import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../data/models/topic.dart';
import '../../data/models/subject.dart';

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  String searchQuery = '';
  Subject? selectedSubject;
  TopicStatus? selectedStatus;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);
    final sessions = ref.watch(sessionsProvider);

    List<Topic> filteredTopics = topics.where((t) {
      final matchesSearch = t.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesSubject = selectedSubject == null || t.subjectId == selectedSubject!.id;
      final matchesStatus = selectedStatus == null || t.status == selectedStatus;
      
      bool matchesDate = true;
      if (selectedDate != null) {
        final topicSessions = sessions.where((s) => s.topicId == t.id).toList();
        matchesDate = topicSessions.any((s) => 
          s.dateTime.year == selectedDate!.year && 
          s.dateTime.month == selectedDate!.month && 
          s.dateTime.day == selectedDate!.day
        );
      }

      return matchesSearch && matchesSubject && matchesStatus && matchesDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Topics',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                DropdownButton<Subject>(
                  hint: const Text('All Subjects'),
                  value: selectedSubject,
                  items: [
                    const DropdownMenuItem<Subject>(value: null, child: Text('All Subjects')),
                    ...subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))),
                  ],
                  onChanged: (val) => setState(() => selectedSubject = val),
                ),
                const SizedBox(width: 16),
                DropdownButton<TopicStatus>(
                  hint: const Text('All Statuses'),
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Statuses')),
                    DropdownMenuItem(value: TopicStatus.notStarted, child: Text('Not Started')),
                    DropdownMenuItem(value: TopicStatus.inProgress, child: Text('In Progress')),
                    DropdownMenuItem(value: TopicStatus.completed, child: Text('Completed')),
                  ],
                  onChanged: (val) => setState(() => selectedStatus = val),
                ),
                const SizedBox(width: 16),
                InputChip(
                  label: Text(selectedDate == null ? 'Filter Date' : DateFormat('MMM dd, yyyy').format(selectedDate!)),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  onDeleted: selectedDate != null ? () => setState(() => selectedDate = null) : null,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: filteredTopics.isEmpty
                ? const Center(child: Text('No topics match the criteria.'))
                : ListView.builder(
                    itemCount: filteredTopics.length,
                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];
                      final subject = subjects.firstWhere(
                        (s) => s.id == topic.subjectId, 
                        orElse: () => Subject(id: '', name: 'Unknown')
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(topic.name),
                          subtitle: Text(subject.name),
                          trailing: Chip(
                            label: Text(topic.status.name),
                            backgroundColor: topic.status == TopicStatus.completed 
                                ? Colors.green.shade100 
                                : Colors.orange.shade100,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
