import 'package:flutter/material.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/policyapi.dart';
import 'package:presence/src/features/api/url.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Hrshift extends StatefulWidget {
  const Hrshift({super.key});

  @override
  _HrshiftState createState() => _HrshiftState();
}

class _HrshiftState extends State<Hrshift> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;
  bool _isLoadingHolidays = false;
  String _errorMessage = '';
  Map<DateTime, Map<String, String>> shiftRoster = {};
  Map<DateTime, String> holidays = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchShiftsForDate(_selectedDay!);
    _fetchHolidays(); 
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }


  Future<void> _fetchHolidays() async {
    setState(() {
      _isLoadingHolidays = true;
    });

    try {
      final holidaysData = await PolicyService.fetchPublicHolidays();
      setState(() {
        holidays.clear();
        for (var holiday in holidaysData) {
          final date = DateTime.parse(holiday['date']);
          holidays[_normalizeDate(date)] = holiday['name'];
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching holidays: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingHolidays = false;
      });
    }
  }


  Future<void> _fetchShiftsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final normalizedDate = _normalizeDate(date);
      final formattedDate = "${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}";
      
      final response = await http.get(
        Uri.parse('$BASE_URL/assignview/?date=$formattedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final Map<String, String> shiftsForDate = {};
        
        for (var assignment in data['assignments']) {
          shiftsForDate[assignment['employee_name']] = assignment['shift_type'];
        }
        
        setState(() {
          shiftRoster[normalizedDate] = shiftsForDate;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load shifts: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching shifts: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            if (_isLoading || _isLoadingHolidays) _buildLoadingIndicator(),
            if (_errorMessage.isNotEmpty) _buildErrorWidget(),
            if (_selectedDay != null && !_isLoading && _errorMessage.isEmpty) 
              _buildSelectedDayCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        _errorMessage,
        style: const TextStyle(color: Colors.red),
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
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _fetchShiftsForDate(selectedDay);
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
        holidayTextStyle: const TextStyle(color: Colors.red),
        holidayDecoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 1.5),
        ),
        markersMaxCount: 3,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          bool hasShifts = _hasShiftRoster(day);
          bool isHoliday = _isHoliday(day);
          final holidayName = holidays[_normalizeDate(day)];
          
          if (isHoliday) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.day.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                  if (holidayName != null)
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
          } else if (hasShifts) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Text(
                day.day.toString(),
                style: const TextStyle(color: Colors.blueAccent),
              ),
            );
          }
          return null;
        },
        holidayBuilder: (context, day, focusedDay) {
          final holidayName = holidays[_normalizeDate(day)];
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.day.toString(),
                  style: const TextStyle(
                    color: Colors.red, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                if (holidayName != null)
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
      ),
      holidayPredicate: (day) {
        return _isHoliday(day);
      },
    );
  }

  Widget _buildSelectedDayCard() {
    final holidayName = holidays[_normalizeDate(_selectedDay!)];
    
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
                    "Holiday: ${holidayName ?? ''}",
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