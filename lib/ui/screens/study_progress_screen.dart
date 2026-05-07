import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../data/models/topic.dart';

class StudyProgressScreen extends ConsumerWidget {
  const StudyProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Study Progress')),
      body: subjects.isEmpty 
        ? const Center(child: Text('No subjects added yet.'))
        : ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final subjectTopics = topics.where((t) => t.subjectId == subject.id).toList();
              
              if (subjectTopics.isEmpty) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('No topics added'),
                  ),
                );
              }

              final completedTopics = subjectTopics.where((t) => t.status == TopicStatus.completed).length;
              final progress = completedTopics / subjectTopics.length;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 4),
                      Text('${(progress * 100).toStringAsFixed(1)}% Completed ($completedTopics/${subjectTopics.length})'),
                    ],
                  ),
                  children: subjectTopics.map((topic) {
                    return ListTile(
                      title: Text(topic.name),
                      trailing: DropdownButton<TopicStatus>(
                        value: topic.status,
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            ref.read(topicsProvider.notifier).updateTopicStatus(topic.id, newStatus);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: TopicStatus.notStarted, child: Text('Not Started')),
                          DropdownMenuItem(value: TopicStatus.inProgress, child: Text('In Progress')),
                          DropdownMenuItem(value: TopicStatus.completed, child: Text('Completed')),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
    );
  }
}
