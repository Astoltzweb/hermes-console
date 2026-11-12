import '../../l10n/app_localizations.dart';
import '../models/session.dart';
import '../bots/state/bot_chat_target.dart' show botChatTitle;

/// [Session.displayTitle] with its generic fallbacks in the app language.
String localizedSessionTitle(Strings strings, Session session) =>
    session.title == botChatTitle &&
        (session.source.startsWith('bot-mode') ||
            session.source == 'mobile-bot')
    ? strings.i18n131McBotChat
    : session.titleWith(
        (kind) => switch (kind) {
          SessionGenericTitle.kanbanTask => strings.i18n1215KanbanTask,
          SessionGenericTitle.scheduledTask => strings.i18n1215ScheduledTask,
          SessionGenericTitle.conversation => strings.i18n1215Conversation,
        },
      );
