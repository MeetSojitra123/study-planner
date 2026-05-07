import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../providers/providers.dart';
import '../../data/models/subject.dart';
import '../../data/models/topic.dart';

class SubjectManagementScreen extends ConsumerWidget {
  const SubjectManagementScreen({super.key});

  void _showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Subject', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            labelText: 'Subject Name',
            labelStyle: const TextStyle(color: Color(0xFF64748B)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1))),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                ref.read(subjectsProvider.notifier).addSubject(nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Add Topic to ${subject.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                labelText: 'Topic Name', 
                labelStyle: const TextStyle(color: Color(0xFF64748B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true, fillColor: const Color(0xFFF1F5F9),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1))),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              style: const TextStyle(color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                labelText: 'Estimated Time (mins)', 
                labelStyle: const TextStyle(color: Color(0xFF64748B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true, fillColor: const Color(0xFFF1F5F9),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1))),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              final name = nameController.text.trim();
              final time = int.tryParse(timeController.text.trim());
              if (name.isNotEmpty && time != null && time > 0) {
                ref.read(topicsProvider.notifier).addTopic(subject.id, name, time);
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Curriculum')),
      body: subjects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 80, color: const Color(0xFF64748B).withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('No subjects yet.\nStart planning your success!', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final subjectTopics = topics.where((t) => t.subjectId == subject.id).toList();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white),
                    boxShadow: [BoxShadow(color: const Color(0xFF64748B).withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: const Color(0xFF6366F1),
                          collapsedIconColor: const Color(0xFF94A3B8),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                          subtitle: Text('${subjectTopics.length} topics • ${subjectTopics.fold<int>(0, (p, e) => p + e.estimatedTimeInMinutes)} mins total', style: const TextStyle(color: Color(0xFF64748B))),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.folder_rounded, color: Color(0xFF6366F1)),
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: const Color(0xFFF8FAFC).withValues(alpha: 0.5),
                              child: Column(
                                children: [
                                  ...subjectTopics.map((topic) => ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                                        leading: Container(
                                          width: 8, height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: topic.status == TopicStatus.completed ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                        title: Text(topic.name, style: const TextStyle(fontSize: 15, color: Color(0xFF334155))),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('${topic.estimatedTimeInMinutes}m', style: const TextStyle(color: Color(0xFF94A3B8))),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF43F5E), size: 20),
                                              onPressed: () => ref.read(topicsProvider.notifier).removeTopic(topic.id),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF6366F1),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
                                    ),
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('New Topic', style: TextStyle(fontWeight: FontWeight.w600)),
                                    onPressed: () => _showAddTopicDialog(context, ref, subject),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFF43F5E)),
                                    icon: const Icon(Icons.delete_forever_rounded, size: 18),
                                    label: const Text('Delete Subject'),
                                    onPressed: () => ref.read(subjectsProvider.notifier).removeSubject(subject.id),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Above custom bottom nav
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF6366F1),
          onPressed: () => _showAddSubjectDialog(context, ref),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Subject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
