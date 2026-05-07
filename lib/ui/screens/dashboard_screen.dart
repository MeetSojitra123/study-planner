import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';
import '../../data/models/topic.dart';
import '../../data/models/subject.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);

    final totalSubjects = subjects.length;
    final completedTopics = topics.where((t) => t.status == TopicStatus.completed).length;
    final pendingTopics = topics.length - completedTopics;

    // Calculate priority subjects (lowest completion)
    final subjectCompletion = <Subject, double>{};
    for (var subject in subjects) {
      final subjectTopics = topics.where((t) => t.subjectId == subject.id).toList();
      if (subjectTopics.isEmpty) {
        subjectCompletion[subject] = 0.0;
      } else {
        final completed = subjectTopics.where((t) => t.status == TopicStatus.completed).length;
        subjectCompletion[subject] = completed / subjectTopics.length;
      }
    }

    final sortedSubjects = subjectCompletion.keys.toList()
      ..sort((a, b) => subjectCompletion[a]!.compareTo(subjectCompletion[b]!));
      
    final lowestCompletionSubject = sortedSubjects.isNotEmpty ? sortedSubjects.first : null;
    final suggestedTopics = lowestCompletionSubject != null 
      ? topics.where((t) => t.subjectId == lowestCompletionSubject.id && t.status != TopicStatus.completed).take(2).toList()
      : <Topic>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard(context, 'Subjects', totalSubjects.toString(), Icons.menu_book, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(context, 'Completed', completedTopics.toString(), Icons.check_circle, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(context, 'Pending', pendingTopics.toString(), Icons.pending, Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Topic Completion Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: topics.isEmpty 
                ? const Center(child: Text('No topics added'))
                : PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      if (completedTopics > 0)
                        PieChartSectionData(
                          color: Colors.green,
                          value: completedTopics.toDouble(),
                          title: '$completedTopics',
                          radius: 50,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      if (pendingTopics > 0)
                        PieChartSectionData(
                          color: Colors.orange,
                          value: pendingTopics.toDouble(),
                          title: '$pendingTopics',
                          radius: 50,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
            ),
            const SizedBox(height: 24),
            const Text('Priority Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (lowestCompletionSubject != null)
              Card(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade50,
                child: ListTile(
                  title: Text(lowestCompletionSubject.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  subtitle: Text('Completion: ${(subjectCompletion[lowestCompletionSubject]! * 100).toStringAsFixed(1)}%'),
                  trailing: const Icon(Icons.warning, color: Colors.red),
                ),
              )
            else
              const Text('No priority subjects found.'),
            const SizedBox(height: 16),
            const Text('Suggested Topics to Study', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (suggestedTopics.isNotEmpty)
              ...suggestedTopics.map((topic) => Card(
                child: ListTile(
                  leading: const Icon(Icons.lightbulb, color: Colors.amber),
                  title: Text(topic.name),
                  subtitle: Text('Est. Time: ${topic.estimatedTimeInMinutes} mins'),
                ),
              ))
            else
              const Text('No topics to suggest right now.'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
