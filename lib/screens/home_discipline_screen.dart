import 'package:flutter/material.dart';
import '../models/os_models.dart';
import '../providers/os_controller.dart';
import '../theme/os_theme.dart';
import '../widgets/os_widgets.dart';

class HomeDisciplineScreen extends StatelessWidget {
  final PersonalOSController controller;
  final ValueChanged<int> onNavigateTab;

  const HomeDisciplineScreen({
    super.key,
    required this.controller,
    required this.onNavigateTab,
  });

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showFailureDiagnosisSheet(BuildContext context) {
    final taskCtrl = TextEditingController(
      text: 'Complete Graph Shortest Path Lab',
    );
    String selectedCause = 'Overwhelmed / Too Big';
    final causes = [
      'Overwhelmed / Too Big',
      'Phone Distraction',
      'Low Energy / Poor Sleep',
      'Unclear Next Step',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PersonalOSTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why Did a Plan Stall Today?',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: PersonalOSTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Diagnose the friction so Personal OS adjusts the plan without abandoning your goal.',
                    style: TextStyle(
                      fontSize: 13,
                      color: PersonalOSTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: taskCtrl,
                    decoration: InputDecoration(
                      labelText: 'Unfinished Task or Goal',
                      filled: true,
                      fillColor: PersonalOSTheme.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Select Root Cause:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PersonalOSTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: causes.map((cause) {
                      final isSelected = selectedCause == cause;
                      return ChoiceChip(
                        label: Text(cause),
                        selected: isSelected,
                        selectedColor:
                            PersonalOSTheme.primaryPurple.withOpacity(0.3),
                        onSelected: (_) {
                          setModalState(() => selectedCause = cause);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PersonalOSTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (taskCtrl.text.trim().isNotEmpty) {
                          controller.diagnoseAndAdaptFailedPlan(
                            taskTitle: taskCtrl.text.trim(),
                            rootCause: selectedCause,
                          );
                          Navigator.pop(ctx);
                        }
                      },
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text(
                        'Adapt Plan & Keep Momentum',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final completionPercent = (controller.overallOSCompletion * 100).round();
    final urgentSubject = controller.topUrgentSubject;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      children: [
        // Top Header (Matches Screenshot 1: "Good morning, Alex 👋")
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,\n${controller.userName} 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: PersonalOSTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Personal OS • All 6 Systems Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: PersonalOSTheme.textSecondary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: PersonalOSTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PersonalOSTheme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt,
                          color: PersonalOSTheme.neonLime, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.focusMinutesToday}m focus',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: PersonalOSTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: PersonalOSTheme.primaryPurple,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Hero Radial Progress Ring (Screenshot 1 centerpiece)
        Center(
          child: NeonProgressRing(
            progress: controller.overallOSCompletion,
            size: 200,
            strokeWidth: 15,
            color: PersonalOSTheme.primaryPurple,
            centerChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$completionPercent%',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: PersonalOSTheme.textPrimary,
                  ),
                ),
                const Text(
                  'Daily OS Score',
                  style: TextStyle(
                    fontSize: 12,
                    color: PersonalOSTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),

        // 3 KPI Cards Row (Matches Screenshot 1: Active Projects, Consistency, Attention)
        Row(
          children: [
            MetricStatCard(
              icon: Icons.folder_special_rounded,
              iconColor: PersonalOSTheme.primaryPurple,
              value: '${controller.skillTracks.length}',
              label: 'Active Skill Projects',
              onTap: () => onNavigateTab(4),
            ),
            const SizedBox(width: 10),
            MetricStatCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: PersonalOSTheme.neonLime,
              value:
                  '${controller.habits.where((h) => h.completedToday).length}/${controller.habits.length}',
              label: 'Habits Locked Today',
            ),
            const SizedBox(width: 10),
            MetricStatCard(
              icon: Icons.warning_amber_rounded,
              iconColor: PersonalOSTheme.amberWarning,
              value:
                  '${controller.subjects.where((s) => s.isAttendanceLow).length + controller.assignments.where((a) => !a.isCompleted).length}',
              label: 'Needs Attention',
              onTap: () => onNavigateTab(1),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Smart Priority Triage Banner ("What Needs Attention First")
        if (urgentSubject != null)
          GestureDetector(
            onTap: () => onNavigateTab(1),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PersonalOSTheme.coralRed.withOpacity(0.20),
                    PersonalOSTheme.surfaceCard,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: PersonalOSTheme.coralRed.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PersonalOSTheme.coralRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: PersonalOSTheme.coralRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NEEDS ATTENTION FIRST',
                          style: TextStyle(
                            color: PersonalOSTheme.coralRed,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${urgentSubject.code}: ${urgentSubject.name}',
                          style: const TextStyle(
                            color: PersonalOSTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          urgentSubject.urgencyReason,
                          style: const TextStyle(
                            color: PersonalOSTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: PersonalOSTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 22),

        // Deep Focus Session & Distraction Shield (Module 6: Personal Discipline)
        const SectionHeader(title: 'Deep Focus & Distraction Shield'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PersonalOSTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: PersonalOSTheme.borderSubtle),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pomodoro Sprint Timer',
                        style: TextStyle(
                          color: PersonalOSTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimer(controller.remainingSeconds),
                        style: const TextStyle(
                          color: PersonalOSTheme.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isTimerRunning
                              ? PersonalOSTheme.amberWarning
                              : PersonalOSTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: controller.toggleFocusTimer,
                        icon: Icon(
                          controller.isTimerRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          controller.isTimerRunning ? 'Pause' : 'Start 25m',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => controller.resetFocusTimer(),
                        icon: const Icon(Icons.refresh_rounded,
                            color: PersonalOSTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24, color: PersonalOSTheme.borderSubtle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Caught yourself scrolling? Log urge & return (${controller.distractionCountToday} caught today)',
                      style: const TextStyle(
                        color: PersonalOSTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PersonalOSTheme.neonLime,
                      side: const BorderSide(color: PersonalOSTheme.neonLime),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.logDistractionImpulse,
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    label: const Text(
                      'Resist Urge',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Daily Habits Checklist across all pillars
        const SectionHeader(title: 'Daily Non-Negotiable Habits'),
        ...controller.habits.map((habit) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: PersonalOSTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: habit.completedToday
                    ? PersonalOSTheme.primaryPurple.withOpacity(0.5)
                    : PersonalOSTheme.borderSubtle,
              ),
            ),
            child: ListTile(
              onTap: () => controller.toggleHabit(habit.id),
              leading: Icon(
                habit.completedToday
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: habit.completedToday
                    ? PersonalOSTheme.neonLime
                    : PersonalOSTheme.textMuted,
              ),
              title: Text(
                habit.title,
                style: TextStyle(
                  color: PersonalOSTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration:
                      habit.completedToday ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                '${habit.pillar} • 🔥 ${habit.streakDays} day streak',
                style: const TextStyle(
                  color: PersonalOSTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PersonalOSTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  habit.pillar,
                  style: const TextStyle(
                    fontSize: 11,
                    color: PersonalOSTheme.primaryPurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),

        // Why Plans Fail & Adaptive Goal Reset Engine
        SectionHeader(
          title: 'Why Plans Failed & Adaptive Reset',
          actionLabel: 'Diagnose Friction',
          onAction: () => _showFailureDiagnosisSheet(context),
        ),
        ...controller.diagnostics.map((diag) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PersonalOSTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PersonalOSTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: PersonalOSTheme.amberWarning.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Root Cause: ${diag.rootCause}',
                        style: const TextStyle(
                          color: PersonalOSTheme.amberWarning,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.autorenew_rounded,
                        size: 16, color: PersonalOSTheme.neonLime),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  diag.unfinishedTaskTitle,
                  style: const TextStyle(
                    color: PersonalOSTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'System Adjustment: ${diag.adaptiveAdjustment}',
                  style: const TextStyle(
                    color: PersonalOSTheme.neonLime,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
