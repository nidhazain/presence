import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/api.dart';
import 'package:presence/src/features/api/employee/policyapi.dart';
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
  Map<DateTime, String> _shiftDataMap = {}; 
  Map<DateTime, List<dynamic>> _colleaguesMap = {}; 
  bool _isLoadingHolidays = false;
  String? _holidaysError;
  Map<DateTime, String> holidays = {};
  Map<String, Color> _shiftColors = {}; // To store color mapping from backend

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchInitialData();
    _fetchHolidays();
    _initializeDefaultColors();
  }

  void _initializeDefaultColors() {

    _shiftColors = {
      'morning': const Color.fromARGB(255, 30, 123, 236),
      'intermediate': const Color.fromARGB(255, 40, 107, 37),
      'night': const Color.fromARGB(255, 208, 9, 208),
      'general': const Color.fromARGB(255, 221, 14, 73),
    };
  }

  Future<void> _fetchHolidays() async {
    setState(() {
      _isLoadingHolidays = true;
      _holidaysError = null;
    });
    
    try {
      final holidaysData = await PolicyService.fetchPublicHolidays();
      setState(() {
        holidays.clear();
        for (var holiday in holidaysData) {
          final date = DateTime.parse(holiday['date']);
          holidays[_normalizeDate(date)] = holiday['name'];
        }
        _isLoadingHolidays = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHolidays = false;
        _holidaysError = 'Failed to load holidays';
      });
      print('Error fetching holidays: $e');
    }
  }

  bool _checkHoliday(DateTime day) {
    return holidays.containsKey(_normalizeDate(day));
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _fetchInitialData() async {
    await _fetchShiftDataForDay(_selectedDay!);
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    await _fetchShiftsForRange(firstDay, lastDay);
  }

Future<void> _fetchShiftsForRange(DateTime start, DateTime end) async {
  String? token = await TokenService.getAccessToken();
  
  try {
    final url = '$BASE_URL/shiftcolor/?start_date=${_formatDate(start)}&end_date=${_formatDate(end)}';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> shiftDates = responseData['shift_dates'] ?? [];
      
      setState(() {
        _shiftDataMap.clear();
        
        for (var dayData in shiftDates) {
          if (dayData['date'] != null) {
            final date = DateTime.parse(dayData['date']);
            final shifts = dayData['shifts'] as Map<String, dynamic>?;
            
            if (shifts != null && shifts.isNotEmpty) {
              // Get the first shift in the shifts map
              final firstShift = shifts.values.first;
              if (firstShift['shift_type'] != null) {
                _shiftDataMap[_normalizeDate(date)] = firstShift['shift_type'];
              }
            }
          }
        }
      });
    } else {
      print('Failed to fetch shift range: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching shift range: $error');
   // print('Response body: ${response?.body}'); // Add this to see the actual response
  }
}

  Future<void> _fetchShiftDataForDay(DateTime day) async {
    String? token = await TokenService.getAccessToken();
    final String formattedDate = _formatDate(day);

    try {
      final url = '$BASE_URL/shift-colleagues/$formattedDate/';

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
          
          final normalizedDate = _normalizeDate(day);
          if (_selectedDayShiftData != null && _selectedDayShiftData!['shift_type'] != null) {
            _shiftDataMap[normalizedDate] = _selectedDayShiftData!['shift_type'];
            _colleaguesMap[normalizedDate] = _colleagues;
          }
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

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Color _getShiftColor(String? shift) {
    if (shift == null) return primary;
    final shiftLower = shift.toLowerCase();
    return _shiftColors[shiftLower] ?? primary;
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
            _buildSelectedDayCard(),
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
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
        final lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);
        _fetchShiftsForRange(firstDay, lastDay);
      },
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        if (_colleaguesMap.containsKey(_normalizeDate(selectedDay))) {
          setState(() {
            _colleagues = _colleaguesMap[_normalizeDate(selectedDay)]!;
            _selectedDayShiftData = _colleagues.isNotEmpty ? _colleagues.first : null;
            _isHoliday = _checkHoliday(selectedDay);
          });
        } else {
          _fetchShiftDataForDay(selectedDay);
        }
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
        ),
        holidayTextStyle: const TextStyle(color: Colors.red),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          final normalizedDate = _normalizeDate(date);
          final isHoliday = _checkHoliday(date);
          final shift = _shiftDataMap[normalizedDate];
          final holidayName = holidays[normalizedDate];
          
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            // decoration: BoxDecoration(
            //   shape: BoxShape.circle,
            //   color: isHoliday 
            //       ? Colors.red.withOpacity(0.1)
            //       : (shift != null ? _getShiftColor(shift).withOpacity(0.2) : null),
            // ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isHoliday 
                        ? Colors.red 
                        : (shift != null ? _getShiftColor(shift) : null),
                  ),
                ),
                if (isHoliday && holidayName != null)
                  Text(
                    holidayName.split(' ')[0],
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 8,
                    ),
                  ),
              ],
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
          final normalizedDate = _normalizeDate(date);
          final isHoliday = _checkHoliday(date);
          final shift = _shiftDataMap[normalizedDate];
          
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHoliday
                  ? Colors.red.withOpacity(0.2)
                  : (shift != null ? _getShiftColor(shift).withOpacity(0.7) : primary.withOpacity(0.7)),
              border: Border.all(
                color: isHoliday ? Colors.red : (shift != null ? _getShiftColor(shift) : primary),
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
          final normalizedDate = _normalizeDate(date);
          final isHoliday = _checkHoliday(date);
          final shift = _shiftDataMap[normalizedDate];
          
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHoliday 
                  ? Colors.red.withOpacity(0.7) 
                  : (shift != null ? _getShiftColor(shift).withOpacity(0.7) : Colors.blueAccent),
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
    final normalizedDate = _normalizeDate(_selectedDay!);
    final String currentShift = _selectedDayShiftData?['shift_type']?.toString() ?? 
                              _shiftDataMap[normalizedDate] ?? 
                              'No';
    final bool isToday = isSameDay(_selectedDay!, DateTime.now());
    final List<dynamic> colleaguesToShow = _colleagues.isNotEmpty 
        ? _colleagues 
        : _colleaguesMap[normalizedDate] ?? [];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card.outlined(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: _isHoliday ? Colors.red : _getShiftColor(currentShift),
              width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        color: (_isHoliday ? Colors.red : _getShiftColor(currentShift))
            .withOpacity(.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  isToday
                      ? "Today's: ${currentShift.toLowerCase() == 'general' ? 'General' : currentShift}"
                      : "${currentShift.toLowerCase() == 'general' ? 'General' : currentShift} shift",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  _selectedDay!.toLocal().toString().split(' ')[0],
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
                            "Holiday: ${holidays[normalizedDate] ?? ''}",
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
              if (currentShift != 'No Shift')
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: () => _showColleaguesDialog(colleaguesToShow, currentShift),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: _getShiftColor(currentShift)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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

  void _showColleaguesDialog(List<dynamic> colleagues, String currentShift) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: CustomTitleText8(text: "Colleagues in $currentShift shift"),
          content: colleagues.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: colleagues.map((colleague) {
                    final String name =
                        colleague['employee_name']?.toString() ?? 'Unknown';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _getShiftColor(currentShift).withOpacity(0.2),
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