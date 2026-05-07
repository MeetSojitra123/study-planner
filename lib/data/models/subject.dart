import 'package:hive/hive.dart';

class Subject {
  final String id;
  final String name;

  Subject({required this.id, required this.name});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 0;

  @override
  Subject read(BinaryReader reader) {
    return Subject(
      id: reader.readString(),
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
  }
}
