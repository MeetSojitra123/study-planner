import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../data/models/subject.dart';
import '../../data/models/topic.dart';
import 'package:intl/intl.dart';

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
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      final duration = int.tryParse(durationController.text) ?? 60;
      
      ref.read(sessionsProvider.notifier).addSession(
        selectedSubject!.id,
        selectedTopic!.id,
        dateTime,
        duration,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session Scheduled!')),
      );
      
      setState(() {
        selectedSubject = null;
        selectedTopic = null;
        selectedDate = null;
        selectedTime = null;
        durationController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);
    final topics = ref.watch(topicsProvider);
    final sessions = ref.watch(sessionsProvider);

    final availableTopics = selectedSubject == null 
        ? <Topic>[] 
        : topics.where((t) => t.subjectId == selectedSubject!.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Study Scheduling')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Schedule a New Session', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Select Subject', border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Subject>(
                  isDense: true,
                  value: selectedSubject,
                  items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSubject = val;
                      selectedTopic = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Select Topic', border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Topic>(
                  isDense: true,
                  value: selectedTopic,
                  items: availableTopics.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => selectedTopic = val),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(selectedDate!)),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(selectedTime == null ? 'Select Time' : selectedTime!.format(context)),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
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
              decoration: const InputDecoration(labelText: 'Duration (minutes)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _scheduleSession,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                child: const Text('Schedule Session', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Upcoming Sessions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            sessions.isEmpty 
              ? const Text('No upcoming sessions')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final subject = subjects.firstWhere(
                      (s) => s.id == session.subjectId, 
                      orElse: () => Subject(id: '', name: 'Unknown')
                    );
                    final topic = topics.firstWhere(
                      (t) => t.id == session.topicId, 
                      orElse: () => Topic(id: '', subjectId: '', name: 'Unknown', estimatedTimeInMinutes: 0)
                    );
                    
                    return Card(
                      child: ListTile(
                        title: Text('${subject.name} - ${topic.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${DateFormat('MMM dd, yyyy - hh:mm a').format(session.dateTime)} (${session.durationInMinutes} mins)'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
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
}
