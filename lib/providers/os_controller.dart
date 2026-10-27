import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/os_models.dart';
import '../theme/os_theme.dart';

class PersonalOSController extends ChangeNotifier {
  // User Profile & Discipline State
  String userName = 'Alex';
  int focusMinutesToday = 95;
  int targetFocusMinutes = 180;
  int distractionCountToday = 2;
  int consumptionMinutesToday = 15; // From screenshot 2 ("Used for 15m")
  int creationMinutesToday = 85;
  bool isCreatorLockActive = true; // Separates creating from endlessly watching

  // Pomodoro Timer State
  int remainingSeconds = 25 * 60;
  bool isTimerRunning = false;
  Timer? _focusTimer;

  // 1. College & Studies State
  List<CourseSubject> subjects = [];
  List<AcademicAssignment> assignments = [];

  // 2. Fitness & Health State
  double currentWeightKg = 64.5;
  double targetWeightKg = 70.0; // Lean muscle gain target
  double sleepHoursLastNight = 7.5;
  int stepsToday = 7125;
  int targetSteps = 8000;
  int selectedSplitIndex = 0;
  List<double> weeklyWeightHistory = [63.8, 64.0, 64.1, 64.2, 64.4, 64.3, 64.5];
  List<WorkoutSplitDay> workoutSplits = [];
  List<MealLog> dailyMeals = [];

  // 3. Content Creation State
  List<ContentProject> contentProjects = [];
  List<int> weeklyReelViews = [42000, 68000, 91000, 54000, 88000, 61000, 68206];

  // 4. Skills & Projects State
  List<SkillTrack> skillTracks = [];

  // 5. Income & Opportunities State
  double monthlyIncomeGoal = 25000.0; // In INR or USD (configurable)
  String currencySymbol = '₹';
  List<OpportunityLead> leads = [];
  List<FinancialTransaction> transactions = [];

  // 6. Personal Discipline State
  List<DailyHabit> habits = [];
  List<PlanFailureDiagnostic> diagnostics = [];

  PersonalOSController() {
    _seedInitialData();
    _loadFromLocalDevice();
  }

  // ==========================================================================
  // COMPUTED METRICS ACROSS THE OS
  // ==========================================================================

  /// Overall Daily OS Completion (0.0 to 1.0) shown in the Hero Ring
  double get overallOSCompletion {
    final habitScore = habits.isEmpty
        ? 0.0
        : habits.where((h) => h.completedToday).length / habits.length;
    final workoutScore = workoutSplits.isEmpty
        ? 0.0
        : workoutSplits[selectedSplitIndex].completionRatio;
    final focusScore =
        (focusMinutesToday / targetFocusMinutes).clamp(0.0, 1.0);
    final taskScore = assignments.isEmpty
        ? 1.0
        : assignments.where((a) => a.isCompleted).length / assignments.length;

    return ((habitScore * 0.35) +
            (workoutScore * 0.25) +
            (focusScore * 0.25) +
            (taskScore * 0.15))
        .clamp(0.0, 1.0);
  }

  /// Sorted subjects by urgency (Low attendance or approaching exam first)
  List<CourseSubject> get prioritizedSubjects {
    final copy = List<CourseSubject>.from(subjects);
    copy.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));
    return copy;
  }

  /// Top urgent academic alert banner message
  CourseSubject? get topUrgentSubject =>
      prioritizedSubjects.isNotEmpty ? prioritizedSubjects.first : null;

  int get totalCaloriesConsumed => dailyMeals
      .where((m) => m.isEaten)
      .fold(0, (sum, item) => sum + item.calories);

  int get totalProteinConsumed => dailyMeals
      .where((m) => m.isEaten)
      .fold(0, (sum, item) => sum + item.proteinGrams);

  int get targetCalories => 2650; // Lean bulk caloric surplus
  int get targetProteinGrams => 140;

  double get totalEarnings => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpenses => transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get netSavings => totalEarnings - totalExpenses;

  int get totalReelViewsLast7Days =>
      weeklyReelViews.fold(0, (sum, v) => sum + v);

  // ==========================================================================
  // MUTATION ACTIONS & LOGIC
  // ==========================================================================

  void markAttendance(String subjectId, {required bool attended}) {
    final idx = subjects.indexWhere((s) => s.id == subjectId);
    if (idx == -1) return;
    subjects[idx].totalClasses += 1;
    if (attended) {
      subjects[idx].attendedClasses += 1;
    }
    _saveToLocalDevice();
    notifyListeners();
  }

  void toggleRevisionTopic(String subjectId, String topic) {
    final idx = subjects.indexWhere((s) => s.id == subjectId);
    if (idx == -1) return;
    if (subjects[idx].completedTopics.contains(topic)) {
      subjects[idx].completedTopics.remove(topic);
    } else {
      subjects[idx].completedTopics.add(topic);
    }
    _saveToLocalDevice();
    notifyListeners();
  }

  void toggleAssignment(String assignmentId) {
    final idx = assignments.indexWhere((a) => a.id == assignmentId);
    if (idx == -1) return;
    assignments[idx].isCompleted = !assignments[idx].isCompleted;
    _saveToLocalDevice();
    notifyListeners();
  }

  void addAssignment({
    required String title,
    required String courseCode,
    required String category,
    required String priority,
    required int daysFromNow,
  }) {
    assignments.insert(
      0,
      AcademicAssignment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        courseCode: courseCode,
        dueDate: DateTime.now().add(Duration(days: daysFromNow)),
        category: category,
        priority: priority,
      ),
    );
    _saveToLocalDevice();
    notifyListeners();
  }

  void selectWorkoutSplit(int index) {
    selectedSplitIndex = index;
    notifyListeners();
  }

  void toggleExercise(int splitIndex, int exerciseIndex) {
    final item = workoutSplits[splitIndex].exercises[exerciseIndex];
    item.isDone = !item.isDone;
    _saveToLocalDevice();
    notifyListeners();
  }

  void toggleMeal(String mealId) {
    final idx = dailyMeals.indexWhere((m) => m.id == mealId);
    if (idx == -1) return;
    dailyMeals[idx].isEaten = !dailyMeals[idx].isEaten;
    _saveToLocalDevice();
    notifyListeners();
  }

  void updateBodyWeight(double delta) {
    currentWeightKg =
        double.parse((currentWeightKg + delta).toStringAsFixed(1));
    if (weeklyWeightHistory.isNotEmpty) {
      weeklyWeightHistory[weeklyWeightHistory.length - 1] = currentWeightKg;
    }
    _saveToLocalDevice();
    notifyListeners();
  }

  void updateSleepHours(double delta) {
    sleepHoursLastNight =
        (sleepHoursLastNight + delta).clamp(3.0, 12.0);
    _saveToLocalDevice();
    notifyListeners();
  }

  void toggleCreatorLock() {
    isCreatorLockActive = !isCreatorLockActive;
    _saveToLocalDevice();
    notifyListeners();
  }

  void advanceContentStage(String contentId) {
    const stages = ['Idea', 'Scripting', 'Editing', 'Scheduled', 'Published'];
    final idx = contentProjects.indexWhere((c) => c.id == contentId);
    if (idx == -1) return;
    final currentIdx = stages.indexOf(contentProjects[idx].stage);
    final nextIdx = (currentIdx + 1) % stages.length;
    contentProjects[idx].stage = stages[nextIdx];
    if (stages[nextIdx] == 'Published' && contentProjects[idx].views == 0) {
      contentProjects[idx].views = 12400;
      contentProjects[idx].likes = 940;
      contentProjects[idx].saves = 310;
    }
    _saveToLocalDevice();
    notifyListeners();
  }

  void addContentIdea({
    required String title,
    required String hookScript,
    required String platform,
  }) {
    contentProjects.insert(
      0,
      ContentProject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        hookScript: hookScript,
        platform: platform,
        stage: 'Idea',
        scheduledDate: DateTime.now().add(const Duration(days: 2)),
      ),
    );
    creationMinutesToday += 15;
    _saveToLocalDevice();
    notifyListeners();
  }

  void toggleSkillLesson(String trackId, int lessonIndex) {
    final idx = skillTracks.indexWhere((t) => t.id == trackId);
    if (idx == -1) return;
    final lesson = skillTracks[idx].lessons[lessonIndex];
    lesson.isCompleted = !lesson.isCompleted;
    if (lesson.isCompleted) {
      skillTracks[idx].githubCommitsThisWeek += 1;
    }
    _saveToLocalDevice();
    notifyListeners();
  }

  void addMicroLesson(String trackId, String lessonTitle, String deliverable) {
    final idx = skillTracks.indexWhere((t) => t.id == trackId);
    if (idx == -1) return;
    skillTracks[idx].lessons.add(
          MicroLesson(
            title: lessonTitle,
            deliverableHint: deliverable,
          ),
        );
    _saveToLocalDevice();
    notifyListeners();
  }

  void advanceLeadStatus(String leadId) {
    const statuses = ['Outreach Sent', 'In Call', 'Active Gig', 'Paid'];
    final idx = leads.indexWhere((l) => l.id == leadId);
    if (idx == -1) return;
    final currentIdx = statuses.indexOf(leads[idx].status);
    final nextIdx = (currentIdx + 1) % statuses.length;
    leads[idx].status = statuses[nextIdx];

    if (statuses[nextIdx] == 'Paid') {
      transactions.insert(
        0,
        FinancialTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: leads[idx].clientOrSource,
          subtitle: leads[idx].serviceType,
          amount: leads[idx].potentialAmount,
          isIncome: true,
          date: DateTime.now(),
        ),
      );
    }
    _saveToLocalDevice();
    notifyListeners();
  }

  void addFinancialEntry({
    required String title,
    required String subtitle,
    required double amount,
    required bool isIncome,
  }) {
    transactions.insert(
      0,
      FinancialTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        subtitle: subtitle,
        amount: amount,
        isIncome: isIncome,
        date: DateTime.now(),
      ),
    );
    _saveToLocalDevice();
    notifyListeners();
  }

  void toggleHabit(String habitId) {
    final idx = habits.indexWhere((h) => h.id == habitId);
    if (idx == -1) return;
    habits[idx].completedToday = !habits[idx].completedToday;
    habits[idx].streakDays += habits[idx].completedToday ? 1 : -1;
    if (habits[idx].streakDays < 0) habits[idx].streakDays = 0;
    _saveToLocalDevice();
    notifyListeners();
  }

  void logDistractionImpulse() {
    distractionCountToday += 1;
    _saveToLocalDevice();
    notifyListeners();
  }

  /// Understands WHY a plan failed and automatically shrinks/adjusts the goal
  /// instead of abandoning it.
  void diagnoseAndAdaptFailedPlan({
    required String taskTitle,
    required String rootCause,
  }) {
    String adjustment;
    switch (rootCause) {
      case 'Overwhelmed / Too Big':
        adjustment =
            'Split "$taskTitle" into a 15-minute starter micro-step for today.';
        break;
      case 'Phone Distraction':
        adjustment =
            'Enabled Creator Lock & scheduled "$taskTitle" into a 25m offline sprint.';
        isCreatorLockActive = true;
        break;
      case 'Low Energy / Poor Sleep':
        adjustment =
            'Moved heavy cognitive work to tomorrow morning; swapped in light review now.';
        break;
      default:
        adjustment =
            'Defined exact first file/action for "$taskTitle" so zero friction remains.';
    }

    diagnostics.insert(
      0,
      PlanFailureDiagnostic(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        unfinishedTaskTitle: taskTitle,
        rootCause: rootCause,
        adaptiveAdjustment: adjustment,
        loggedAt: DateTime.now(),
      ),
    );
    _saveToLocalDevice();
    notifyListeners();
  }

  // Pomodoro Focus Session Engine
  void toggleFocusTimer() {
    if (isTimerRunning) {
      _focusTimer?.cancel();
      isTimerRunning = false;
    } else {
      isTimerRunning = true;
      _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds > 0) {
          remainingSeconds--;
          if (remainingSeconds % 60 == 0) {
            focusMinutesToday += 1;
          }
          notifyListeners();
        } else {
          timer.cancel();
          isTimerRunning = false;
          focusMinutesToday += 25;
          remainingSeconds = 25 * 60;
          _saveToLocalDevice();
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void resetFocusTimer({int minutes = 25}) {
    _focusTimer?.cancel();
    isTimerRunning = false;
    remainingSeconds = minutes * 60;
    notifyListeners();
  }

  // ==========================================================================
  // LOCAL PERSISTENCE ON PHONE (Zero-config JSON file in system temp/app dir)
  // ==========================================================================

  Future<File?> _getLocalStoreFile() async {
    if (kIsWeb) return null;
    try {
      final dir = Directory.systemTemp;
      return File('${dir.path}/personal_os_local_state_v1.json');
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToLocalDevice() async {
    final file = await _getLocalStoreFile();
    if (file == null) return;
    try {
      final payload = jsonEncode({
        'userName': userName,
        'focusMinutesToday': focusMinutesToday,
        'distractionCountToday': distractionCountToday,
        'consumptionMinutesToday': consumptionMinutesToday,
        'creationMinutesToday': creationMinutesToday,
        'isCreatorLockActive': isCreatorLockActive,
        'currentWeightKg': currentWeightKg,
        'sleepHoursLastNight': sleepHoursLastNight,
        'subjects': subjects.map((s) => s.toJson()).toList(),
        'assignments': assignments.map((a) => a.toJson()).toList(),
        'workoutSplits': workoutSplits.map((w) => w.toJson()).toList(),
        'dailyMeals': dailyMeals.map((m) => m.toJson()).toList(),
        'contentProjects': contentProjects.map((c) => c.toJson()).toList(),
        'skillTracks': skillTracks.map((s) => s.toJson()).toList(),
        'leads': leads.map((l) => l.toJson()).toList(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'habits': habits.map((h) => h.toJson()).toList(),
        'diagnostics': diagnostics.map((d) => d.toJson()).toList(),
      });
      await file.writeAsString(payload);
    } catch (_) {
      // Silently ignore file system restrictions on constrained sandboxes
    }
  }

  Future<void> _loadFromLocalDevice() async {
    final file = await _getLocalStoreFile();
    if (file == null || !await file.exists()) return;
    try {
      final raw = await file.readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      userName = data['userName'] ?? userName;
      focusMinutesToday = data['focusMinutesToday'] ?? focusMinutesToday;
      distractionCountToday =
          data['distractionCountToday'] ?? distractionCountToday;
      consumptionMinutesToday =
          data['consumptionMinutesToday'] ?? consumptionMinutesToday;
      creationMinutesToday =
          data['creationMinutesToday'] ?? creationMinutesToday;
      isCreatorLockActive = data['isCreatorLockActive'] ?? isCreatorLockActive;
      currentWeightKg =
          (data['currentWeightKg'] as num?)?.toDouble() ?? currentWeightKg;
      sleepHoursLastNight =
          (data['sleepHoursLastNight'] as num?)?.toDouble() ??
              sleepHoursLastNight;

      if (data['subjects'] != null) {
        subjects = (data['subjects'] as List)
            .map((e) => CourseSubject.fromJson(e))
            .toList();
      }
      if (data['assignments'] != null) {
        assignments = (data['assignments'] as List)
            .map((e) => AcademicAssignment.fromJson(e))
            .toList();
      }
      if (data['workoutSplits'] != null) {
        workoutSplits = (data['workoutSplits'] as List)
            .map((e) => WorkoutSplitDay.fromJson(e))
            .toList();
      }
      if (data['dailyMeals'] != null) {
        dailyMeals = (data['dailyMeals'] as List)
            .map((e) => MealLog.fromJson(e))
            .toList();
      }
      if (data['contentProjects'] != null) {
        contentProjects = (data['contentProjects'] as List)
            .map((e) => ContentProject.fromJson(e))
            .toList();
      }
      if (data['skillTracks'] != null) {
        skillTracks = (data['skillTracks'] as List)
            .map((e) => SkillTrack.fromJson(e))
            .toList();
      }
      if (data['leads'] != null) {
        leads = (data['leads'] as List)
            .map((e) => OpportunityLead.fromJson(e))
            .toList();
      }
      if (data['transactions'] != null) {
        transactions = (data['transactions'] as List)
            .map((e) => FinancialTransaction.fromJson(e))
            .toList();
      }
      if (data['habits'] != null) {
        habits = (data['habits'] as List)
            .map((e) => DailyHabit.fromJson(e))
            .toList();
      }
      if (data['diagnostics'] != null) {
        diagnostics = (data['diagnostics'] as List)
            .map((e) => PlanFailureDiagnostic.fromJson(e))
            .toList();
      }
      notifyListeners();
    } catch (_) {
      // Fallback to seeded defaults if schema changed
    }
  }

  // ==========================================================================
  // INITIAL SEED DATA (GROUNDED IN USER'S 6 MODULES & SCREENSHOTS)
  // ==========================================================================

  void _seedInitialData() {
    final now = DateTime.now();

    // 1. College & Studies
    subjects = [
      CourseSubject(
        id: 'sub_1',
        name: 'Data Structures & Algorithms',
        code: 'CS301',
        attendedClasses: 19,
        totalClasses: 28, // 67.8% -> Below 75% alert!
        targetAttendance: 0.75,
        nextExamDate: now.add(const Duration(days: 4)),
        currentGradePercent: 87.1,
        accentColor: PersonalOSTheme.coralRed,
        revisionTopics: [
          'Graph BFS & Dijkstra',
          'Dynamic Programming Memoization',
          'AVL Trees & Rotations',
          'Heap Priority Queues',
        ],
        completedTopics: ['Graph BFS & Dijkstra', 'Heap Priority Queues'],
      ),
      CourseSubject(
        id: 'sub_2',
        name: 'Applied Machine Learning & AI',
        code: 'AI402',
        attendedClasses: 24,
        totalClasses: 29, // 82.7%
        targetAttendance: 0.75,
        nextExamDate: now.add(const Duration(days: 6)),
        currentGradePercent: 92.0,
        accentColor: PersonalOSTheme.skyBlue,
        revisionTopics: [
          'Backpropagation & Gradients',
          'Transformer Attention Heads',
          'RAG & Vector Embeddings',
          'LoRA Fine-Tuning',
        ],
        completedTopics: [
          'Backpropagation & Gradients',
          'Transformer Attention Heads',
          'RAG & Vector Embeddings',
        ],
      ),
      CourseSubject(
        id: 'sub_3',
        name: 'Mobile App Architecture',
        code: 'SE204',
        attendedClasses: 26,
        totalClasses: 28, // 92.8%
        targetAttendance: 0.75,
        nextExamDate: now.add(const Duration(days: 15)),
        currentGradePercent: 94.5,
        accentColor: PersonalOSTheme.neonLime,
        revisionTopics: [
          'Flutter Rendering Tree & Element Layer',
          'Local SQLite / Hive Persistence',
          'State Notifier & Clean Architecture',
        ],
        completedTopics: [
          'Flutter Rendering Tree & Element Layer',
          'Local SQLite / Hive Persistence',
        ],
      ),
      CourseSubject(
        id: 'sub_4',
        name: 'Database Management Systems',
        code: 'CS305',
        attendedClasses: 20,
        totalClasses: 27, // 74.0% -> Borderline warning!
        targetAttendance: 0.75,
        nextExamDate: now.add(const Duration(days: 11)),
        currentGradePercent: 84.0,
        accentColor: PersonalOSTheme.amberWarning,
        revisionTopics: [
          'BCNF & 3NF Normalization',
          'ACID & MVCC Concurrency',
          'B+ Tree Indexing',
        ],
        completedTopics: ['BCNF & 3NF Normalization'],
      ),
    ];

    assignments = [
      AcademicAssignment(
        id: 'as_1',
        title: 'Lab Report: Graph Shortest Path Benchmark',
        courseCode: 'CS301',
        dueDate: now.subtract(const Duration(hours: 5)), // Past Due alert
        category: 'Lab Reports',
        priority: 'High',
        isCompleted: false,
      ),
      AcademicAssignment(
        id: 'as_2',
        title: 'Build Personal OS Flutter Prototype',
        courseCode: 'SE204',
        dueDate: now.add(const Duration(hours: 8)), // Due Today
        category: 'Projects',
        priority: 'High',
        isCompleted: false,
      ),
      AcademicAssignment(
        id: 'as_3',
        title: 'Reading Check: Transformer Self-Attention Paper',
        courseCode: 'AI402',
        dueDate: now.add(const Duration(days: 1)),
        category: 'Reading Checks',
        priority: 'Medium',
        isCompleted: false,
      ),
      AcademicAssignment(
        id: 'as_4',
        title: 'SQL Indexing & Query Planner Lab',
        courseCode: 'CS305',
        dueDate: now.add(const Duration(days: 3)),
        category: 'Labs',
        priority: 'Medium',
        isCompleted: true,
      ),
    ];

    // 2. Fitness & Health Habits (Muscle Hypertrophy Focus)
    workoutSplits = [
      WorkoutSplitDay(
        dayName: 'Push Day (Chest, Shoulders, Triceps)',
        focusMuscle: 'Progressive Overload • Upper Push',
        exercises: [
          ExerciseItem(
            name: 'Incline Dumbbell Press',
            targetSetsReps: '4 sets × 8–10 reps • 24 kg',
            estimatedCalories: 240,
            isDone: true,
          ),
          ExerciseItem(
            name: 'Overhead Barbell Press',
            targetSetsReps: '3 sets × 8 reps • 40 kg',
            estimatedCalories: 210,
            isDone: true,
          ),
          ExerciseItem(
            name: 'Cable Lateral Raises',
            targetSetsReps: '4 sets × 15 reps • 10 kg',
            estimatedCalories: 160,
            isDone: true,
          ),
          ExerciseItem(
            name: 'Rope Tricep Pushdowns + Dips',
            targetSetsReps: '3 sets × 12 reps • 25 kg',
            estimatedCalories: 190,
            isDone: false,
          ),
        ],
      ),
      WorkoutSplitDay(
        dayName: 'Pull Day (Back Width, Rear Delts, Biceps)',
        focusMuscle: 'Hypertrophy V-Taper • Upper Pull',
        exercises: [
          ExerciseItem(
            name: 'Weighted Pull-Ups / Lat Pulldown',
            targetSetsReps: '4 sets × 8–10 reps • 65 kg',
            estimatedCalories: 260,
            isDone: false,
          ),
          ExerciseItem(
            name: 'Chest-Supported Barbell Row',
            targetSetsReps: '4 sets × 10 reps • 55 kg',
            estimatedCalories: 230,
            isDone: false,
          ),
          ExerciseItem(
            name: 'Face Pulls & Rear Delt Flyes',
            targetSetsReps: '3 sets × 15 reps • 20 kg',
            estimatedCalories: 140,
            isDone: false,
          ),
          ExerciseItem(
            name: 'Incline Dumbbell Hammer Curls',
            targetSetsReps: '3 sets × 12 reps • 14 kg',
            estimatedCalories: 150,
            isDone: false,
          ),
        ],
      ),
      WorkoutSplitDay(
        dayName: 'Legs & Core (Quads, Hamstrings, Calves)',
        focusMuscle: 'Lower Body Strength & Stability',
        exercises: [
          ExerciseItem(
            name: 'Barbell Back Squat',
            targetSetsReps: '4 sets × 6–8 reps • 85 kg',
            estimatedCalories: 310,
            isDone: false,
          ),
          ExerciseItem(
            name: 'Romanian Deadlifts (RDL)',
            targetSetsReps: '4 sets × 10 reps • 75 kg',
            estimatedCalories: 280,
            isDone: false,
          ),
          ExerciseItem(
            name: 'Bulgarian Split Squats',
            targetSetsReps: '3 sets × 10/leg • 18 kg',
            estimatedCalories: 210,
            isDone: false,
          ),
          ExerciseItem(
            name: 'Hanging Leg Raises & Calf Press',
            targetSetsReps: '4 sets × 15 reps',
            estimatedCalories: 160,
            isDone: false,
          ),
        ],
      ),
    ];

    dailyMeals = [
      MealLog(
        id: 'm_1',
        name: 'Oats, Whey Scoop, Peanut Butter & Banana',
        calories: 680,
        proteinGrams: 42,
        timeLabel: '8:30 AM • Pre-Class Fuel',
        isEaten: true,
      ),
      MealLog(
        id: 'm_2',
        name: 'Chicken Breast / Paneer Rice Bowl + Curd',
        calories: 790,
        proteinGrams: 48,
        timeLabel: '1:30 PM • Campus Lunch',
        isEaten: true,
      ),
      MealLog(
        id: 'm_3',
        name: '4 Whole Eggs + Sourdough Toast (Post-Workout)',
        calories: 520,
        proteinGrams: 30,
        timeLabel: '6:30 PM • Recovery',
        isEaten: false,
      ),
      MealLog(
        id: 'm_4',
        name: 'Dal Tadka, 3 Rotis & Grilled Soya/Tofu',
        calories: 640,
        proteinGrams: 28,
        timeLabel: '9:15 PM • Dinner',
        isEaten: false,
      ),
    ];

    // 3. Content Creation
    contentProjects = [
      ContentProject(
        id: 'cp_1',
        title: 'How I Built My Personal OS in Flutter at 20',
        hookScript:
            'HOOK (0-3s): "Stop using 7 different apps to run your college life..." Show dark mode dashboard ring.',
        platform: 'Instagram Reels',
        stage: 'Editing',
        scheduledDate: now.add(const Duration(days: 1)),
        views: 0,
        likes: 0,
        saves: 0,
      ),
      ContentProject(
        id: 'cp_2',
        title: '3 Free AI Agents That Save Me 10 Hours Studying',
        hookScript:
            'HOOK (0-3s): "If you are still manually summarizing 80-page PDFs before finals, watch this..."',
        platform: 'Instagram Reels',
        stage: 'Scripting',
        scheduledDate: now.add(const Duration(days: 3)),
        views: 0,
        likes: 0,
        saves: 0,
      ),
      ContentProject(
        id: 'cp_3',
        title: 'Day in the Life: CS Student + Gym + Freelance',
        hookScript:
            'Fast-paced 0.5s cuts: 6AM oats -> 9AM DSA lecture -> 5PM incline press -> 9PM client edit.',
        platform: 'YouTube Shorts',
        stage: 'Published',
        scheduledDate: now.subtract(const Duration(days: 2)),
        views: 82700,
        likes: 6420,
        saves: 2150,
      ),
      ContentProject(
        id: 'cp_4',
        title: 'GitHub Portfolio Tricks That Get Internships',
        hookScript:
            'Show pinned repos + custom README stats + real live deployment links.',
        platform: 'Instagram Reels',
        stage: 'Published',
        scheduledDate: now.subtract(const Duration(days: 5)),
        views: 49200,
        likes: 3810,
        saves: 1890,
      ),
    ];

    // 4. Skills & Projects
    skillTracks = [
      SkillTrack(
        id: 'sk_1',
        name: 'AI & LLM Engineering',
        categoryIcon: 'auto_awesome',
        activeMilestoneProject: 'Local Study RAG Chatbot with Gemini API',
        githubCommitsThisWeek: 9,
        accentColor: PersonalOSTheme.primaryPurple,
        lessons: [
          MicroLesson(
            title: 'Prompt Engineering & Structured JSON Output',
            isCompleted: true,
            deliverableHint: 'Built assignment parser schema',
          ),
          MicroLesson(
            title: 'Vector Embeddings & Semantic Chunking',
            isCompleted: true,
            deliverableHint: 'Indexed 4 course syllabus PDFs',
          ),
          MicroLesson(
            title: 'Function Calling & Agent Tool Routing',
            isCompleted: false,
            deliverableHint: 'Connect timetable auto-scheduler tool',
          ),
          MicroLesson(
            title: 'Deploy AI Microservice on Free Tier',
            isCompleted: false,
            deliverableHint: 'Ship live endpoint for mobile app',
          ),
        ],
      ),
      SkillTrack(
        id: 'sk_2',
        name: 'Flutter & App Dev',
        categoryIcon: 'phone_iphone',
        activeMilestoneProject: 'Personal OS Offline-First Mobile App',
        githubCommitsThisWeek: 14,
        accentColor: PersonalOSTheme.neonLime,
        lessons: [
          MicroLesson(
            title: 'CustomPainter Radial Rings & Dark UI Theme',
            isCompleted: true,
            deliverableHint: 'Created 78% OS completion gauge',
          ),
          MicroLesson(
            title: 'ChangeNotifier State & Local JSON Persistence',
            isCompleted: true,
            deliverableHint: 'Zero-latency offline save on phone',
          ),
          MicroLesson(
            title: 'Interactive Charts & Attendance Calculator',
            isCompleted: true,
            deliverableHint: 'Built 75% attendance recovery engine',
          ),
          MicroLesson(
            title: 'Build Release APK & Install on Device',
            isCompleted: false,
            deliverableHint: 'Run flutter build apk --release',
          ),
        ],
      ),
      SkillTrack(
        id: 'sk_3',
        name: 'Coding, DSA & GitHub',
        categoryIcon: 'terminal',
        activeMilestoneProject: '150 LeetCode Patterns + Open Source PRs',
        githubCommitsThisWeek: 11,
        accentColor: PersonalOSTheme.skyBlue,
        lessons: [
          MicroLesson(
            title: 'Sliding Window & Two Pointers (15 problems)',
            isCompleted: true,
            deliverableHint: 'Pushed clean Dart/C++ solutions to GitHub',
          ),
          MicroLesson(
            title: 'Trees, Tries & Graph Traversals',
            isCompleted: true,
            deliverableHint: 'Implemented visual BFS pathfinder',
          ),
          MicroLesson(
            title: 'Dynamic Programming 1D & 2D Grids',
            isCompleted: false,
            deliverableHint: 'Solve 5 knapsack & subsequence problems',
          ),
        ],
      ),
      SkillTrack(
        id: 'sk_4',
        name: 'Short-Form Video Editing',
        categoryIcon: 'movie_filter',
        activeMilestoneProject: 'High-Retention Reel Template Pack',
        githubCommitsThisWeek: 4,
        accentColor: PersonalOSTheme.amberWarning,
        lessons: [
          MicroLesson(
            title: 'J-Cuts, L-Cuts & 3-Second Visual Hooks',
            isCompleted: true,
            deliverableHint: 'Boosted 3s retention above 72%',
          ),
          MicroLesson(
            title: 'Dynamic Captions & Sound Design Layering',
            isCompleted: true,
            deliverableHint: 'Saved custom SFX preset folder',
          ),
          MicroLesson(
            title: 'Color Grading Log Footage & Export Presets',
            isCompleted: false,
            deliverableHint: 'Create 60fps crisp dark-aesthetic LUT',
          ),
        ],
      ),
    ];

    // 5. Income & Opportunities (Low-cost student side income)
    leads = [
      OpportunityLead(
        id: 'ld_1',
        clientOrSource: 'Samantha Johnson (Creator Agency)',
        serviceType: '4 Reels/Week Video Editing Retainer',
        status: 'Active Gig',
        potentialAmount: 12000,
        isLowCostStudentFriendly: true,
      ),
      OpportunityLead(
        id: 'ld_2',
        clientOrSource: 'Campus Startup Founder',
        serviceType: 'Flutter MVP UI Prototype (3 Screens)',
        status: 'In Call',
        potentialAmount: 8500,
        isLowCostStudentFriendly: true,
      ),
      OpportunityLead(
        id: 'ld_3',
        clientOrSource: 'Tech Gear & Coding Setup Link-in-Bio',
        serviceType: 'Affiliate Experiment (Zero Ad Spend)',
        status: 'Active Gig',
        potentialAmount: 3200,
        isLowCostStudentFriendly: true,
      ),
      OpportunityLead(
        id: 'ld_4',
        clientOrSource: 'Local Fitness Coach DM Outreach',
        serviceType: 'Short-Form Reel Script + Edit Trial',
        status: 'Outreach Sent',
        potentialAmount: 6000,
        isLowCostStudentFriendly: true,
      ),
    ];

    transactions = [
      FinancialTransaction(
        id: 'tx_1',
        title: 'Samantha Johnson • Retainer Milestone',
        subtitle: 'Freelance Video Editing (Zero capital)',
        amount: 9000,
        isIncome: true,
        date: now.subtract(const Duration(days: 3)),
      ),
      FinancialTransaction(
        id: 'tx_2',
        title: 'UI Component Template & Affiliate Payout',
        subtitle: 'Digital Product / Affiliate Experiment',
        amount: 4050,
        isIncome: true,
        date: now.subtract(const Duration(days: 6)),
      ),
      FinancialTransaction(
        id: 'tx_3',
        title: 'Whey Isolate & Gym Membership',
        subtitle: 'Health & Muscle Routine Investment',
        amount: 2400,
        isIncome: false,
        date: now.subtract(const Duration(days: 4)),
      ),
      FinancialTransaction(
        id: 'tx_4',
        title: 'Cloud Domain & API Credits',
        subtitle: 'Low-cost Student Dev Tooling',
        amount: 650,
        isIncome: false,
        date: now.subtract(const Duration(days: 7)),
      ),
    ];

    // 6. Personal Discipline Habits & Failure Diagnostics
    habits = [
      DailyHabit(
        id: 'hb_1',
        title: 'Attend all morning lectures (Protect >75%)',
        pillar: 'Studies',
        streakDays: 6,
        completedToday: true,
      ),
      DailyHabit(
        id: 'hb_2',
        title: 'Hit 140g protein + Progressive Overload Lift',
        pillar: 'Fitness',
        streakDays: 11,
        completedToday: true,
      ),
      DailyHabit(
        id: 'hb_3',
        title: '30m Script/Edit BEFORE opening Reels feed',
        pillar: 'Content',
        streakDays: 4,
        completedToday: true,
      ),
      DailyHabit(
        id: 'hb_4',
        title: '1 GitHub commit or 1 DSA problem solved',
        pillar: 'Skills',
        streakDays: 9,
        completedToday: false,
      ),
      DailyHabit(
        id: 'hb_5',
        title: 'Send 2 cold outreach DMs / follow-ups',
        pillar: 'Income',
        streakDays: 3,
        completedToday: false,
      ),
    ];

    diagnostics = [
      PlanFailureDiagnostic(
        id: 'dg_1',
        unfinishedTaskTitle: 'Dynamic Programming Revision (CS301)',
        rootCause: 'Overwhelmed / Too Big',
        adaptiveAdjustment:
            'Shrunk 3-hour study block into a 20-minute 1D memoization warm-up so momentum isn\'t lost.',
        loggedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
