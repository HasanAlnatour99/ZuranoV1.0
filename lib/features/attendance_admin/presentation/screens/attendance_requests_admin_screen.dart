import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';
import '../../../employee_dashboard/data/models/attendance_request_model.dart';

class AttendanceRequestsAdminScreen extends ConsumerWidget {
  const AttendanceRequestsAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionUserProvider).asData?.value;
    final sid = user?.salonId?.trim() ?? '';
    if (sid.isEmpty) {
      return const Scaffold(body: Center(child: Text('No salon')));
    }

    final stream = ref
        .watch(attendanceRequestsAdminRepositoryProvider)
        .watchPending(sid);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance requests')),
      body: StreamBuilder<List<AttendanceRequestModel>>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No pending requests.',
                style: TextStyle(color: ZuranoPremiumUiColors.textSecondary),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = list[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeamMemberNameText(
                        r.employeeName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text('${r.requestedPunchType.name} · ${r.reason}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(
                                    attendanceRequestsAdminRepositoryProvider,
                                  )
                                  .rejectRequest(
                                    salonId: sid,
                                    requestId: r.requestId,
                                    reviewerUid: user!.uid,
                                    reviewerName: user.name,
                                    reviewNote: 'Rejected',
                                  );
                            },
                            child: const Text('Reject'),
                          ),
                          FilledButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(
                                      attendanceRequestsAdminRepositoryProvider,
                                    )
                                    .approveRequest(
                                      salonId: sid,
                                      requestId: r.requestId,
                                      reviewerUid: user!.uid,
                                      reviewerName: user.name,
                                    );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Approved')),
                                  );
                                }
                              } on Object catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text('$e')));
                                }
                              }
                            },
                            child: const Text('Approve'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
