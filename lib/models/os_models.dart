import 'package:flutter/material.dart';

// ============================================================================
// 1. COLLEGE & STUDIES MODELS
// ============================================================================

class CourseSubject {
  final String id;
  String name;
  String code;
  int attendedClasses;
  int totalClasses;
  double targetAttendance; // e.g., 0.75 for 75%
  DateTime? nextExamDate;
  double currentGradePercent;
  Color accentColor;
  List<String> revisionTopics;
  List<String> completedTopics;

  CourseSubject({
    required this.id,
    required this.name,
    required this.code,
    required this.attendedClasses,
    required this.totalClasses,
    this.targetAttendance = 0.75,
    this.nextExamDate,
    this.currentGradePercent = 85.0,
    required this.accentColor,
    required this.revisionTopics,
    required this.completedTopics,
  });

  double get attendanceRatio =>
      totalClasses == 0 ? 1.0 : attendedClasses / totalClasses;

  bool get isAttendanceLow => attendanceRatio < targetAttendance;

  /// Calculates how many consecutive classes must be attended to reach target
  int get classesNeededForTarget {
    if (!isAttendanceLow) return 0;
    // (attended + x) / (total + x) >= target
    // attended + x >= target * total + target * x
    // x * (1 - target) >= target * total - attended
    final needed = ((targetAttendance * totalClasses) - attendedClasses) /
        (1.0 - targetAttendance);
    return needed.ceil().clamp(0, 999);
  }

  /// Calculates how many classes can be safely skipped while staying >= target
  int get safeBunksAvailable {
    if (isAttendanceLow) return 0;
    final bunks = (attendedClasses / targetAttendance) - totalClasses;
    return bunks.floor().clamp(0, 999);
  }

  int get daysUntilExam {
    if (nextExamDate == null) return 999;
    final diff = nextExamDate!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Priority Score (0-100): Higher means needs immediate attention
  double get urgencyScore {
    double score = 0;
    if (isAttendanceLow) {
      score += 45 + ((targetAttendance - attendanceRatio) * 100);
    }
    if (daysUntilExam <= 7) {
      score += 40 - (daysUntilExam * 4);
    } else if (daysUntilExam <= 14) {
      score += 20;
    }
    final revisionProgress = revisionTopics.isEmpty
        ? 1.0
        : completedTopics.length / revisionTopics.length;
    score += (1.0 - revisionProgress) * 15;
    return score.clamp(0.0, 100.0);
  }

  String get urgencyReason {
    if (isAttendanceLow && daysUntilExam <= 7) {
      return 'CRITICAL: Attendance ${(attendanceRatio * 100).toStringAsFixed(0)}% (<75%) & Exam in $daysUntilExam days';
    } else if (isAttendanceLow) {
      return 'Attend next $classesNeededForTarget classes to recover ${(targetAttendance * 100).toInt()}% criteria';
    } else if (daysUntilExam <= 7) {
      return 'Exam in $daysUntilExam days • ${revisionTopics.length - completedTopics.length} topics left';
    } else if (safeBunksAvailable > 0) {
      return 'On track • $safeBunksAvailable safe skips buffer available';
    }
    return 'Steady progress • Keep revising';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'attendedClasses': attendedClasses,
        'totalClasses': totalClasses,
        'targetAttendance': targetAttendance,
        'nextExamDate': nextExamDate?.toIso8601String(),
        'currentGradePercent': currentGradePercent,
        'accentColor': accentColor.value,
        'revisionTopics': revisionTopics,
        'completedTopics': completedTopics,
      };

  factory CourseSubject.fromJson(Map<String, dynamic> json) => CourseSubject(
        id: json['id'],
        name: json['name'],
        code: json['code'],
        attendedClasses: json['attendedClasses'],
        totalClasses: json['totalClasses'],
        targetAttendance: (json['targetAttendance'] as num).toDouble(),
        nextExamDate: json['nextExamDate'] != null
            ? DateTime.tryParse(json['nextExamDate'])
            : null,
        currentGradePercent: (json['currentGradePercent'] as num).toDouble(),
        accentColor: Color(json['accentColor'] as int),
        revisionTopics: List<String>.from(json['revisionTopics'] ?? []),
        completedTopics: List<String>.from(json['completedTopics'] ?? []),
      );
}

class AcademicAssignment {
  final String id;
  String title;
  String courseCode;
  DateTime dueDate;
  String category; // 'Lab Report', 'Assignment', 'Project', 'Presentation'
  String priority; // 'High', 'Medium', 'Low'
  bool isCompleted;

  AcademicAssignment({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.dueDate,
    required this.category,
    this.priority = 'High',
    this.isCompleted = false,
  });

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'courseCode': courseCode,
        'dueDate': dueDate.toIso8601String(),
        'category': category,
        'priority': priority,
        'isCompleted': isCompleted,
      };

  factory AcademicAssignment.fromJson(Map<String, dynamic> json) =>
      AcademicAssignment(
        id: json['id'],
        title: json['title'],
        courseCode: json['courseCode'],
        dueDate: DateTime.parse(json['dueDate']),
        category: json['category'],
        priority: json['priority'] ?? 'High',
        isCompleted: json['isCompleted'] ?? false,
      );
}

// ============================================================================
// 2. FITNESS & HEALTH HABITS MODELS
// ============================================================================

class ExerciseItem {
  String name;
  String targetSetsReps; // e.g. "4x8-10 • 60kg"
  int estimatedCalories;
  bool isDone;

  ExerciseItem({
    required this.name,
    required this.targetSetsReps,
    required this.estimatedCalories,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'targetSetsReps': targetSetsReps,
        'estimatedCalories': estimatedCalories,
        'isDone': isDone,
      };

  factory ExerciseItem.fromJson(Map<String, dynamic> json) => ExerciseItem(
        name: json['name'],
        targetSetsReps: json['targetSetsReps'],
        estimatedCalories: json['estimatedCalories'],
        isDone: json['isDone'] ?? false,
      );
}

class WorkoutSplitDay {
  final String dayName; // 'Push Hypertrophy', 'Pull Strength', 'Legs & Core'
  final String focusMuscle;
  List<ExerciseItem> exercises;

  WorkoutSplitDay({
    required this.dayName,
    required this.focusMuscle,
    required this.exercises,
  });

  int get totalCalories =>
      exercises.fold(0, (sum, item) => sum + item.estimatedCalories);

  int get burnedCalories => exercises
      .where((e) => e.isDone)
      .fold(0, (sum, item) => sum + item.estimatedCalories);

  double get completionRatio => exercises.isEmpty
      ? 0.0
      : exercises.where((e) => e.isDone).length / exercises.length;

  Map<String, dynamic> toJson() => {
        'dayName': dayName,
        'focusMuscle': focusMuscle,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutSplitDay.fromJson(Map<String, dynamic> json) =>
      WorkoutSplitDay(
        dayName: json['dayName'],
        focusMuscle: json['focusMuscle'],
        exercises: (json['exercises'] as List)
            .map((e) => ExerciseItem.fromJson(e))
            .toList(),
      );
}

class MealLog {
  final String id;
  String name;
  int calories;
  int proteinGrams;
  String timeLabel;
  bool isEaten;

  MealLog({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteinGrams,
    required this.timeLabel,
    this.isEaten = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'proteinGrams': proteinGrams,
        'timeLabel': timeLabel,
        'isEaten': isEaten,
      };

  factory MealLog.fromJson(Map<String, dynamic> json) => MealLog(
        id: json['id'],
        name: json['name'],
        calories: json['calories'],
        proteinGrams: json['proteinGrams'],
        timeLabel: json['timeLabel'],
        isEaten: json['isEaten'] ?? false,
      );
}

// ============================================================================
// 3. CONTENT CREATION MODELS
// ============================================================================

class ContentProject {
  final String id;
  String title;
  String hookScript;
  String platform; // 'Instagram Reels', 'YouTube Shorts', 'LinkedIn'
  String stage; // 'Idea', 'Scripting', 'Editing', 'Scheduled', 'Published'
  DateTime scheduledDate;
  int views;
  int likes;
  int saves;

  ContentProject({
    required this.id,
    required this.title,
    required this.hookScript,
    this.platform = 'Instagram Reels',
    required this.stage,
    required this.scheduledDate,
    this.views = 0,
    this.likes = 0,
    this.saves = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hookScript': hookScript,
        'platform': platform,
        'stage': stage,
        'scheduledDate': scheduledDate.toIso8601String(),
        'views': views,
        'likes': likes,
        'saves': saves,
      };

  factory ContentProject.fromJson(Map<String, dynamic> json) => ContentProject(
        id: json['id'],
        title: json['title'],
        hookScript: json['hookScript'],
        platform: json['platform'] ?? 'Instagram Reels',
        stage: json['stage'],
        scheduledDate: DateTime.parse(json['scheduledDate']),
        views: json['views'] ?? 0,
        likes: json['likes'] ?? 0,
        saves: json['saves'] ?? 0,
      );
}

// ============================================================================
// 4. SKILLS & PROJECTS MODELS
// ============================================================================

class MicroLesson {
  String title;
  bool isCompleted;
  String deliverableHint;

  MicroLesson({
    required this.title,
    this.isCompleted = false,
    required this.deliverableHint,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'isCompleted': isCompleted,
        'deliverableHint': deliverableHint,
      };

  factory MicroLesson.fromJson(Map<String, dynamic> json) => MicroLesson(
        title: json['title'],
        isCompleted: json['isCompleted'] ?? false,
        deliverableHint: json['deliverableHint'] ?? '',
      );
}

class SkillTrack {
  final String id;
  String name; // 'AI & LLMs', 'Flutter & App Dev', 'Coding & DSA', 'GitHub & Open Source', 'Video Editing'
  String categoryIcon;
  String activeMilestoneProject;
  int githubCommitsThisWeek;
  List<MicroLesson> lessons;
  Color accentColor;

  SkillTrack({
    required this.id,
    required this.name,
    required this.categoryIcon,
    required this.activeMilestoneProject,
    this.githubCommitsThisWeek = 0,
    required this.lessons,
    required this.accentColor,
  });

  int get completedCount => lessons.where((l) => l.isCompleted).length;
  double get progress =>
      lessons.isEmpty ? 0.0 : completedCount / lessons.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'categoryIcon': categoryIcon,
        'activeMilestoneProject': activeMilestoneProject,
        'githubCommitsThisWeek': githubCommitsThisWeek,
        'lessons': lessons.map((l) => l.toJson()).toList(),
        'accentColor': accentColor.value,
      };

  factory SkillTrack.fromJson(Map<String, dynamic> json) => SkillTrack(
        id: json['id'],
        name: json['name'],
        categoryIcon: json['categoryIcon'],
        activeMilestoneProject: json['activeMilestoneProject'],
        githubCommitsThisWeek: json['githubCommitsThisWeek'] ?? 0,
        lessons: (json['lessons'] as List)
            .map((l) => MicroLesson.fromJson(l))
            .toList(),
        accentColor: Color(json['accentColor'] as int),
      );
}

// ============================================================================
// 5. INCOME & OPPORTUNITIES MODELS
// ============================================================================

class OpportunityLead {
  final String id;
  String clientOrSource;
  String serviceType; // 'Freelance Video Edit', 'Flutter MVP', 'Affiliate Experiment', 'AI Automation'
  String status; // 'Outreach Sent', 'In Call', 'Active Gig', 'Paid'
  double potentialAmount;
  bool isLowCostStudentFriendly;

  OpportunityLead({
    required this.id,
    required this.clientOrSource,
    required this.serviceType,
    required this.status,
    required this.potentialAmount,
    this.isLowCostStudentFriendly = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientOrSource': clientOrSource,
        'serviceType': serviceType,
        'status': status,
        'potentialAmount': potentialAmount,
        'isLowCostStudentFriendly': isLowCostStudentFriendly,
      };

  factory OpportunityLead.fromJson(Map<String, dynamic> json) =>
      OpportunityLead(
        id: json['id'],
        clientOrSource: json['clientOrSource'],
        serviceType: json['serviceType'],
        status: json['status'],
        potentialAmount: (json['potentialAmount'] as num).toDouble(),
        isLowCostStudentFriendly: json['isLowCostStudentFriendly'] ?? true,
      );
}

class FinancialTransaction {
  final String id;
  String title;
  String subtitle;
  double amount;
  bool isIncome; // true = Income, false = Expense
  DateTime date;

  FinancialTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'amount': amount,
        'isIncome': isIncome,
        'date': date.toIso8601String(),
      };

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) =>
      FinancialTransaction(
        id: json['id'],
        title: json['title'],
        subtitle: json['subtitle'],
        amount: (json['amount'] as num).toDouble(),
        isIncome: json['isIncome'] ?? true,
        date: DateTime.parse(json['date']),
      );
}

// ============================================================================
// 6. PERSONAL DISCIPLINE & DIAGNOSTICS MODELS
// ============================================================================

class DailyHabit {
  final String id;
  String title;
  String pillar; // 'Studies', 'Fitness', 'Content', 'Skills', 'Discipline'
  int streakDays;
  bool completedToday;

  DailyHabit({
    required this.id,
    required this.title,
    required this.pillar,
    this.streakDays = 0,
    this.completedToday = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'pillar': pillar,
        'streakDays': streakDays,
        'completedToday': completedToday,
      };

  factory DailyHabit.fromJson(Map<String, dynamic> json) => DailyHabit(
        id: json['id'],
        title: json['title'],
        pillar: json['pillar'],
        streakDays: json['streakDays'] ?? 0,
        completedToday: json['completedToday'] ?? false,
      );
}

class PlanFailureDiagnostic {
  final String id;
  String unfinishedTaskTitle;
  String rootCause; // 'Overwhelmed / Too Big', 'Phone Distraction', 'Low Energy / Poor Sleep', 'Unclear Next Step'
  String adaptiveAdjustment; // Automatic system adjustment
  DateTime loggedAt;

  PlanFailureDiagnostic({
    required this.id,
    required this.unfinishedTaskTitle,
    required this.rootCause,
    required this.adaptiveAdjustment,
    required this.loggedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'unfinishedTaskTitle': unfinishedTaskTitle,
        'rootCause': rootCause,
        'adaptiveAdjustment': adaptiveAdjustment,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory PlanFailureDiagnostic.fromJson(Map<String, dynamic> json) =>
      PlanFailureDiagnostic(
        id: json['id'],
        unfinishedTaskTitle: json['unfinishedTaskTitle'],
        rootCause: json['rootCause'],
        adaptiveAdjustment: json['adaptiveAdjustment'],
        loggedAt: DateTime.parse(json['loggedAt']),
      );
}
