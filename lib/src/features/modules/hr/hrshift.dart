import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class Hrshift extends StatefulWidget {
  const Hrshift({super.key});

  @override
  _HrshiftState createState() => _HrshiftState();
}

class _HrshiftState extends State<Hrshift> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // Ensure today's card is visible initially
  }

  // Shift roster data - would typically come from a database or API
  final Map<DateTime, Map<String, String>> shiftRoster = {
    DateTime(2025, 3, 3): {
      "Alice": "Morning",
      "John": "Morning",
      "Bob": "Night",
      "Charlie": "Intermediate"
    },
    DateTime(2025, 3, 4): {
      "David": "Morning",
      "Eve": "Intermediate",
      "Frank": "Night"
    },
    DateTime(2025, 3, 5): {
      "Alice": "Night",
      "Bob": "Morning",
      "Charlie": "Intermediate"
    },
    DateTime(2025, 3, 6): {
      "George": "Intermediate",
      "Helen": "Morning",
      "Ian": "Night"
    },
    DateTime(2025, 3, 7): {
      "Jack": "Morning",
      "Karen": "Night",
      "Leo": "Intermediate"
    },
    DateTime(2025, 3, 8): {
      "Mike": "Morning",
      "Nina": "Intermediate",
      "Olivia": "Night"
    },
    DateTime(2025, 3, 10): {
      "Steve": "Morning",
      "Tina": "Intermediate",
      "Uma": "Night"
    },
    DateTime(2025, 3, 31): {
      "Steve": "Morning",
      "Tina": "Intermediate",
      "Uma": "Night"
    },
  };

  // Public holidays - would typically come from a database or API
  final Map<DateTime, List<String>> holidays = {
    DateTime(2025, 1, 26): ['Republic Day'],
    DateTime(2025, 8, 15): ['Independence Day'],
    DateTime(2025, 3, 31): ['Eid'],
    DateTime(2025, 4, 14): ['Tamil New Year'],
    DateTime(2025, 12, 25): ['Christmas'],
  };

  /// Normalizes date by removing time portion for comparison
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Gets organized shifts for a specific day
  Map<String, List<String>> _getShiftsForDay(DateTime day) {
    var normalizedDate = _normalizeDate(day);
    Map<String, List<String>> shifts = {
      "Morning": [],
      "Intermediate": [],
      "Night": []
    };
    if (shiftRoster.containsKey(normalizedDate)) {
      shiftRoster[normalizedDate]?.forEach((employee, shift) {
        shifts[shift]?.add(employee);
      });
    }
    return shifts;
  }

  /// Checks if a day is a holiday
  bool _isHoliday(DateTime day) {
    return holidays.containsKey(_normalizeDate(day));
  }

  /// Checks if a day has shift roster assigned
  bool _hasShiftRoster(DateTime day) {
    return shiftRoster.containsKey(_normalizeDate(day));
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            _buildCalendar(),
            SizedBox(height: screenHeight * 0.02),
            if (_selectedDay != null) _buildSelectedDayCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime(2024, 1, 1),
      lastDay: DateTime(2025, 12, 31),
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        });
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        // Mark holidays in red
        holidayTextStyle: const TextStyle(color: Colors.red),
        holidayDecoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 1.5),
        ),
        // Custom cell styling based on day properties
        markersMaxCount: 3,
      ),
      // Custom calendar builders for special date styling
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          // Check if day has shifts or is a holiday
          bool hasShifts = _hasShiftRoster(day);
          bool isHoliday = _isHoliday(day);
          
          if (isHoliday) {
            // Red styling for holidays
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 1.5),
              ),
              child: Text(
                day.day.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (hasShifts) {
            // Blue styling for days with shift roster
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              
              child: Text(
                day.day.toString(),
                style: const TextStyle(color: Colors.blueAccent),
              ),
            );
          }
          return null; // Return null for default styling
        },
        holidayBuilder: (context, day, focusedDay) {
          // Additional customization for holidays if needed
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            
            child: Text(
              day.day.toString(),
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      // Mark holidays in the calendar
      holidayPredicate: (day) {
        return _isHoliday(day);
      },
    );
  }

  Widget _buildSelectedDayCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card.outlined(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: _isHoliday(_selectedDay!) ? Colors.red : Colors.blue, 
            width: 1.5
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        color: (_isHoliday(_selectedDay!) ? Colors.red : blue).withOpacity(.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  _selectedDay == _normalizeDate(DateTime.now())
                      ? "Today's Shifts"
                      : "Shifts on ${_selectedDay!.toLocal().toString().split(' ')[0]}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (_isHoliday(_selectedDay!))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Holiday: ${holidays[_normalizeDate(_selectedDay!)]?.join(', ')}",
                    style: const TextStyle(
                      color: Colors.red, 
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ..._buildShiftSections(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildShiftSections() {
    return _getShiftsForDay(_selectedDay!).entries.map((entry) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
          child: Text(
            "${entry.key} Shift",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14, 
              color: primary
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Text(
            entry.value.isNotEmpty 
                ? entry.value.join(", ") 
                : "No employees assigned", 
            style: const TextStyle(fontSize: 14)
          ),
        ),
        const Divider(height: 8),
      ],
    )).toList();
  }
}