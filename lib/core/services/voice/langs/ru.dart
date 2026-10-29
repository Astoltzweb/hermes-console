part of '../voice_language.dart';

class _RuVoiceLanguage extends VoiceLanguage {
  const _RuVoiceLanguage() : super(
    code: 'ru', whisperLanguage: 'ru',
    systemSttLocales: const ['ru_RU', 'ru-RU', 'ru'],
    deviceTtsLocales: const ['ru-RU'], deviceTtsFallback: 'ru-RU',
    neuralVoiceId: null, systemTtsOnly: true, streamingVoiceId: 'af_heart',
    messages: _ruVoiceMessages, commands: _ruVoiceCommands,
    speech: const _RuSpeechGrammar(), transcript: _ruTranscriptGrammar,
  );

  @override
  String normalizeCommand(String input) => input.toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ').trim();

  @override
  LocalVoiceCommand? semanticCommand(String text) {
    final value = normalizeCommand(text);
    if (RegExp(r'^(?:пожалуйста )?(?:закончи|заверши|закрой) (?:разговор|беседу|диалог)(?: пожалуйста)?$').hasMatch(value)) {
      return LocalVoiceCommand.end;
    }
    if (RegExp(r'^(?:пожалуйста )?(?:пауза|сделай паузу|подожди)(?: пожалуйста)?$').hasMatch(value)) {
      return LocalVoiceCommand.pause;
    }
    if (RegExp(r'^(?:пожалуйста )?(?:замолчи|перестань говорить|хватит говорить|останови озвучивание)(?: пожалуйста)?$').hasMatch(value)) {
      return LocalVoiceCommand.silenceCurrent;
    }
    return null;
  }
}

const _ruVoiceCommands = VoiceCommandGrammar(
  silence: ['замолчи', 'перестань говорить', 'хватит говорить', 'останови озвучивание'],
  pause: ['пауза', 'сделай паузу', 'подожди'],
  end: ['закончи разговор', 'заверши беседу', 'закрой диалог'],
  leading: ['гермес', 'пожалуйста'], trailing: ['пожалуйста', 'спасибо'],
  connectors: ['и', 'а также'],
);

const _ruVoiceMessages = <String, String>{
  'microphoneReleasing': 'Микрофон ещё освобождается.',
  'microphoneUnclear': 'Не удалось распознать речь.',
  'didNotHear': 'Я вас не услышал.',
  'microphoneUnavailable': 'Не удалось запустить микрофон.',
  'sendFailed': 'Не удалось отправить сообщение.',
  'responseInterrupted': 'Ответ прерван.',
  'serverUnavailable': 'Голосовой сервис Hermes недоступен. Голосовой режим приостановлен.',
  'approvalRequired': 'Hermes ожидает вашего подтверждения. Откройте приложение.',
  'responseRequired': 'Hermes ожидает вашего ответа. Откройте приложение.',
  'stopNotSaved': 'Не удалось сохранить остановку. Попробуйте ещё раз.',
  'recognitionUnavailable': 'Распознавание речи не готово ({status}).',
};

const _ruTranscriptGrammar = VoiceTranscriptGrammar(
  nonSpeechLabels: r'музыка|шум|тишина|смех|аплодисменты',
  strongMarkers: [],
  subscribeOutro: r'^(?:подпишитесь на канал|спасибо за просмотр)$',
);

class _RuSpeechGrammar extends _EnSpeechGrammar {
  const _RuSpeechGrammar();
  @override String get linkWord => 'ссылка';
  @override String get codeNotice => 'Блок кода пропущен.';
  @override String get emailAt => ' собака ';
  @override String get emailDot => ' точка ';
  @override String get orWord => ' или ';
  @override String get conjunctionPattern => r'(?!)';
  @override String get decimalSeparator => 'запятая';
  @override String get percentUnit => 'процентов';
  @override String get currencyJoiner => ' и ';
  @override String get referenceHeadingPattern => 'источники|ссылки|литература';
  @override bool get dateMonthFirst => false;
  @override bool get decimalUsesDot => false;
  @override (String, String, String, String)? currencyNames(String currency) => null;
  @override String clock(int hour, String minutes) => '$hour:$minutes';
  @override String formatDate(int day, int month, int year) => '$day.$month.$year';
  @override String formatFraction(String numerator, String denominator) => '$numerator / $denominator';
}
