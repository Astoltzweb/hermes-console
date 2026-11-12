# Full Russian localization review

The source review covers the complete Russian catalog and the native widget
resources. Baseline: `243e8d6`. The new personal APK has been installed on Galaxy S22; representative runtime
screens have been checked.

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

All 4,963 original messages have been reviewed; 3,255 were corrected against
the baseline. Three additional shared UI
messages bring the catalog to 4,966: the Dashboard diagnostic button, a
localized kilobyte value, and the warning for a room with exactly one member.

The review covers connection setup, navigation, themes, chat controls, errors,
voice settings, generated media, MoA, Kanban, SSH/SFTP, SOUL, memory, permissions,
notifications, model selection, reasoning levels, schedules, backups, imports,
projects, profiles, MCP/OAuth/webhooks, pets, and accessibility descriptions.

The 197 handwritten-copy candidates were inspected. Technical identifiers,
brands, user-provided names, command examples and diagnostic service messages
remain literal. Theme service messages are diagnostic data: the UI uses
`themeErrorCopy` and localized counts instead. UI gaps fixed include diagnostic
Dashboard/latency labels, voice-download sizes, memory sizes, elapsed seconds,
run status names, and canonical Bot Chat display names. Protocol/session titles
are not rewritten on the server.

All 115 translatable native launcher-widget resources now have Russian copy,
including format arguments and Russian plural categories. The separate
background notification catalog and native notification strings were reviewed.
MoA's `per_iteration` and `user_turn` values have Russian display labels while
the wire values remain unchanged.

Flutter maps both `=1` and `one` to one generated branch. Redundant shadowed
branches were removed. The incomplete-team warning uses an explicit count == 1
UI condition, so it does not appear for 21 or 101 members. Regression checks
cover this distinction, plural agreement, and MoA mode labels.

The strict Spanish-structure checker is not a linguistic completion gate:
Russian count labels can use different plural/select structures and can omit
repeated brand mentions. Template key/argument parity, ICU parsing and generated
Russian output are checked separately without changing that checker.

The source review is complete. Personal build `1.3.1-ru.5` (9654) was installed
over the previous personal build with data preserved. Home, the composer,
model/reasoning settings and chat permissions were inspected on Galaxy S22.
The corrected text is visible and the Hermes connection is established.

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

## Validation

- Generated localization successfully; no shadowed Russian plural warnings.
- Four Russian catalog/number/MoA regression checks passed.
- 29 locale, notification, Kanban and session-title checks passed.
- 106 STT, worker, server-transcription, lifecycle and room-dictation checks
  passed, including bounded WAV requests and partial-result preservation.
- `flutter analyze --no-pub`: no issues found.
- Native widget resource names, format arguments and plural categories match
  the base resource contract (115 entries).
- Personal arm64/full debug APK build succeeded; signer continuity and package/version were checked before an in-place ADB update.
- Manual dictation remained active on the physical phone after 72.6 seconds and was then cancelled; the existing composer draft was retained. This verifies crossing the former one-minute deadline, not an hour-long endurance run.
