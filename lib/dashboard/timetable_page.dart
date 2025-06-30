import 'package:flutter/material.dart';

class TimeTablePage extends StatefulWidget {
  const TimeTablePage({super.key});

  @override
  State<TimeTablePage> createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  String selectedDay = 'Monday';

  final Map<String, List<Map<String, String>>> timetableData = {
    'Monday': [
      {'period': 'Assembly', 'time': '08:00 to 08:15', 'subject': 'Assembly', 'teacher': ''},
      {'period': 'I', 'time': '08:15 to 08:45', 'subject': 'Math', 'teacher': 'Mr. Sharma'},
      {'period': 'II', 'time': '08:45 to 09:15', 'subject': 'English', 'teacher': 'Ms. Kapoor'},
      {'period': 'III', 'time': '09:15 to 09:45', 'subject': 'Science', 'teacher': 'Mr. Patel'},
      {'period': 'IV', 'time': '09:45 to 10:15', 'subject': 'Hindi', 'teacher': 'Ms. Singh'},
      {'period': 'Lunch', 'time': '10:15 to 10:45', 'subject': 'Lunch', 'teacher': ''},
      {'period': 'V', 'time': '10:45 to 11:15', 'subject': 'SST', 'teacher': 'Mr. Rao'},
      {'period': 'VI', 'time': '11:15 to 12:30', 'subject': 'Computer', 'teacher': 'Ms. Roy'},
    ],
    // Add other days...
  };

  @override
  Widget build(BuildContext context) {
    final todayPeriods = timetableData[selectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Table"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          _buildDaySelector(),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: todayPeriods.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final period = todayPeriods[index];
                final isBreak = period['period'] == 'Assembly' || period['period'] == 'Lunch';

                return Card(
                  color: isBreak ? Colors.orange.shade100 : Colors.white,
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isBreak ? Colors.orange : Colors.deepPurple,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              period['period']!,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              period['time']!,
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: isBreak
                              ? Text(
                                  period['subject']!,
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Subject: ${period['subject']}",
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("Teacher: ${period['teacher']}"),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = selectedDay == day;
          return GestureDetector(
            onTap: () {
              setState(() => selectedDay = day);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
