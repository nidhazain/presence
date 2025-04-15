import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/leaveapi.dart';
import 'package:presence/src/validations/validation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LeaveForm extends StatefulWidget {
  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  final _formKey = GlobalKey<FormState>();
  final _storage = FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _selectedLeaveType;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _leaveDaysController = TextEditingController();
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _leaveTypes = [];
  bool _isLoading = true;
  File? _selectedImage;
  final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _backendDateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _fetchLeaveTypes();
  }

  Future<void> _fetchLeaveTypes() async {
    try {
      String? token = await _storage.read(key: 'access');
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unauthorized: No token found')),
          );
        }
        return;
      }
      List<Map<String, dynamic>> fetchedLeaveTypes =
          await LeaveService.getLeaveTypes(token);

      if (mounted) {
        setState(() {
          _leaveTypes = fetchedLeaveTypes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching leave types')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedImage != null && mounted) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTitleText10(text: 'Select Image Source'),
              CloseButton(onPressed: () => Navigator.pop(context)),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Gallery'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Camera'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _selectedImage == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No image selected',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _selectedImage = null;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 20, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedLeaveType,
      decoration: InputDecoration(
        filled: true,
        fillColor: primary.withOpacity(.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      icon: Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
      hint: Text("Select type"),
      items: _leaveTypes.map((type) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: type,
          child: Text(type["name"]),
        );
      }).toList(),
      validator: (value) => value == null ? "Please select a leave type" : null,
      onChanged: (Map<String, dynamic>? newValue) {
        if (mounted) {
          setState(() {
            _selectedLeaveType = newValue;
          });
        }
      },
    );
  }

  void _clearForm() {
    print('pressed');
    if (mounted) {
      setState(() {
        _selectedLeaveType = null;
        _startDateController.clear();
        _endDateController.clear();
        _reasonController.clear();
        _selectedImage = null;
        _leaveDaysController.clear();
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() => _isSubmitting = true);
      }
      String? token = await _storage.read(key: 'access');
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unauthorized: No token found')),
          );
          setState(() => _isSubmitting = false);
        }
        return;
      }

      // Convert display dates to backend format
      String startDate = _backendDateFormat
          .format(_displayDateFormat.parse(_startDateController.text));
      String endDate = _backendDateFormat
          .format(_displayDateFormat.parse(_endDateController.text));

      final response = await LeaveService.submitLeaveRequest(
        token: token,
        startDate: startDate, // Now in yyyy-MM-dd format
        endDate: endDate, // Now in yyyy-MM-dd format
        leaveType: _selectedLeaveType != null
            ? _selectedLeaveType!["id"].toString()
            : "",
        reason: _reasonController.text,
        image: _selectedImage,
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
      }

      if (response.containsKey('error')) {
        if (response['error'] ==
            'You already have a leave request for this date range!') {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Validation Error'),
                content: Text(response['error']),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['error'])),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Leave request submitted successfully')),
          );
          _clearForm();
        }
      }
    }
  }

  int? _calculateLeaveDays() {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      return null;
    }
    try {
      DateTime startDate = _displayDateFormat.parse(_startDateController.text);
      DateTime endDate = _displayDateFormat.parse(_endDateController.text);
      if (endDate.isBefore(startDate)) return null;
      return endDate.difference(startDate).inDays + 1;
    } catch (e) {
      return null;
    }
  }

  void _updateLeaveDays() {
    int? days = _calculateLeaveDays();
    if (mounted) {
      setState(() {
        _leaveDaysController.text = days != null ? days.toString() : '';
      });
    }
  }

  Widget _buildLeaveDaysField() {
    return TextFormField(
      controller: _leaveDaysController,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: primary.withOpacity(.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        hintText: 'Number of Leave Days',
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String hintText) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: primary.withOpacity(.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
        hintText: hintText,
      ),
      validator: (value) {
        String? baseValidation = ValidationHelper.validateField(value);
        if (baseValidation != null) {
          return baseValidation;
        }
        if (controller == _endDateController &&
            _startDateController.text.isNotEmpty) {
          try {
            DateTime startDate =
                _displayDateFormat.parse(_startDateController.text);
            DateTime endDate = _displayDateFormat.parse(value!);
            if (endDate.isBefore(startDate)) {
              return 'End date cannot be before start date';
            }
          } catch (e) {
            return 'Invalid date format';
          }
        }
        return null;
      },
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null && mounted) {
          setState(() {
            controller.text = _displayDateFormat.format(pickedDate);
          });
          _updateLeaveDays();
        }
      },
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _reasonController,
      minLines: 3,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        filled: true,
        fillColor: primary.withOpacity(.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        hintText: "Enter your reason",
      ),
      validator: ValidationHelper.validateField,
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: CustomButton(
            text: 'Clear',
            onPressed: _clearForm,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: _isSubmitting ? 'Submitting...' : 'Submit',
            onPressed: _isSubmitting ? () async {} : _submitForm,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTitleText9(text: 'Start Date'),
                _buildDateField(_startDateController, 'Select Start Date'),
                SizedBox(height: 16),
                CustomTitleText9(text: 'End Date'),
                _buildDateField(_endDateController, 'Select End Date'),
                SizedBox(height: 16),
                // Automatically updated leave days field
                CustomTitleText9(text: 'Number of Leave'),
                _buildLeaveDaysField(),
                SizedBox(height: 16),
                CustomTitleText9(text: 'Leave Type'),
                _buildDropdown(),
                SizedBox(height: 16),
                CustomTitleText9(text: 'Reason'),
                _buildReasonField(),
                SizedBox(height: 16),
                CustomTitleText9(text: 'Supporting Document'),
                SizedBox(height: 8),
                _buildImagePreview(),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: Icon(Icons.add_a_photo),
                  label: Text(
                      _selectedImage == null ? 'Add Image' : 'Change Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
