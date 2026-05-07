import 'package:hive/hive.dart';

enum TopicStatus { notStarted, inProgress, completed }

class TopicAdapter extends TypeAdapter<Topic> {
  @override
  final int typeId = 1;

  @override
  Topic read(BinaryReader reader) {
    return Topic(
      id: reader.readString(),
      subjectId: reader.readString(),
      name: reader.readString(),
      estimatedTimeInMinutes: reader.readInt(),
      status: TopicStatus.values[reader.readInt()],
    );
  }

  @override
  void write(BinaryWriter writer, Topic obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.subjectId);
    writer.writeString(obj.name);
    writer.writeInt(obj.estimatedTimeInMinutes);
    writer.writeInt(obj.status.index);
  }
}

class Topic {
  final String id;
  final String subjectId;
  final String name;
  final int estimatedTimeInMinutes;
  final TopicStatus status;

  Topic({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.estimatedTimeInMinutes,
    this.status = TopicStatus.notStarted,
  });

  Topic copyWith({
    String? id,
    String? subjectId,
    String? name,
    int? estimatedTimeInMinutes,
    TopicStatus? status,
  }) {
    return Topic(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      estimatedTimeInMinutes: estimatedTimeInMinutes ?? this.estimatedTimeInMinutes,
      status: status ?? this.status,
    );
  }
}
