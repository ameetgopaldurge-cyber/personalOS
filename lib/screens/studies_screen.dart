import 'package:flutter/material.dart';
import '../models/os_models.dart';
import '../providers/os_controller.dart';
import '../theme/os_theme.dart';
import '../widgets/os_widgets.dart';

class StudiesScreen extends StatelessWidget {
  final PersonalOSController controller;

  const StudiesScreen({super.key, required this.controller});

  void _showAddAssignmentModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    String selectedCode = controller.subjects.first.code;
    String selectedCategory = 'Assignments';
    String selectedPriority = 'High';
    int daysUntilDue = 2;

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
                    'Add Assignment or Exam Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: PersonalOSTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Task Title (e.g. Lab 4: Trees)',
                      filled: true,
                      fillColor: PersonalOSTheme.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCode,
                          dropdownColor: PersonalOSTheme.surfaceElevated,
                          decoration: InputDecoration(
                            labelText: 'Course',
                            filled: true,
                            fillColor: PersonalOSTheme.surfaceElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: controller.subjects
                              .map((s) => DropdownMenuItem(
                                    value: s.code,
                                    child: Text(s.code),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setModalState(() => selectedCode = v);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: daysUntilDue,
                          dropdownColor: PersonalOSTheme.surfaceElevated,
                          decoration: InputDecoration(
                            labelText: 'Due In',
                            filled: true,
                            fillColor: PersonalOSTheme.surfaceElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('Today')),
                            DropdownMenuItem(value: 1, child: Text('Tomorrow')),
                            DropdownMenuItem(value: 2, child: Text('In 2 Days')),
                            DropdownMenuItem(value: 5, child: Text('In 5 Days')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setModalState(() => daysUntilDue = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PersonalOSTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (titleCtrl.text.trim().isNotEmpty) {
                          controller.addAssignment(
                            title: titleCtrl.text.trim(),
                            courseCode: selectedCode,
                            category: selectedCategory,
                            priority: selectedPriority,
                            daysFromNow: daysUntilDue,
                          );
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text(
                        'Save Academic Deadline',
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
    final sortedSubjects = controller.prioritizedSubjects;
    final pastDueList =
        controller.assignments.where((a) => a.isOverdue).toList();
    final upcomingList =
        controller.assignments.where((a) => !a.isOverdue).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      children: [
        // Top Header (Matches Screenshot 3: "Overview ✓")
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Text(
                      'Academic Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: PersonalOSTheme.skyBlue,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.verified_rounded,
                        color: PersonalOSTheme.amberWarning, size: 22),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Sorted by Exam Proximity & Attendance Risk (<75%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: PersonalOSTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 2x2 Grades & Attendance Grid (Matches Screenshot 3 "Grades" cards)
        const SectionHeader(title: 'Classes, Attendance & Exam Triage'),
        ...sortedSubjects.map((subject) {
          final attPct = (subject.attendanceRatio * 100).toStringAsFixed(1);
          final isLow = subject.isAttendanceLow;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: PersonalOSTheme.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isLow
                    ? PersonalOSTheme.coralRed.withOpacity(0.65)
                    : PersonalOSTheme.borderSubtle,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: subject.accentColor.withOpacity(0.2),
                      child: Text(
                        subject.code.substring(0, 2),
                        style: TextStyle(
                          color: subject.accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: const TextStyle(
                              color: PersonalOSTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Grade: ${subject.currentGradePercent}% • Exam in ${subject.daysUntilExam}d',
                            style: const TextStyle(
                              color: PersonalOSTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isLow
                            ? PersonalOSTheme.coralRed.withOpacity(0.2)
                            : PersonalOSTheme.neonLime.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$attPct% (${subject.attendedClasses}/${subject.totalClasses})',
                        style: TextStyle(
                          color: isLow
                              ? PersonalOSTheme.coralRed
                              : PersonalOSTheme.neonLime,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  subject.urgencyReason,
                  style: TextStyle(
                    color: isLow
                        ? PersonalOSTheme.coralRed
                        : PersonalOSTheme.amberWarning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                // Quick Attendance Buttons + Revision Topics
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PersonalOSTheme.neonLime,
                        side: const BorderSide(
                            color: PersonalOSTheme.borderSubtle),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () =>
                          controller.markAttendance(subject.id, attended: true),
                      icon: const Icon(Icons.check, size: 15),
                      label: const Text('Attended +1',
                          style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PersonalOSTheme.coralRed,
                        side: const BorderSide(
                            color: PersonalOSTheme.borderSubtle),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => controller.markAttendance(subject.id,
                          attended: false),
                      icon: const Icon(Icons.close, size: 15),
                      label: const Text('Missed',
                          style: TextStyle(fontSize: 11)),
                    ),
                    const Spacer(),
                    Text(
                      'Revision: ${subject.completedTopics.length}/${subject.revisionTopics.length}',
                      style: const TextStyle(
                        color: PersonalOSTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: subject.revisionTopics.map((topic) {
                    final done = subject.completedTopics.contains(topic);
                    return FilterChip(
                      label: Text(
                        topic,
                        style: TextStyle(
                          fontSize: 11,
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      selected: done,
                      onSelected: (_) =>
                          controller.toggleRevisionTopic(subject.id, topic),
                      selectedColor:
                          PersonalOSTheme.primaryPurple.withOpacity(0.28),
                      checkmarkColor: PersonalOSTheme.neonLime,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),

        // Past Due Section (Matches Screenshot 3 "Past Due")
        if (pastDueList.isNotEmpty) ...[
          const Text(
            'Past Due',
            style: TextStyle(
              color: PersonalOSTheme.coralRed,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...pastDueList.map((a) => _AssignmentTile(
                assignment: a,
                onToggle: () => controller.toggleAssignment(a.id),
              )),
          const SizedBox(height: 14),
        ],

        // Today & Upcoming Deadlines (Matches Screenshot 3 "Today")
        SectionHeader(
          title: 'Today & Upcoming Deadlines',
          actionLabel: 'Add Deadline',
          onAction: () => _showAddAssignmentModal(context),
        ),
        ...upcomingList.map((a) => _AssignmentTile(
              assignment: a,
              onToggle: () => controller.toggleAssignment(a.id),
            )),
      ],
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final AcademicAssignment assignment;
  final VoidCallback onToggle;

  const _AssignmentTile({
    required this.assignment,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: PersonalOSTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: assignment.isOverdue
              ? PersonalOSTheme.coralRed.withOpacity(0.5)
              : PersonalOSTheme.borderSubtle,
        ),
      ),
      child: ListTile(
        onTap: onToggle,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: assignment.isCompleted
              ? PersonalOSTheme.neonLime.withOpacity(0.2)
              : PersonalOSTheme.primaryPurple.withOpacity(0.2),
          child: Icon(
            assignment.isCompleted ? Icons.check : Icons.assignment_outlined,
            color: assignment.isCompleted
                ? PersonalOSTheme.neonLime
                : PersonalOSTheme.primaryPurple,
            size: 18,
          ),
        ),
        title: Text(
          assignment.title,
          style: TextStyle(
            color: PersonalOSTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration:
                assignment.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4, right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: PersonalOSTheme.skyBlue.withOpacity(0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${assignment.courseCode} • ${assignment.category}',
                style: const TextStyle(
                  color: PersonalOSTheme.skyBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          assignment.isOverdue ? 'OVERDUE' : assignment.priority,
          style: TextStyle(
            color: assignment.isOverdue
                ? PersonalOSTheme.coralRed
                : PersonalOSTheme.neonLime,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
