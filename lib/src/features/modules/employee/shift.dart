import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:table_calendar/table_calendar.dart';

class ShiftCalendarScreen extends StatefulWidget {
  const ShiftCalendarScreen({super.key});

  @override
  _ShiftCalendarScreenState createState() => _ShiftCalendarScreenState();
}

class _ShiftCalendarScreenState extends State<ShiftCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, dynamic>? _selectedDayShiftData;
  List<dynamic> _colleagues = [];
  bool _isHoliday = false; 

  final Map<DateTime, List<String>> holidays = {
    DateTime(2025, 1, 26): ['Republic Day'],
    DateTime(2025, 8, 15): ['Independence Day'],
    DateTime(2025, 3, 31): ['Eid'],
    DateTime(2025, 4, 14): ['Tamil New Year'],
    DateTime(2025, 12, 25): ['Christmas'],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchShiftDataForDay(_selectedDay!);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
 
  bool _checkHoliday(DateTime day) {
    return holidays.containsKey(_normalizeDate(day));
  }

  Future<void> _fetchShiftDataForDay(DateTime day) async {
    String? token = await TokenService.getAccessToken(); 

 
    final String formattedDate =
        "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    try {
      final String url;
      if (isSameDay(day, DateTime.now())) {
        url = '$BASE_URL/employee-shifts/'; 
      } else {
        url = '$BASE_URL/shift-colleagues/$formattedDate/'; 
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _selectedDayShiftData = (data is List && data.isNotEmpty) ? data.first : null;
          _colleagues = data;
          _isHoliday = _checkHoliday(day);
        });
      } else {
        setState(() {
          _selectedDayShiftData = null;
          _colleagues = [];
          _isHoliday = _checkHoliday(day);
        });
      }
    } catch (error) {
      setState(() {
        _selectedDayShiftData = null;
        _colleagues = [];
        _isHoliday = _checkHoliday(day);
      });
    }
  }

  Color _getShiftColor(String? shift) {
    switch (shift) {
      case 'morning'&& 'Morning':
        return const Color.fromARGB(255, 54, 144, 240);
      case 'Night':
        return const Color.fromARGB(255, 167, 69, 243);
      case 'Intermediate':
        return const Color.fromARGB(255, 55, 169, 59);
      default:
        return primary;
    }
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
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        _fetchShiftDataForDay(selectedDay);
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
        holidayTextStyle: const TextStyle(color: Colors.red),
        markerDecoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          bool isHoliday = _checkHoliday(date);
          String? shift;
          if (isSameDay(date, _selectedDay) && _selectedDayShiftData != null) {
            shift = _selectedDayShiftData!['shift_type'];
          }
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHoliday ? Colors.red : _getShiftColor(shift),
              ),
            ),
          );
        },
        holidayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        todayBuilder: (context, date, _) {
          bool isHoliday = _checkHoliday(date);
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHoliday ? Colors.red.withOpacity(0.2) : primary.withOpacity(0.7),
              border: Border.all(
                color: isHoliday ? Colors.red : primary,
                width: 1.5,
              ),
            ),
            child: Text(
              '${date.day}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        selectedBuilder: (context, date, _) {
          bool isHoliday = _checkHoliday(date);
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHoliday ? Colors.red.withOpacity(0.7) : Colors.blueAccent,
            ),
            child: Text(
              '${date.day}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      holidayPredicate: (day) => _checkHoliday(day),
    );
  }

  Widget _buildSelectedDayCard() {
    final String currentShift = _selectedDayShiftData?['shift_type']?.toString() ?? 'No Shift';
    final bool isToday = isSameDay(_selectedDay!, DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card.outlined(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: _isHoliday
                  ? Colors.red
                  // ignore: unnecessary_null_comparison
                  : (currentShift != null ? _getShiftColor(currentShift) : Colors.blue),
              width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        color: (_isHoliday
                ? Colors.red
                // ignore: unnecessary_null_comparison
                : (currentShift != null ? _getShiftColor(currentShift) : blue))
            .withOpacity(.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  isToday
                      ? "Today's Shift: $currentShift"
                      : "$currentShift shift",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  isToday ? "Today" : _selectedDay!.toLocal().toString().split(' ')[0],
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (_isHoliday)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.celebration, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Holiday: ${holidays[_normalizeDate(_selectedDay!)]?.join(', ') ?? ''}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (currentShift != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: _showColleaguesDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: _getShiftColor(currentShift)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    label: const Text('View Colleagues'),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showColleaguesDialog() {
    final String currentShift = _selectedDayShiftData?['shift_type']?.toString() ?? 'No Shift';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: CustomTitleText8(text: "Colleagues in $currentShift shift"),
          content: _colleagues.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _colleagues.map((colleague) {
                    final String name = colleague['employee_name']?.toString() ?? 'Unknown';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getShiftColor(currentShift).withOpacity(0.2),
                        child: Text(
                          name[0],
                          style: TextStyle(
                            color: _getShiftColor(currentShift),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(name),
                    );
                  }).toList(),
                )
              : CustomTitleText9(text: "No colleagues assigned to this shift."),
          actions: [
            CustomButton(
              text: 'Close',
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
