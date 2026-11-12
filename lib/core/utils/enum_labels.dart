/// Localized labels for shared enums (approval mode, risk), used by
/// permissions, the chat (approvals) and runs. The approval mode has no other
/// name for people; the UI always goes through these helpers.
library;

import '../../l10n/app_localizations.dart';
import '../services/approval_policy.dart';
import '../services/command_risk.dart';

String approvalModeLabel(Strings s, ApprovalMode m) => switch (m) {
  ApprovalMode.globalDefault => s.modeGlobalDefault,
  ApprovalMode.yolo => s.modeYolo,
  ApprovalMode.interactive => s.modeInteractive,
  ApprovalMode.conservative => s.modeConservative,
  ApprovalMode.readOnly => s.modeReadOnly,
};

String commandRiskLabel(Strings s, CommandRisk r) => switch (r) {
  CommandRisk.low => s.riskLow,
  CommandRisk.medium => s.riskMedium,
  CommandRisk.high => s.riskHigh,
};

/// Display names for run states; server status values stay unchanged.
String kanbanRunStatusLabel(Strings s, String status) => switch (status) {
  'running' => s.statusRunning,
  'done' || 'completed' || 'succeeded' => s.crnRunCompleted,
  'failed' || 'crashed' || 'error' => s.crnRunFailed,
  'cancelled' || 'canceled' => s.tg1215TurnCancelled,
  'stopped' || 'terminated' => s.subagentUiStatusStopped,
  'queued' || 'pending' => s.kanbanColTodo,
  _ => status.replaceAll('_', ' '),
};

/// An incomplete team warning is about exactly one member, not 21 or 101.
String roomMemberCountLabel(Strings s, int count) =>
    count == 1 ? s.roomAvatarSingleMember : s.roomAvatarMembers(count);
