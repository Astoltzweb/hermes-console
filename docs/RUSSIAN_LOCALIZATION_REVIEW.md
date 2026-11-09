# Full Russian localization review

This is an ongoing review of the complete Russian interface, not a claim that
the catalog has already been fully reviewed. Baseline: `243e8d6`.

## Scope and completion criteria

- Review all 4,963 catalog messages against their English meaning and the
  authoritative Spanish template; preserve previously approved wording.
- Translate every ICU branch and use Russian number agreement, including
  counts such as 11, 21, 22 and 25. Preserve placeholders and protocol values.
- Check permission labels against the actual approval policy. UI copy changes
  must not change authorization behavior.
- Inspect handwritten UI copy, Android resources, notifications and widgets.
- Generate the locale, validate catalog contracts, analyze and build the app,
  then inspect representative screens on the personal Android installation.
- Commit and push the finished work on `fix/connection-stability-and-russian`.

## Current checkpoint

2,055 unique messages have been reviewed. The first 2,050 messages in the
English catalog's insertion order are covered, together with five additional
permission/model messages. The next sequential key is `chaAttachmentPreviewLoading`.

Covered areas: connection setup, navigation, themes, chat controls and errors,
voice chat status, generated media, MoA, Kanban, SSH/SFTP, SOUL editing, memory,
app information, server settings, permissions, notifications, model selection,
reasoning levels, scheduled tasks, security and session details.

The remaining catalog and the non-ARB audit are still pending. The initial
handwritten-copy inventory contains 197 candidates; these include intentional
technical strings and require individual inspection. The Russian native widget
resources also need review. MoA fan-out values (`per_iteration`, `user_turn`)
need localized display labels; the wire values must stay unchanged. No full linguistic-completion claim is made here.

## Terminology

- Session permissions: `Разрешения в этом чате`.
- Effective mode: `Текущий режим`.
- Ask: `Запрашивать разрешение`.
- Conservative: `Строгий контроль` (always asks, ignores saved always-rules,
  and requires extra confirmation for high-risk actions).
- YOLO: `Без подтверждений (YOLO)`; high-risk warnings retain their meaning.
- Read only: `Только чтение`.
- Reasoning effort: `Уровень рассуждений`, with distinct levels from
  `Минимальный` through `Предельный`.
- Dashboard: `Панель управления`; instance: `Сервер`; draft: `Черновик`.
- API/provider names, wire identifiers, commands, URLs and file names remain
  unchanged; product brands retain their original spelling.
