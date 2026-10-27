import 'package:flutter/material.dart';
import '../providers/os_controller.dart';
import '../theme/os_theme.dart';
import '../widgets/os_widgets.dart';

class FitnessScreen extends StatelessWidget {
  final PersonalOSController controller;

  const FitnessScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final activeSplit = controller.workoutSplits[controller.selectedSplitIndex];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      children: [
        // Top Header (Matches Screenshot 2: "Start your workout today!")
        const Text(
          'Start your\nworkout today! 💪',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: PersonalOSTheme.textPrimary,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Daily Muscle-Building Split • Progressive Overload Routine',
          style: TextStyle(
            fontSize: 12,
            color: PersonalOSTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        // Split Selector Chips (Push / Pull / Legs)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(controller.workoutSplits.length, (idx) {
              final split = controller.workoutSplits[idx];
              final isSelected = idx == controller.selectedSplitIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(split.dayName.split(' (').first),
                  selected: isSelected,
                  selectedColor: PersonalOSTheme.primaryPurple,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : PersonalOSTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => controller.selectWorkoutSplit(idx),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),

        // Vibrant Purple Workout Card (Matches Screenshot 2 left phone hero card)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF6D28D9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: PersonalOSTheme.primaryPurple.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fitness_center,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${activeSplit.burnedCalories} cal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    ' / ${activeSplit.totalCalories} cal target',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                activeSplit.dayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(activeSplit.exercises.length, (exIdx) {
                final ex = activeSplit.exercises[exIdx];
                return InkWell(
                  onTap: () => controller.toggleExercise(
                      controller.selectedSplitIndex, exIdx),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          ex.isDone
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: ex.isDone
                              ? PersonalOSTheme.neonLime
                              : Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ex.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: ex.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        Text(
                          ex.targetSetsReps,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Current Weight & Weekly Pill Bar Chart (Matches Screenshot 2 right phone)
        const SectionHeader(title: 'Body Weight & Hypertrophy Trend'),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: PersonalOSTheme.surfaceCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: PersonalOSTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Weight (Lean Bulk)',
                        style: TextStyle(
                          color: PersonalOSTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.currentWeightKg} kg',
                        style: const TextStyle(
                          color: PersonalOSTheme.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => controller.updateBodyWeight(-0.2),
                        icon: const Icon(Icons.remove_circle_outline,
                            color: PersonalOSTheme.textSecondary),
                      ),
                      IconButton(
                        onPressed: () => controller.updateBodyWeight(0.2),
                        icon: const Icon(Icons.add_circle_outline,
                            color: PersonalOSTheme.neonLime),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                      controller.weeklyWeightHistory.length, (i) {
                    final w = controller.weeklyWeightHistory[i];
                    final normalized = ((w - 60.0) / 8.0).clamp(0.25, 1.0);
                    final isToday =
                        i == controller.weeklyWeightHistory.length - 1;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          w.toStringAsFixed(1),
                          style: TextStyle(
                            color: isToday
                                ? PersonalOSTheme.neonLime
                                : PersonalOSTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 28,
                          height: 75 * normalized,
                          decoration: BoxDecoration(
                            color: isToday
                                ? PersonalOSTheme.primaryPurple
                                : PersonalOSTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
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
        const SizedBox(height: 18),

        // Overall Status Cards: Protein, Calories & Sleep Recovery
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PersonalOSTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PersonalOSTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Protein Intake',
                      style: TextStyle(
                        color: PersonalOSTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${controller.totalProteinConsumed}g / ${controller.targetProteinGrams}g',
                      style: const TextStyle(
                        color: PersonalOSTheme.neonLime,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: (controller.totalProteinConsumed /
                              controller.targetProteinGrams)
                          .clamp(0.0, 1.0),
                      backgroundColor: PersonalOSTheme.surfaceElevated,
                      color: PersonalOSTheme.neonLime,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PersonalOSTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PersonalOSTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sleep & Recovery',
                      style: TextStyle(
                        color: PersonalOSTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${controller.sleepHoursLastNight.toStringAsFixed(1)} hrs',
                          style: const TextStyle(
                            color: PersonalOSTheme.skyBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => controller.updateSleepHours(-0.5),
                              child: const Icon(Icons.remove,
                                  size: 18,
                                  color: PersonalOSTheme.textSecondary),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => controller.updateSleepHours(0.5),
                              child: const Icon(Icons.add,
                                  size: 18, color: PersonalOSTheme.skyBlue),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: (controller.sleepHoursLastNight / 8.0)
                          .clamp(0.0, 1.0),
                      backgroundColor: PersonalOSTheme.surfaceElevated,
                      color: PersonalOSTheme.skyBlue,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Daily Muscle-Building Meals Checklist
        SectionHeader(
          title:
              'Muscle Nutrition (${controller.totalCaloriesConsumed}/${controller.targetCalories} kcal)',
        ),
        ...controller.dailyMeals.map((meal) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: PersonalOSTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PersonalOSTheme.borderSubtle),
            ),
            child: ListTile(
              onTap: () => controller.toggleMeal(meal.id),
              leading: Icon(
                meal.isEaten
                    ? Icons.check_circle_rounded
                    : Icons.restaurant_menu_rounded,
                color: meal.isEaten
                    ? PersonalOSTheme.neonLime
                    : PersonalOSTheme.primaryPurple,
              ),
              title: Text(
                meal.name,
                style: TextStyle(
                  color: PersonalOSTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: meal.isEaten ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                meal.timeLabel,
                style: const TextStyle(
                  color: PersonalOSTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${meal.proteinGrams}g Protein',
                    style: const TextStyle(
                      color: PersonalOSTheme.neonLime,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${meal.calories} kcal',
                    style: const TextStyle(
                      color: PersonalOSTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
