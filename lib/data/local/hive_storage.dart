import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../models/study_session.dart';

class HiveStorage {
  static const String subjectsBoxName = 'subjects';
  static const String topicsBoxName = 'topics';
  static const String sessionsBoxName = 'sessions';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(TopicAdapter());
    Hive.registerAdapter(StudySessionAdapter());

    await Hive.openBox<Subject>(subjectsBoxName);
    await Hive.openBox<Topic>(topicsBoxName);
    await Hive.openBox<StudySession>(sessionsBoxName);
  }

  static Box<Subject> getSubjectsBox() => Hive.box<Subject>(subjectsBoxName);
  static Box<Topic> getTopicsBox() => Hive.box<Topic>(topicsBoxName);
  static Box<StudySession> getSessionsBox() => Hive.box<StudySession>(sessionsBoxName);
}
