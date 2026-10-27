import 'package:flutter/material.dart';
import '../providers/os_controller.dart';
import '../theme/os_theme.dart';
import '../widgets/os_widgets.dart';

class ContentScreen extends StatelessWidget {
  final PersonalOSController controller;

  const ContentScreen({super.key, required this.controller});

  void _showAddReelModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final hookCtrl = TextEditingController();
    String platform = 'Instagram Reels';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PersonalOSTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
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
                'New Reel Idea & 3-Second Hook',
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
                  labelText: 'Reel Concept / Working Title',
                  filled: true,
                  fillColor: PersonalOSTheme.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hookCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Spoken Hook + Visual Action (First 3 Seconds)',
                  filled: true,
                  fillColor: PersonalOSTheme.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                    if (titleCtrl.text.trim().isNotEmpty) {
                      controller.addContentIdea(
                        title: titleCtrl.text.trim(),
                        hookScript: hookCtrl.text.trim().isEmpty
                            ? 'Hook: Show transformation result in first 2 seconds.'
                            : hookCtrl.text.trim(),
                        platform: platform,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  icon: const Icon(Icons.videocam_rounded),
                  label: const Text(
                    'Add to Creation Pipeline',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxViews = controller.weeklyReelViews
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      children: [
        // Top Header + Anti-Doomscroll Pill (Matches Screenshot 2 top pill "Used for 15m" & Screenshot 4 "Insights")
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creator Studio',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: PersonalOSTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Create Before You Consume • Reels & Shorts',
                  style: TextStyle(
                    fontSize: 12,
                    color: PersonalOSTheme.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: controller.isCreatorLockActive
                    ? PersonalOSTheme.primaryPurple.withOpacity(0.22)
                    : PersonalOSTheme.coralRed.withOpacity(0.22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: controller.isCreatorLockActive
                      ? PersonalOSTheme.primaryPurple
                      : PersonalOSTheme.coralRed,
                ),
              ),
              child: InkWell(
                onTap: controller.toggleCreatorLock,
                child: Row(
                  children: [
                    Icon(
                      controller.isCreatorLockActive
                          ? Icons.lock_clock_rounded
                          : Icons.lock_open_rounded,
                      size: 15,
                      color: PersonalOSTheme.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Feed: ${controller.consumptionMinutesToday}m / 15m',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: PersonalOSTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Creation vs Consumption Guardrail Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PersonalOSTheme.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PersonalOSTheme.borderSubtle),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_moon_rounded,
                  color: PersonalOSTheme.neonLime, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creator Ratio: ${controller.creationMinutesToday}m Creating vs ${controller.consumptionMinutesToday}m Scrolling',
                      style: const TextStyle(
                        color: PersonalOSTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Anti-doomscroll rule active: Script or edit 1 reel before opening social feeds.',
                      style: TextStyle(
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
        const SizedBox(height: 18),

        // Insights & Weekly Reel Reach (Matches Screenshot 4 left screen: 472,206 views + bar chart)
        const SectionHeader(title: 'Account Insights (Last 7 Days)'),
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
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PersonalOSTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reels Views',
                            style: TextStyle(
                              color: PersonalOSTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${controller.totalReelViewsLast7Days}',
                            style: const TextStyle(
                              color: PersonalOSTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PersonalOSTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accounts Reached',
                            style: TextStyle(
                              color: PersonalOSTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '333,127',
                            style: TextStyle(
                              color: PersonalOSTheme.neonLime,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                      controller.weeklyReelViews.length, (i) {
                    final v = controller.weeklyReelViews[i];
                    final h = (v / maxViews) * 65;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 26,
                          height: h,
                          decoration: BoxDecoration(
                            color: i == 2 || i == 4
                                ? PersonalOSTheme.primaryPurple
                                : PersonalOSTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
                          style: const TextStyle(
                            color: PersonalOSTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // NLE Timeline Editor Track Preview (Matches Screenshot 4 right screen)
        const SectionHeader(title: 'Active Timeline Cut • Voiceover & Captions'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PersonalOSTheme.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PersonalOSTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Project: Personal OS Flutter Build Reel (4K • 60fps)',
                    style: TextStyle(
                      color: PersonalOSTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '00:28 / 00:45',
                    style: TextStyle(
                      color: PersonalOSTheme.neonLime,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Multi-track timeline bars matching screenshot 4
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: PersonalOSTheme.skyBlue.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🎥 B-Roll Track: Fast Screen Recording + Desk Overheads',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: PersonalOSTheme.electricViolet.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🎙️ Voiceover Track: High-energy hook + noise gate applied',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: PersonalOSTheme.amberWarning.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💬 Dynamic Captions + Whoosh/Pop SFX Layer',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Content Projects & Scripts Pipeline
        SectionHeader(
          title: 'Reels Pipeline & Scripts (Tap Stage to Advance)',
          actionLabel: 'New Reel Idea',
          onAction: () => _showAddReelModal(context),
        ),
        ...controller.contentProjects.map((project) {
          final isPublished = project.stage == 'Published';
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
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: const TextStyle(
                          color: PersonalOSTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.advanceContentStage(project.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isPublished
                              ? PersonalOSTheme.neonLime.withOpacity(0.2)
                              : PersonalOSTheme.primaryPurple.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${project.stage} ➔',
                          style: TextStyle(
                            color: isPublished
                                ? PersonalOSTheme.neonLime
                                : PersonalOSTheme.primaryPurple,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  project.hookScript,
                  style: const TextStyle(
                    color: PersonalOSTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (isPublished) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          size: 16, color: PersonalOSTheme.neonLime),
                      const SizedBox(width: 4),
                      Text(
                        '${project.views} views • ❤️ ${project.likes} • 🔖 ${project.saves} saves',
                        style: const TextStyle(
                          color: PersonalOSTheme.neonLime,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
