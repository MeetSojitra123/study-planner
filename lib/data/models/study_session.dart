import 'package:hive/hive.dart';

class StudySessionAdapter extends TypeAdapter<StudySession> {
  @override
  final int typeId = 2;

  @override
  StudySession read(BinaryReader reader) {
    return StudySession(
      id: reader.readString(),
      subjectId: reader.readString(),
      topicId: reader.readString(),
      dateTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      durationInMinutes: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, StudySession obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.subjectId);
    writer.writeString(obj.topicId);
    writer.writeInt(obj.dateTime.millisecondsSinceEpoch);
    writer.writeInt(obj.durationInMinutes);
  }
}

class StudySession {
  final String id;
  final String subjectId;
  final String topicId;
  final DateTime dateTime;
  final int durationInMinutes;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.dateTime,
    required this.durationInMinutes,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      subjectId: json['subjectId'],
      topicId: json['topicId'],
      dateTime: DateTime.parse(json['dateTime']),
      durationInMinutes: json['durationInMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'topicId': topicId,
      'dateTime': dateTime.toIso8601String(),
      'durationInMinutes': durationInMinutes,
    };
  }
}
