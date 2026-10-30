import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Russian notification and run labels describe tasks, not jogging', () {
    final ru = jsonDecode(File('lib/l10n/app_ru.arb').readAsStringSync())
        as Map<String, dynamic>;
    expect(ru['notifRunsTitle'], 'Выполнение задач');
    expect(ru['notifRunsSub'], 'Когда выполнение задачи завершается успешно или с ошибкой');
    expect(ru['notifTestButton'], 'Проверить уведомления');
    expect(ru['statusDisabled'], 'отключено');
    expect(ru['cronDeleteConversationAndScheduleHelp'], 'Также отменить будущие запуски.');
    final runTerms = RegExp(r'пробеж|\bбежит\b|\bзабег|\bинвалид\b', caseSensitive: false, unicode: true);
    for (final entry in ru.entries) {
      if (entry.value is String) {
        expect(runTerms.hasMatch(entry.value as String), isFalse, reason: entry.key);
      }
    }
  });
}
