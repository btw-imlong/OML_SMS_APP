import 'package:flutter/material.dart';
import 'package:flutter_sms/core/models/user_role.dart';

/// Mirrors the backend enum: com.onemore.mission.mission.domain.MissionStatus
enum MissionStatus {
  draft('DRAFT', 'Draft', Color(0xFF6B7280), Color(0xFFF1F2F4)),
  submitted('SUBMITTED', 'Submitted', Color(0xFF1D4ED8), Color(0xFFE6EEFC)),
  fmReview('FM_REVIEW', 'FM Review', Color(0xFFB45309), Color(0xFFFEF3C7)),
  hrbpReview('HRBP_REVIEW', 'HRBP Review', Color(0xFFB45309), Color(0xFFFEF3C7)),
  financeReview('FINANCE_REVIEW', 'Finance Review', Color(0xFFB45309), Color(0xFFFEF3C7)),
  bizopsReview('BIZOPS_REVIEW', 'BizOps Review', Color(0xFFB45309), Color(0xFFFEF3C7)),
  executiveReview('EXECUTIVE_REVIEW', 'Executive Review', Color(0xFFB45309), Color(0xFFFEF3C7)),
  approved('APPROVED', 'Approved', Color(0xFF15803D), Color(0xFFDCFCE7)),
  rejected('REJECTED', 'Rejected', Color(0xFFB91C1C), Color(0xFFFEE2E2)),
  cancelled('CANCELLED', 'Cancelled', Color(0xFF4B5563), Color(0xFFE5E7EB)),
  reportSubmitted('REPORT_SUBMITTED', 'Report Submitted', Color(0xFF0F766E), Color(0xFFCCFBF1)),
  settled('SETTLED', 'Settled', Color(0xFF6D28D9), Color(0xFFEDE9FE));

  const MissionStatus(this.code, this.label, this.color, this.background);

  /// Value sent by the backend, e.g. FM_REVIEW.
  final String code;
  final String label;
  final Color color;
  final Color background;

  static MissionStatus? tryParse(String? raw) {
    if (raw == null) return null;
    final value = raw.trim().toUpperCase();
    for (final s in MissionStatus.values) {
      if (s.code == value) return s;
    }
    return null;
  }
}

/// Which statuses are "waiting for me" for each role.
extension UserRoleQueue on UserRole {
  Set<MissionStatus> get queueStatuses {
    switch (this) {
      case UserRole.staff:
        return const <MissionStatus>{};
      case UserRole.functionManager:
        return const {MissionStatus.fmReview};
      case UserRole.hrbp:
        return const {MissionStatus.hrbpReview};
      case UserRole.finance:
        return const {MissionStatus.financeReview, MissionStatus.reportSubmitted};
      case UserRole.bizops:
        return const {MissionStatus.bizopsReview};
      case UserRole.executive:
        return const {MissionStatus.executiveReview};
      case UserRole.admin:
        return const {
          MissionStatus.fmReview,
          MissionStatus.hrbpReview,
          MissionStatus.financeReview,
          MissionStatus.bizopsReview,
          MissionStatus.executiveReview,
        };
    }
  }
}
