import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
    syncToFirestore(); // Push to cloud
  }
  
  void removeSubject(String id) {
    HiveStorage.getSubjectsBox().delete(id);
    state = state.where((s) => s.id != id).toList();
    // We also need to delete from Firestore
    FirebaseFirestore.instance.collection('subjects').doc(id).delete().catchError((_) {});
  }

  Future<void> syncToFirestore() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    for (var subject in state) {
      batch.set(firestore.collection('subjects').doc(subject.id), subject.toJson());
    }
    await batch.commit();
  }

  Future<void> syncFromFirestore() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final snapshot = await FirebaseFirestore.instance.collection('subjects').get();
    for (var doc in snapshot.docs) {
      final subject = Subject.fromJson(doc.data());
      HiveStorage.getSubjectsBox().put(subject.id, subject);
    }
    state = HiveStorage.getSubjectsBox().values.toList();
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
    syncToFirestore(); // Push to cloud
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
      syncToFirestore(); // Push to cloud
    }
  }

  void removeTopic(String id) {
    HiveStorage.getTopicsBox().delete(id);
    state = state.where((t) => t.id != id).toList();
    FirebaseFirestore.instance.collection('topics').doc(id).delete().catchError((_) {});
  }

  Future<void> syncToFirestore() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    for (var topic in state) {
      batch.set(firestore.collection('topics').doc(topic.id), topic.toJson());
    }
    await batch.commit();
  }

  Future<void> syncFromFirestore() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final snapshot = await FirebaseFirestore.instance.collection('topics').get();
    for (var doc in snapshot.docs) {
      final topic = Topic.fromJson(doc.data());
      HiveStorage.getTopicsBox().put(topic.id, topic);
    }
    state = HiveStorage.getTopicsBox().values.toList();
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
    syncToFirestore(); // Push to cloud
  }

  void removeSession(String id) {
    HiveStorage.getSessionsBox().delete(id);
    state = state.where((s) => s.id != id).toList();
    FirebaseFirestore.instance.collection('sessions').doc(id).delete().catchError((_) {});
  }

  Future<void> syncToFirestore() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    for (var session in state) {
      batch.set(firestore.collection('sessions').doc(session.id), session.toJson());
    }
    await batch.commit();
  }

  Future<void> syncFromFirestore() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final snapshot = await FirebaseFirestore.instance.collection('sessions').get();
    for (var doc in snapshot.docs) {
      final session = StudySession.fromJson(doc.data());
      HiveStorage.getSessionsBox().put(session.id, session);
    }
    state = HiveStorage.getSessionsBox().values.toList();
  }
}

final sessionsProvider = NotifierProvider<SessionsNotifier, List<StudySession>>(() {
  return SessionsNotifier();
});
