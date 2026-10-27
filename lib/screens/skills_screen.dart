import 'package:flutter/material.dart';
import '../models/os_models.dart';
import '../providers/os_controller.dart';
import '../theme/os_theme.dart';
import '../widgets/os_widgets.dart';

class SkillsScreen extends StatelessWidget {
  final PersonalOSController controller;

  const SkillsScreen({super.key, required this.controller});

  void _showTrackDetailModal(BuildContext context, SkillTrack track) {
    final lessonCtrl = TextEditingController();
    final deliverableCtrl = TextEditingController();

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
                  Text(
                    track.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: PersonalOSTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Active Project: ${track.activeMilestoneProject}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: PersonalOSTheme.neonLime,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(track.lessons.length, (i) {
                    final lesson = track.lessons[i];
                    return CheckboxListTile(
                      value: lesson.isCompleted,
                      activeColor: PersonalOSTheme.primaryPurple,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        lesson.title,
                        style: TextStyle(
                          color: PersonalOSTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: lesson.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        'Output: ${lesson.deliverableHint}',
                        style: const TextStyle(
                          color: PersonalOSTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      onChanged: (_) {
                        controller.toggleSkillLesson(track.id, i);
                        setModalState(() {});
                      },
                    );
                  }),
                  const Divider(color: PersonalOSTheme.borderSubtle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: lessonCtrl,
                    decoration: InputDecoration(
                      labelText: 'Add Next Small Lesson Step',
                      filled: true,
                      fillColor: PersonalOSTheme.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: deliverableCtrl,
                    decoration: InputDecoration(
                      labelText: 'Real Project Proof / Deliverable',
                      filled: true,
                      fillColor: PersonalOSTheme.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PersonalOSTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (lessonCtrl.text.trim().isNotEmpty) {
                          controller.addMicroLesson(
                            track.id,
                            lessonCtrl.text.trim(),
                            deliverableCtrl.text.trim().isEmpty
                                ? 'Push working code to GitHub'
                                : deliverableCtrl.text.trim(),
                          );
                          lessonCtrl.clear();
                          deliverableCtrl.clear();
                          setModalState(() {});
                        }
                      },
                      child: const Text('Add Micro-Lesson'),
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
    final totalCommits = controller.skillTracks
        .fold(0, (sum, item) => sum + item.githubCommitsThisWeek);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      children: [
        // Header (Matches Screenshot 5: "My Courses" with purple "My")
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(
                    text: 'My ',
                    style: TextStyle(color: PersonalOSTheme.primaryPurple),
                  ),
                  TextSpan(
                    text: 'Skills & Projects',
                    style: TextStyle(color: PersonalOSTheme.textPrimary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: PersonalOSTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.commit_rounded,
                      size: 16, color: PersonalOSTheme.neonLime),
                  const SizedBox(width: 4),
                  Text(
                    '$totalCommits GitHub Commits/wk',
                    style: const TextStyle(
                      color: PersonalOSTheme.neonLime,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Broad ambitions broken into micro-lessons & shipped proof-of-work',
          style: TextStyle(
            fontSize: 12,
            color: PersonalOSTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 18),

        // 2-Column Grid of Skill Cards (Matches Screenshot 5 2x3 "Resume" cards)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.skillTracks.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final track = controller.skillTracks[index];
            final pct = (track.progress * 100).round();
            final isComplete = pct == 100;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PersonalOSTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PersonalOSTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PersonalOSTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        isComplete
                            ? Icons.check_circle
                            : Icons.timelapse_rounded,
                        size: 15,
                        color: isComplete
                            ? PersonalOSTheme.neonLime
                            : PersonalOSTheme.amberWarning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$pct% completed',
                        style: const TextStyle(
                          color: PersonalOSTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.folder_outlined,
                        size: 15,
                        color: PersonalOSTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${track.completedCount}/${track.lessons.length} modules',
                        style: const TextStyle(
                          color: PersonalOSTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    track.activeMilestoneProject,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: track.accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PersonalOSTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => _showTrackDetailModal(context, track),
                      child: const Text(
                        'Resume',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 22),

        // Detailed Micro-Lessons & Real Project Breakdown
        const SectionHeader(title: 'Active Sequence of Lessons & Deliverables'),
        ...controller.skillTracks.map((track) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: PersonalOSTheme.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PersonalOSTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      track.name,
                      style: const TextStyle(
                        color: PersonalOSTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${track.githubCommitsThisWeek} commits',
                      style: const TextStyle(
                        color: PersonalOSTheme.neonLime,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(track.lessons.length, (lIdx) {
                  final lesson = track.lessons[lIdx];
                  return InkWell(
                    onTap: () => controller.toggleSkillLesson(track.id, lIdx),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Icon(
                            lesson.isCompleted
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: lesson.isCompleted
                                ? PersonalOSTheme.neonLime
                                : PersonalOSTheme.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title,
                                  style: TextStyle(
                                    color: PersonalOSTheme.textPrimary,
                                    fontSize: 13,
                                    decoration: lesson.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  'Project step: ${lesson.deliverableHint}',
                                  style: const TextStyle(
                                    color: PersonalOSTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }
}
