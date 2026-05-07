import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';
import '../../data/models/topic.dart';
import '../../data/models/subject.dart';
import 'dart:ui';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);

    final totalSubjects = subjects.length;
    final completedTopics = topics.where((t) => t.status == TopicStatus.completed).length;
    final pendingTopics = topics.length - completedTopics;

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
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Branded Header ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'StudyPlanner',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.5),
                        ),
                        Text(
                          'Your exam prep companion',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Stat Cards ──
            Row(
              children: [
                Expanded(child: _buildStatCard(context, 'Subjects', totalSubjects.toString(), Icons.my_library_books_rounded, const [Color(0xFF6366F1), Color(0xFF4F46E5)])),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(context, 'Done', completedTopics.toString(), Icons.check_circle_rounded, const [Color(0xFF10B981), Color(0xFF059669)])),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(context, 'Pending', pendingTopics.toString(), Icons.hourglass_bottom_rounded, const [Color(0xFFF59E0B), Color(0xFFD97706)])),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Preparation Status', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            _buildGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  height: 220,
                  child: topics.isEmpty 
                    ? const Center(child: Text('Add topics to see your progress chart!', style: TextStyle(color: Color(0xFF64748B))))
                    : PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 50,
                        sections: [
                          if (completedTopics > 0)
                            PieChartSectionData(
                              color: const Color(0xFF10B981),
                              value: completedTopics.toDouble(),
                              title: '$completedTopics',
                              radius: 60,
                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              badgeWidget: _buildBadge(Icons.check, const Color(0xFF10B981)),
                              badgePositionPercentageOffset: .98,
                            ),
                          if (pendingTopics > 0)
                            PieChartSectionData(
                              color: const Color(0xFFF43F5E),
                              value: pendingTopics.toDouble(),
                              title: '$pendingTopics',
                              radius: 60,
                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              badgeWidget: _buildBadge(Icons.hourglass_empty, const Color(0xFFF43F5E)),
                              badgePositionPercentageOffset: .98,
                            ),
                        ],
                      ),
                    ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Focus Priority', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            if (lowestCompletionSubject != null)
              _buildGlassCard(
                glowColor: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF43F5E).withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.priority_high_rounded, color: Color(0xFFE11D48)),
                  ),
                  title: Text(lowestCompletionSubject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: subjectCompletion[lowestCompletionSubject]!,
                              backgroundColor: const Color(0xFFF1F5F9),
                              color: const Color(0xFFF43F5E),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('${(subjectCompletion[lowestCompletionSubject]! * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
              )
            else
              _buildGlassCard(child: const Padding(padding: EdgeInsets.all(20), child: Text('You are all caught up!', style: TextStyle(color: Color(0xFF64748B))))),
            
            const SizedBox(height: 32),
            const Text('Suggested Next Steps', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            if (suggestedTopics.isNotEmpty)
              ...suggestedTopics.map((topic) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildGlassCard(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF6366F1), size: 32),
                    title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF0F172A))),
                    subtitle: Text('Est. Time: ${topic.estimatedTimeInMinutes} mins', style: const TextStyle(color: Color(0xFF64748B))),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF94A3B8)),
                  ),
                ),
              ))
            else
              _buildGlassCard(child: const Padding(padding: EdgeInsets.all(20), child: Text('No pending topics. Enjoy your free time!', style: TextStyle(color: Color(0xFF64748B))))),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }

  Widget _buildGlassCard({required Widget child, Color? glowColor}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: glowColor != null 
          ? [BoxShadow(color: glowColor, blurRadius: 20, spreadRadius: -5)] 
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

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, List<Color> gradientColors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
