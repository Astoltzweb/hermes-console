import 'dart:io';
import 'dart:typed_data';

/// Keeps each server request below 4 MB while preserving every PCM sample.
/// Short captures keep their original WAV; long captures are read from disk
/// one chunk at a time, rather than base64-encoding an hour in memory.
Stream<Uint8List> transcriptionWavChunks(
  File file, {
  Duration chunkDuration = const Duration(minutes: 2),
}) async* {
  const bytesPerSecond = 16000 * 2;
  final maxBytes = chunkDuration.inMilliseconds * bytesPerSecond ~/ 1000;
  if (maxBytes < 2) throw ArgumentError.value(chunkDuration, 'chunkDuration');
  if (await file.length() <= maxBytes + 44) {
    final bytes = await file.readAsBytes();
    if (bytes.isNotEmpty) yield bytes;
    return;
  }
  final handle = await file.open();
  try {
    final header = await handle.read(12);
    String tag(List<int> bytes, int offset) =>
        String.fromCharCodes(bytes.sublist(offset, offset + 4));
    if (header.length != 12 ||
        tag(header, 0) != 'RIFF' ||
        tag(header, 8) != 'WAVE') {
      throw const FormatException('Invalid recorded WAV');
    }
    Uint8List? format;
    int? dataLength;
    while (await handle.position() + 8 <= await file.length()) {
      final chunk = await handle.read(8);
      final size = ByteData.sublistView(chunk).getUint32(4, Endian.little);
      final name = tag(chunk, 0);
      if (name == 'fmt ') {
        if (size < 16 || size > 65536) {
          throw const FormatException('Invalid WAV format');
        }
        format = await handle.read(size);
        if (format.length != size) {
          throw const FormatException('Truncated WAV format');
        }
        if (size.isOdd) await handle.setPosition(await handle.position() + 1);
      } else if (name == 'data') {
        dataLength = size;
        break;
      } else {
        await handle.setPosition(await handle.position() + size + size % 2);
      }
    }
    if (format == null || dataLength == null) {
      throw const FormatException('Missing WAV data');
    }
    final fmt = ByteData.sublistView(format);
    if (fmt.getUint16(0, Endian.little) != 1 ||
        fmt.getUint16(2, Endian.little) != 1 ||
        fmt.getUint32(4, Endian.little) != 16000 ||
        fmt.getUint16(14, Endian.little) != 16 ||
        dataLength.isOdd) {
      throw const FormatException('Expected mono PCM16 at 16 kHz');
    }
    final alignedMax = maxBytes - maxBytes % 2;
    var remaining = dataLength;
    while (remaining > 0) {
      var length = remaining < alignedMax ? remaining : alignedMax;
      final pcm = await handle.read(length);
      if (pcm.length != length) {
        throw const FormatException('Truncated WAV data');
      }
      // Prefer a quiet 20 ms boundary near the end so a word is less likely
      // to be split. Re-read the remainder in the next chunk; no samples drop.
      if (remaining > length && length > bytesPerSecond * 2) {
        final samples = ByteData.sublistView(pcm);
        var bestEnergy = 512.0 * 512.0;
        var boundary = length;
        const windowBytes = 640;
        for (
          var offset = length - bytesPerSecond * 2;
          offset + windowBytes <= length;
          offset += windowBytes
        ) {
          var energy = 0.0;
          for (var i = offset; i < offset + windowBytes; i += 2) {
            final sample = samples.getInt16(i, Endian.little);
            energy += sample * sample;
          }
          energy /= windowBytes ~/ 2;
          if (energy < bestEnergy) {
            bestEnergy = energy;
            boundary = offset + windowBytes ~/ 2;
          }
        }
        if (boundary < length) {
          await handle.setPosition(await handle.position() - length + boundary);
          length = boundary;
        }
      }
      final wav = Uint8List(44 + length);
      wav.setRange(0, 4, 'RIFF'.codeUnits);
      wav.setRange(8, 12, 'WAVE'.codeUnits);
      wav.setRange(12, 16, 'fmt '.codeUnits);
      wav.setRange(20, 36, format.take(16));
      wav.setRange(36, 40, 'data'.codeUnits);
      final data = ByteData.sublistView(wav);
      data.setUint32(4, length + 36, Endian.little);
      data.setUint32(16, 16, Endian.little);
      data.setUint32(40, length, Endian.little);
      wav.setRange(44, wav.length, pcm.take(length));
      yield wav;
      remaining -= length;
    }
  } finally {
    await handle.close();
  }
}
