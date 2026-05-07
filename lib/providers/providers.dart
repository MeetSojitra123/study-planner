import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/local/hive_storage.dart';
import '../data/models/subject.dart';
import '../data/models/topic.dart';
import '../data/models/study_session.dart';

const _uuid = Uuid();

// Subjects
class SubjectsNotifier extends Notifier<List<Subject>> {
  @override
  List<Subject> build() {
    return HiveStorage.getSubjectsBox().values.toList();
  }

  void addSubject(String name) {
    final newSubject = Subject(id: _uuid.v4(), name: name);
    HiveStorage.getSubjectsBox().put(newSubject.id, newSubject);
    state = [...state, newSubject];
  }
  
  void removeSubject(String id) {
    HiveStorage.getSubjectsBox().delete(id);
    state = state.where((s) => s.id != id).toList();
  }
}

final subjectsProvider = NotifierProvider<SubjectsNotifier, List<Subject>>(() {
  return SubjectsNotifier();
});

// Topics
class TopicsNotifier extends Notifier<List<Topic>> {
  @override
  List<Topic> build() {
    return HiveStorage.getTopicsBox().values.toList();
  }

  void addTopic(String subjectId, String name, int estimatedMinutes) {
    final topic = Topic(
      id: _uuid.v4(),
      subjectId: subjectId,
      name: name,
      estimatedTimeInMinutes: estimatedMinutes,
    );
    HiveStorage.getTopicsBox().put(topic.id, topic);
    state = [...state, topic];
  }

  void updateTopicStatus(String id, TopicStatus newStatus) {
    final index = state.indexWhere((t) => t.id == id);
    if (index != -1) {
      final updated = state[index].copyWith(status: newStatus);
      HiveStorage.getTopicsBox().put(id, updated);
      state = [
        for (final topic in state)
          if (topic.id == id) updated else topic
      ];
    }
  }

  void removeTopic(String id) {
    HiveStorage.getTopicsBox().delete(id);
    state = state.where((t) => t.id != id).toList();
  }
}

final topicsProvider = NotifierProvider<TopicsNotifier, List<Topic>>(() {
  return TopicsNotifier();
});

// Study Sessions
class SessionsNotifier extends Notifier<List<StudySession>> {
  @override
  List<StudySession> build() {
    return HiveStorage.getSessionsBox().values.toList();
  }

  void addSession(String subjectId, String topicId, DateTime dateTime, int durationInMinutes) {
    final session = StudySession(
      id: _uuid.v4(),
      subjectId: subjectId,
      topicId: topicId,
      dateTime: dateTime,
      durationInMinutes: durationInMinutes,
    );
    HiveStorage.getSessionsBox().put(session.id, session);
    state = [...state, session];
  }

  void removeSession(String id) {
    HiveStorage.getSessionsBox().delete(id);
    state = state.where((s) => s.id != id).toList();
  }
}

final sessionsProvider = NotifierProvider<SessionsNotifier, List<StudySession>>(() {
  return SessionsNotifier();
});
