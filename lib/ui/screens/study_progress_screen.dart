import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../providers/providers.dart';
import '../../data/models/topic.dart';
import '../../data/models/subject.dart';

class StudyProgressScreen extends ConsumerWidget {
  const StudyProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);

    // Calculate Priority & Planning Logic
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
      
    // Find the subject with lowest completion that is NOT 100% complete
    Subject? prioritySubject;
    try {
      prioritySubject = sortedSubjects.firstWhere((s) => subjectCompletion[s]! < 1.0);
    } catch (_) {
      prioritySubject = sortedSubjects.isNotEmpty ? sortedSubjects.first : null;
    }

    final suggestedTopics = prioritySubject != null 
      ? topics.where((t) => t.subjectId == prioritySubject!.id && t.status != TopicStatus.completed).take(3).toList()
      : <Topic>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Progress Tracking')),
      body: subjects.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_chart_outlined_rounded, size: 80, color: const Color(0xFF64748B).withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text('No subjects added.\nNothing to track yet!', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
              ],
            ),
          )
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority & Planning Section
                const Text('Priority Focus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                
                if (prioritySubject != null && subjectCompletion[prioritySubject]! < 1.0) ...[
                  _buildGlassCard(
                    glowColor: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFFF43F5E).withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Needs Attention', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(prioritySubject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                                child: Text('${(subjectCompletion[prioritySubject]! * 100).toStringAsFixed(0)}% Done', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                              )
                            ],
                          ),
                          if (suggestedTopics.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text('Suggested Next Topics:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: suggestedTopics.map((topic) => Chip(
                                avatar: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF6366F1), size: 18),
                                label: Text('${topic.name} (${topic.estimatedTimeInMinutes}m)', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500)),
                                backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.05),
                                side: const BorderSide(color: Colors.transparent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              )).toList(),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  _buildGlassCard(
                    glowColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                    child: const ListTile(
                      leading: Icon(Icons.celebration_rounded, color: Color(0xFF10B981), size: 32),
                      title: Text('All Caught Up!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      subtitle: Text('You have completed all topics. Amazing job!', style: TextStyle(color: Color(0xFF64748B))),
                    )
                  ),
                ],
                
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                
                const Text('All Subjects Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),

                // Existing List View
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final subjectTopics = topics.where((t) => t.subjectId == subject.id).toList();
                    
                    if (subjectTopics.isEmpty) {
                      return _buildGlassCard(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.folder_open_rounded, color: Color(0xFF6366F1)),
                          ),
                          title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                          subtitle: const Text('No topics added to track', style: TextStyle(color: Color(0xFF64748B))),
                        ),
                      );
                    }

                    final completedTopics = subjectTopics.where((t) => t.status == TopicStatus.completed).length;
                    final progress = completedTopics / subjectTopics.length;
                    final isFullyComplete = progress == 1.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildGlassCard(
                        glowColor: isFullyComplete ? const Color(0xFF10B981).withValues(alpha: 0.15) : null,
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            iconColor: isFullyComplete ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                            collapsedIconColor: const Color(0xFF94A3B8),
                            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    color: isFullyComplete ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('${(progress * 100).toStringAsFixed(0)}% Completed ($completedTopics/${subjectTopics.length})', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                color: const Color(0xFFF8FAFC).withValues(alpha: 0.5),
                                child: Column(
                                  children: subjectTopics.map((topic) {
                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                      title: Text(topic.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, decoration: topic.status == TopicStatus.completed ? TextDecoration.lineThrough : null, color: topic.status == TopicStatus.completed ? const Color(0xFF94A3B8) : const Color(0xFF334155))),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<TopicStatus>(
                                            value: topic.status,
                                            icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF94A3B8)),
                                            dropdownColor: Colors.white,
                                            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
                                            onChanged: (newStatus) {
                                              if (newStatus != null) {
                                                ref.read(topicsProvider.notifier).updateTopicStatus(topic.id, newStatus);
                                              }
                                            },
                                            items: const [
                                              DropdownMenuItem(value: TopicStatus.notStarted, child: Text('Not Started', style: TextStyle(color: Color(0xFF64748B)))),
                                              DropdownMenuItem(value: TopicStatus.inProgress, child: Text('In Progress', style: TextStyle(color: Color(0xFFF59E0B)))),
                                              DropdownMenuItem(value: TopicStatus.completed, child: Text('Completed', style: TextStyle(color: Color(0xFF10B981)))),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildGlassCard({required Widget child, Color? glowColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: glowColor != null 
          ? [BoxShadow(color: glowColor, blurRadius: 15, spreadRadius: -5)] 
          : [BoxShadow(color: const Color(0xFF64748B).withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}
