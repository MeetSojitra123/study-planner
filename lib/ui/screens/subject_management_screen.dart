import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../data/models/subject.dart';

class SubjectManagementScreen extends ConsumerWidget {
  const SubjectManagementScreen({super.key});

  void _showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Subject Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                ref.read(subjectsProvider.notifier).addSubject(nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context, WidgetRef ref, Subject subject) {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Topic to ${subject.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Topic Name'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Estimated Time (mins)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final time = int.tryParse(timeController.text.trim());
              if (name.isNotEmpty && time != null && time > 0) {
                ref.read(topicsProvider.notifier).addTopic(subject.id, name, time);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subjects & Topics')),
      body: subjects.isEmpty
          ? const Center(child: Text('No subjects added yet. Add one!'))
          : ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final subjectTopics = topics.where((t) => t.subjectId == subject.id).toList();

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${subjectTopics.length} topics'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => ref.read(subjectsProvider.notifier).removeSubject(subject.id),
                    ),
                    children: [
                      ...subjectTopics.map((topic) => ListTile(
                            title: Text(topic.name),
                            subtitle: Text('${topic.estimatedTimeInMinutes} mins'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                              onPressed: () => ref.read(topicsProvider.notifier).removeTopic(topic.id),
                            ),
                          )),
                      ListTile(
                        leading: const Icon(Icons.add, color: Colors.deepPurple),
                        title: const Text('Add Topic', style: TextStyle(color: Colors.deepPurple)),
                        onTap: () => _showAddTopicDialog(context, ref, subject),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
