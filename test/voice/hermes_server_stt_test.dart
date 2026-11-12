import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/voice/stt_hermes_server.dart';
import 'package:hermes_android/core/services/voice/stt_engine.dart';
import 'package:hermes_android/core/services/voice/wav_chunks.dart';
import 'package:record/record.dart';

/// Spec 048 / US5 — runtime STT contra /api/audio/transcribe
/// (contracts/native-voice.md): el clip WAV local viaja como data_url base64
/// y el transcript del servidor vuelve como final; errores limpios.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('captura habla con el preset acústico equivalente a Desktop', () async {
    expect(kHermesServerSttRecordConfig.encoder, AudioEncoder.wav);
    expect(kHermesServerSttRecordConfig.sampleRate, 16000);
    expect(kHermesServerSttRecordConfig.numChannels, 1);
    expect(kHermesServerSttRecordConfig.echoCancel, isTrue);
    expect(kHermesServerSttRecordConfig.noiseSuppress, isTrue);
    expect(
      kHermesServerSttRecordConfig.androidConfig.audioSource,
      AndroidAudioSource.voiceRecognition,
    );

    final engine = buildHermesServerSttEngine(
      transcribeRequest: (_, _) async => <String, dynamic>{
        'ok': true,
        'transcript': '',
      },
      lang: 'es',
    );
    expect(engine.speechOnsetDb, -18);
    expect(engine.discardAutomaticTurnWithoutSpeechOnset, isTrue);
    await engine.dispose();
  });

  Future<String> clip(List<int> bytes) async {
    final dir = await Directory.systemTemp.createTemp('hermes-stt');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/turno.wav');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  test('el clip se envía como data_url WAV y vuelve el transcript', () async {
    final requests = <(String, String)>[];
    final runtime = HermesServerSttRuntime(
      transcribeRequest: (dataUrl, mimeType) async {
        requests.add((dataUrl, mimeType));
        return {'ok': true, 'transcript': ' hola servidor ', 'provider': 'fw'};
      },
    );
    addTearDown(runtime.dispose);
    final path = await clip([1, 2, 3, 4]);

    final transcript = await runtime.transcribe(
      model: WhisperModel.tiny,
      audioPath: path,
      lang: 'es',
      threads: 2,
    );

    expect(transcript, 'hola servidor');
    expect(requests.single.$2, 'audio/wav');
    expect(
      requests.single.$1,
      'data:audio/wav;base64,${base64Encode([1, 2, 3, 4])}',
    );
  });

  test('un clip vacío no llama al servidor y devuelve vacío', () async {
    var calls = 0;
    final runtime = HermesServerSttRuntime(
      transcribeRequest: (dataUrl, mimeType) async {
        calls++;
        return {'ok': true, 'transcript': 'nunca'};
      },
    );
    addTearDown(runtime.dispose);
    final path = await clip(const []);

    final transcript = await runtime.transcribe(
      model: WhisperModel.tiny,
      audioPath: path,
      lang: 'es',
      threads: 2,
    );

    expect(transcript, '');
    expect(calls, 0);
  });

  test(
    'una respuesta sin ok lanza sin copiar el detalle del servidor',
    () async {
      final runtime = HermesServerSttRuntime(
        transcribeRequest: (dataUrl, mimeType) async => {
          'ok': false,
          'detail': 'PRIVATE_STT_SERVER_DETAIL /home/server/audio.wav',
        },
      );
      addTearDown(runtime.dispose);
      final path = await clip([1]);

      await expectLater(
        runtime.transcribe(
          model: WhisperModel.tiny,
          audioPath: path,
          lang: 'es',
          threads: 2,
        ),
        throwsA(
          predicate<Object>(
            (error) =>
                !error.toString().contains('PRIVATE_STT_SERVER_DETAIL') &&
                !error.toString().contains('/home/server'),
          ),
        ),
      );
    },
  );

  Uint8List wav(int pcmBytes) {
    final bytes = Uint8List(44 + pcmBytes);
    bytes.setRange(0, 4, 'RIFF'.codeUnits);
    bytes.setRange(8, 12, 'WAVE'.codeUnits);
    bytes.setRange(12, 16, 'fmt '.codeUnits);
    bytes.setRange(36, 40, 'data'.codeUnits);
    final data = ByteData.sublistView(bytes);
    data.setUint32(4, pcmBytes + 36, Endian.little);
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, 16000, Endian.little);
    data.setUint32(28, 32000, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    data.setUint32(40, pcmBytes, Endian.little);
    for (var i = 44; i < bytes.length; i++) {
      bytes[i] = i % 251;
    }
    return bytes;
  }

  test(
    'WAV chunks preserve every sample in order with valid headers',
    () async {
      final original = wav(3200);
      final path = await clip(original);
      final chunks = await transcriptionWavChunks(
        File(path),
        chunkDuration: const Duration(milliseconds: 20),
      ).toList();
      expect(chunks.length, 5);
      final pcm = <int>[];
      for (final chunk in chunks) {
        expect(String.fromCharCodes(chunk.sublist(0, 4)), 'RIFF');
        expect(ByteData.sublistView(chunk).getUint32(40, Endian.little), 640);
        pcm.addAll(chunk.sublist(44));
      }
      expect(pcm, original.sublist(44));
    },
  );

  test(
    'long dictation uses bounded requests and joins transcripts in order',
    () async {
      final path = await clip(wav(32000 * 121));
      final sizes = <int>[];
      final runtime = HermesServerSttRuntime(
        transcribeRequest: (url, mime) async {
          final bytes = base64Decode(url.split(',').last);
          sizes.add(bytes.length);
          return {'ok': true, 'transcript': 'part${sizes.length}'};
        },
      );
      final text = await runtime.transcribe(
        model: WhisperModel.tiny,
        audioPath: path,
        lang: 'ru',
        threads: 2,
      );
      expect(text, 'part1 part2');
      expect(sizes, [32000 * 120 + 44, 32000 + 44]);
      await runtime.dispose();
    },
  );

  test('quiet boundaries do not drop or repeat PCM samples', () async {
    final original = wav(32000 * 121);
    original.fillRange(32000 * 118 + 44, 32000 * 120 + 44, 0);
    final path = await clip(original);
    var bytesSeen = 0;
    var chunksSeen = 0;
    await for (final chunk in transcriptionWavChunks(File(path))) {
      final pcm = chunk.sublist(44);
      expect(
        pcm,
        original.sublist(44 + bytesSeen, 44 + bytesSeen + pcm.length),
      );
      expect(chunk.length, lessThanOrEqualTo(32000 * 120 + 44));
      bytesSeen += pcm.length;
      chunksSeen++;
    }
    expect(chunksSeen, 2);
    expect(bytesSeen, original.length - 44);
  });

  test('a failed later chunk retains already transcribed text', () async {
    final path = await clip(wav(32000 * 121));
    var calls = 0;
    final runtime = HermesServerSttRuntime(
      transcribeRequest: (url, mime) async {
        if (++calls == 2) throw StateError('network');
        return {'ok': true, 'transcript': 'preserved text'};
      },
    );
    await expectLater(
      runtime.transcribe(
        model: WhisperModel.tiny,
        audioPath: path,
        lang: 'ru',
        threads: 2,
      ),
      throwsA(
        isA<PartialTranscriptionException>().having(
          (e) => e.text,
          'recognized text',
          'preserved text',
        ),
      ),
    );
    await runtime.dispose();
  });

  test('el modelo local nunca es requisito: modelReady es true', () async {
    final runtime = HermesServerSttRuntime(
      transcribeRequest: (dataUrl, mimeType) async => {'ok': true},
    );
    addTearDown(runtime.dispose);

    expect(await runtime.modelReady(WhisperModel.tiny), isTrue);
  });
}
