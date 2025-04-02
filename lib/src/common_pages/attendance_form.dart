import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/attendanceapi.dart';
import 'package:presence/src/validations/validation.dart';

class RequestAttendanceDialog extends StatefulWidget {
  @override
  _RequestAttendanceDialogState createState() =>
      _RequestAttendanceDialogState();
}

class _RequestAttendanceDialogState extends State<RequestAttendanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  TextEditingController dateController = TextEditingController();
  TextEditingController checkInController = TextEditingController();
  TextEditingController checkOutController = TextEditingController();
  TextEditingController workTypeController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  String _selectedProofType = 'Location';
  File? _imageFile;
  bool _isImageCaptured = false;
  String? _selectedWorkType;

  final DateFormat _backendDateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _loadStoredAddress();
    final DateTime now = DateTime.now();
    
    final String displayFormattedDate = _displayDateFormat.format(now);
    
    dateController = TextEditingController(text: displayFormattedDate);
  }

  String getBackendFormattedDate() {
    try {
      final DateTime date = _displayDateFormat.parse(dateController.text);
      return _backendDateFormat.format(date);
    } catch (e) {
      return _backendDateFormat.format(DateTime.now());
    }
  }

  Future<void> _captureImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isImageCaptured = true;
      });
    }
  }

  Future<void> _loadStoredAddress() async {
    String? address = await _storage.read(key: 'address');
    if (address != null && address.isNotEmpty) {
      setState(() {
        locationController.text = address;
      });
    }
  }

  Future<void> _submitAttendanceRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> requestData = {
        'date': getBackendFormattedDate(), 
        'check_in': checkInController.text,
        'check_out': checkOutController.text,
        'work_type': workTypeController.text,
      };
      if (_selectedProofType.toLowerCase() == 'location') {
        requestData['location'] = locationController.text;
      } else if (_selectedProofType.toLowerCase() == 'image' &&
          _imageFile != null) {
        requestData['image'] = _imageFile!.path;
      }

      bool success = await AttendanceService.submitAttendanceRequest(
        requestData,
        imageFile: _imageFile,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(success
                ? 'Submitted successfully'
                : 'Failed to submit attendance request')),
      );

      if (success) {
        _clearForm();
        Navigator.of(context).pop();
      }
    }
  }

  String formatTimeOfDayTo24Hour(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Container(
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTitleText8(text: 'Attendance Request'),
                    IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTitleText10(text: 'Date'),
                      _buildDateField(),
                      SizedBox(height: 16),
                      CustomTitleText10(text: 'Check In'),
                      _buildTimeField(checkInController, 'Check-In Time'),
                      SizedBox(height: 16),
                      CustomTitleText10(text: 'Check Out'),
                      _buildTimeField(checkOutController, 'Check-Out Time'),
                      SizedBox(height: 16),
                      CustomTitleText10(text: 'Type of Work'),
                      _buildWorkField(),
                      SizedBox(height: 16),
                      _buildProofField(),
                      SizedBox(height: 20),
                      _buildButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateCheckInTime(String? value) {
  if (value == null || value.isEmpty) {
    return 'Check-in time is required';
  }
  try {
    final timeParts = value.split(':').map((e) => int.parse(e)).toList();
    final selectedDate = _displayDateFormat.parse(dateController.text);
    final DateTime checkInDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      timeParts[0],
      timeParts[1],
    );
    final DateTime now = DateTime.now();
    // Only check if the selected date is today.
    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day &&
        checkInDateTime.isAfter(now)) {
      return 'Check-in time cannot be in the future';
    }
  } catch (e) {
    return 'Invalid time format';
  }
  return null;
}

String? _validateCheckOutTime(String? value) {
  if (value == null || value.isEmpty) {
    return 'Check-out time is required';
  }
  try {
    final timeParts = value.split(':').map((e) => int.parse(e)).toList();
    final selectedDate = _displayDateFormat.parse(dateController.text);
    final DateTime checkOutDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      timeParts[0],
      timeParts[1],
    );
    final DateTime now = DateTime.now();
    // Only check if the selected date is today.
    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day &&
        checkOutDateTime.isAfter(now)) {
      return 'Check-out time cannot be in the future';
    }
    // Also ensure check-out isn't before check-in (if provided).
    if (checkInController.text.isNotEmpty) {
      final checkInParts =
          checkInController.text.split(':').map((e) => int.parse(e)).toList();
      final DateTime checkInDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        checkInParts[0],
        checkInParts[1],
      );
      if (checkOutDateTime.isBefore(checkInDateTime)) {
        return 'Check-out cannot be before check-in!';
      }
    }
  } catch (e) {
    return 'Invalid time format';
  }
  return null;
}


  // Add date picker field
  Widget _buildDateField() {
    return TextFormField(
      controller: dateController,
      readOnly: true,
      validator: ValidationHelper.validateField,
      decoration: InputDecoration(
        filled: true,
        fillColor: primary.withOpacity(.05),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey, size: 20),
        hintText: 'Select Date',
      ),
      onTap: () async {
  final DateTime now = DateTime.now();
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: DateTime(now.year - 1),
    lastDate: now,
  );
  if (picked != null) {
    setState(() {
      dateController.text = _displayDateFormat.format(picked);
    });
  }
},

    );
  }

 Widget _buildTimeField(TextEditingController controller, String hintText) {
  String? validator(String? value) {
    if (controller == checkInController) {
      return _validateCheckInTime(value);
    } else if (controller == checkOutController) {
      return _validateCheckOutTime(value);
    } else {
      return ValidationHelper.validateField(value);
    }
  }

  return TextFormField(
    controller: controller,
    readOnly: true,
    validator: validator,
    decoration: InputDecoration(
      filled: true,
      fillColor: primary.withOpacity(.05),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      suffixIcon: Icon(Icons.timer_outlined, color: Colors.grey, size: 20),
      hintText: hintText,
    ),
    onTap: () async {
      TimeOfDay? pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (pickedTime != null) {
        final formattedTime = formatTimeOfDayTo24Hour(pickedTime);
        setState(() {
          controller.text = formattedTime;
        });
      }
    },
  );
}


  Widget _buildProofField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: _selectedProofType.isNotEmpty ? _selectedProofType : null,
          items: ['Location', 'Image']
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: CustomTitleText10(text: item),
                  ))
              .toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedProofType = newValue!;
            });
          },
        ),
        SizedBox(height: 10),
        if (_selectedProofType == 'Location')
          TextFormField(
            controller: locationController,
            readOnly: true,
            validator: ValidationHelper.validateField,
            decoration: InputDecoration(
              filled: true,
              fillColor: primary.withOpacity(.05),
              hintText: "fetching address...",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          )
        else
          _buildImagePreview(),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
            child: CustomButton(
                text: 'Submit', onPressed: _submitAttendanceRequest)),
      ],
    );
  }

void _clearForm() {
  setState(() {
    final DateTime now = DateTime.now();
    dateController.text = _displayDateFormat.format(now);
    
    checkInController.clear();
    checkOutController.clear();
    workTypeController.clear();
    locationController.clear();
    _imageFile = null;
    _isImageCaptured = false;
    _selectedProofType = 'Location';
    _selectedWorkType = "Work from Home"; 
  });
  //_formKey.currentState?.reset();
}


  Widget _buildWorkField() {
    return DropdownButtonFormField<String>(
  value: _selectedWorkType,
  validator: ValidationHelper.validateField,
  decoration: InputDecoration(
    filled: true,
    fillColor: primary.withOpacity(.05),
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintText: 'Type of work',
  ),
  items: [
    DropdownMenuItem(
      value: "Work from Home",
      child: Text("Work from Home"),
    ),
    DropdownMenuItem(
      value: "Field Work",
      child: Text("Field Work"),
    ),
  ],
  onChanged: (String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedWorkType = newValue;
        workTypeController.text = newValue;
      });
    }
  },
);


  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Column(
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imageFile!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() => _imageFile = null),
            child: Text("Clear Image"),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(150, 36),
            ),
          ),
        ],
      );
    }
    return ElevatedButton.icon(
      onPressed: () async => await _captureImage(),
      icon: Icon(Icons.camera_alt),
      label: Text('Capture Image'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(150, 40),
      ),
    );
  }

  void _showFullScreenImage() {
    if (_imageFile == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                _imageFile!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    checkInController.dispose();
    checkOutController.dispose();
    super.dispose();
  }
}