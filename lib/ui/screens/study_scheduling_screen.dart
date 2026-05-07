import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../providers/providers.dart';
import '../../data/models/subject.dart';
import '../../data/models/topic.dart';

class StudySchedulingScreen extends ConsumerStatefulWidget {
  const StudySchedulingScreen({super.key});

  @override
  ConsumerState<StudySchedulingScreen> createState() => _StudySchedulingScreenState();
}

class _StudySchedulingScreenState extends ConsumerState<StudySchedulingScreen> {
  Subject? selectedSubject;
  Topic? selectedTopic;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final durationController = TextEditingController();

  void _scheduleSession() {
    if (selectedSubject != null && selectedTopic != null && selectedDate != null && selectedTime != null && durationController.text.isNotEmpty) {
      final dateTime = DateTime(
        selectedDate!.year, selectedDate!.month, selectedDate!.day,
        selectedTime!.hour, selectedTime!.minute,
      );
      final duration = int.tryParse(durationController.text) ?? 60;
      
      ref.read(sessionsProvider.notifier).addSession(selectedSubject!.id, selectedTopic!.id, dateTime, duration);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Session Scheduled!'), backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      );
      
      setState(() {
        selectedSubject = null; selectedTopic = null; selectedDate = null; selectedTime = null; durationController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please fill all fields!'), backgroundColor: const Color(0xFFF43F5E), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);
    final sessions = ref.watch(sessionsProvider);

    final availableTopics = selectedSubject == null ? <Topic>[] : topics.where((t) => t.subjectId == selectedSubject!.id).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Schedule')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Plan New Session', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 20),
                      _buildDropdown<Subject>(
                        hint: 'Select Subject',
                        value: selectedSubject,
                        items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                        onChanged: (val) => setState(() { selectedSubject = val; selectedTopic = null; }),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<Topic>(
                        hint: 'Select Topic',
                        value: selectedTopic,
                        items: availableTopics.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                        onChanged: (val) => setState(() => selectedTopic = val),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerButton(
                              icon: Icons.calendar_month_rounded,
                              label: selectedDate == null ? 'Date' : DateFormat('MMM dd').format(selectedDate!),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030),
                                  builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF6366F1))), child: child!),
                                );
                                if (date != null) setState(() => selectedDate = date);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPickerButton(
                              icon: Icons.access_time_filled_rounded,
                              label: selectedTime == null ? 'Time' : selectedTime!.format(context),
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context, initialTime: TimeOfDay.now(),
                                  builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF6366F1))), child: child!),
                                );
                                if (time != null) setState(() => selectedTime = time);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: durationController,
                        style: const TextStyle(color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          labelText: 'Duration (minutes)',
                          labelStyle: const TextStyle(color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1))),
                          prefixIcon: const Icon(Icons.timer_rounded, color: Color(0xFF64748B)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 55,
                        child: ElevatedButton(
                          onPressed: _scheduleSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                            shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          ),
                          child: const Text('Schedule Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text('Upcoming Sessions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ),
            const SizedBox(height: 16),
            sessions.isEmpty 
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.event_busy_rounded, size: 60, color: const Color(0xFF64748B).withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text('No sessions planned yet.', style: TextStyle(color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions.reversed.toList()[index]; // Show newest first
                    final subject = subjects.firstWhere((s) => s.id == session.subjectId, orElse: () => Subject(id: '', name: 'Unknown'));
                    final topic = topics.firstWhere((t) => t.id == session.topicId, orElse: () => Topic(id: '', subjectId: '', name: 'Unknown', estimatedTimeInMinutes: 0));
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white),
                        boxShadow: [BoxShadow(color: const Color(0xFF64748B).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFEC4899).withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.event_note_rounded, color: Color(0xFFEC4899)),
                        ),
                        title: Text('${subject.name} - ${topic.name}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('${DateFormat('MMM dd, yyyy • hh:mm a').format(session.dateTime)} \n${session.durationInMinutes} mins', style: const TextStyle(color: Color(0xFF64748B), height: 1.4)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF43F5E)),
                          onPressed: () => ref.read(sessionsProvider.notifier).removeSession(session.id),
                        ),
                      ),
                    );
                  },
                )
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({required String hint, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Color(0xFF64748B))),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w500),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPickerButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
