import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  late DateTime today;
  late CalendarFormat format;
  late DateTime selectedDay;
  late DateTime focusedDay;
  late Map<DateTime, List<Event>> events = {};

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    selectedDay = today;
    focusedDay = today;
    format = CalendarFormat.month;
    _loadEvents();
  }

  void _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      Map<String, dynamic> decoded = jsonDecode(eventsJson);
      Map<DateTime, List<Event>> temp = {};
      decoded.forEach((key, value) {
        temp[DateTime.parse(key)] =
            (value as List).map((e) => Event.fromJson(e)).toList();
      });
      setState(() {
        events = temp;
      });
    }
  }

  void _saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('events', jsonEncode(_encodeMap(events)));
    _loadEvents();
  }

  Map<String, dynamic> _encodeMap(Map<DateTime, List<Event>> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = value.map((e) => e.toJson()).toList();
    });
    return newMap;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = focusedDay;
    });
  }

  void _addEvent(DateTime day) async {
    final newEvent = await showDialog<Event?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty ||
                    noteController.text.isNotEmpty) {
                  final newEvent = Event(
                    date: day,
                    title: titleController.text,
                    note: noteController.text,
                  );
                  _saveEvents();
                  Navigator.of(context).pop(newEvent);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (newEvent != null) {
      setState(() {
        if (events[day] != null) {
          events[day]!.add(newEvent);
        } else {
          events[day] = [newEvent];
        }
      });
      _saveEvents();
    }
  }

  void _deleteEvent(Event event, DateTime day) {
    setState(() {
      events[day]!.remove(event);
    });
    _saveEvents();
  }

  void _showEventDetails(Event event, DateTime day) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Date: ${DateFormat.yMMMd().format(DateTime.parse(event.date.toString()))}'),
              const SizedBox(height: 8),
              Text('Note: ${event.note}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _deleteEvent(event, day);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white24,
        shape: const CircleBorder(),
        onPressed: () {
          _addEvent(selectedDay);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Daily Plan"),
      ),
      body: content(),
    );
  }

  Widget content() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TableCalendar(
            locale: "en_US",
            rowHeight: 43,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarFormat: format,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
              CalendarFormat.week: 'Week',
            },
            onFormatChanged: (CalendarFormat format) {
              setState(() {
                format = format;
              });
            },
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            focusedDay: focusedDay,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            onDaySelected: _onDaySelected,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: true,
              markerDecoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              selectedDecoration:
                  BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
              todayDecoration:
                  BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(
                color: Colors.red,
              ),
            ),
            eventLoader: (day) {
              return events[day] ?? [];
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: events[selectedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                final event = events[selectedDay]![index];
                return GestureDetector(
                  onTap: () {
                    _showEventDetails(event, selectedDay);
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(event.title),
                      subtitle: Text(
                        DateFormat.yMMMd()
                            .format(DateTime.parse(event.date.toString())),
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
}

class Event {
  final DateTime date;
  final String title;
  final String note;

  Event({required this.date, required this.title, required this.note});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      date: DateTime.parse(json['date']),
      title: json['title'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'title': title,
      'note': note,
    };
  }
}
