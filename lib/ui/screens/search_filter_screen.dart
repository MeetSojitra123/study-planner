import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Explore Topics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                labelText: 'Search topics...',
                labelStyle: const TextStyle(color: Color(0xFF64748B)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.8),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF6366F1))),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterDropdown<Subject>(
                  hint: 'All Subjects',
                  value: selectedSubject,
                  items: [
                    const DropdownMenuItem<Subject>(value: null, child: Text('All Subjects')),
                    ...subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))),
                  ],
                  onChanged: (val) => setState(() => selectedSubject = val),
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown<TopicStatus>(
                  hint: 'All Statuses',
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Statuses')),
                    DropdownMenuItem(value: TopicStatus.notStarted, child: Text('Not Started')),
                    DropdownMenuItem(value: TopicStatus.inProgress, child: Text('In Progress')),
                    DropdownMenuItem(value: TopicStatus.completed, child: Text('Completed')),
                  ],
                  onChanged: (val) => setState(() => selectedStatus = val),
                ),
                const SizedBox(width: 12),
                InputChip(
                  label: Text(selectedDate == null ? 'Filter Date' : DateFormat('MMM dd, yyyy').format(selectedDate!)),
                  labelStyle: TextStyle(color: selectedDate == null ? const Color(0xFF64748B) : Colors.white, fontWeight: FontWeight.w600),
                  backgroundColor: selectedDate == null ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF6366F1),
                  side: BorderSide(color: selectedDate == null ? Colors.white : const Color(0xFF6366F1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(12),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2030),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: Color(0xFF6366F1), surface: Colors.white),
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  onDeleted: selectedDate != null ? () => setState(() => selectedDate = null) : null,
                  deleteIconColor: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredTopics.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: const Color(0xFF64748B).withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text('No topics match the criteria.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredTopics.length,
                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];
                      final subject = subjects.firstWhere(
                        (s) => s.id == topic.subjectId, 
                        orElse: () => Subject(id: '', name: 'Unknown')
                      );
                      
                      Color statusColor;
                      switch(topic.status) {
                        case TopicStatus.completed: statusColor = const Color(0xFF10B981); break;
                        case TopicStatus.inProgress: statusColor = const Color(0xFFF59E0B); break;
                        case TopicStatus.notStarted: statusColor = const Color(0xFF64748B); break;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                          boxShadow: [BoxShadow(color: const Color(0xFF64748B).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF0F172A))),
                              subtitle: Text(subject.name, style: const TextStyle(color: Color(0xFF64748B))),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  topic.status.name.replaceAll('notStarted', 'Not Started').replaceAll('inProgress', 'In Progress').replaceAll('completed', 'Completed'),
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
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

  Widget _buildFilterDropdown<T>({required String hint, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
        boxShadow: [BoxShadow(color: const Color(0xFF64748B).withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          hint: Text(hint, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          value: value,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF64748B)),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
