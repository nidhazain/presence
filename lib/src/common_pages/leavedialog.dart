import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/submitbutton.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/models/leave.dart';

String _calculateLeaveDays(String start, String? end) {
  try {
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(start);
    if (end == null || end.isEmpty) {
      return "1";
    }
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(end);
    if (endDate.isBefore(startDate)) return "0";
    return (endDate.difference(startDate).inDays + 1).toString();
  } catch (e) {
    return "0";
  }
}

String formatDate(String dateStr) {
  try {
    final DateTime date = DateFormat('yyyy-MM-dd').parse(dateStr);
    return DateFormat('dd MMM yyyy').format(date);
  } catch (e) {
    return dateStr;
  }
}

void _showFullSizeImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text('Failed to load image'),
                ),
              ),
            ),
          ),
          Positioned(
            top: -16,
            right: -16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              radius: 16,
              child: IconButton(
                icon: Icon(Icons.close, size: 16, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void showLeaveDetailsDialog(BuildContext context, Leave leave) {
  // Do the print checks before building the dialog widget
  if (leave.imageUrl != null && leave.imageUrl!.trim().isNotEmpty) {
    print("Final Image URL being used: ${leave.imageUrl}");
  } else {
    print("No image URL found in leave object!");
  }

  final String leaveDays = _calculateLeaveDays(leave.startDate, leave.endDate);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(leave.type, style: TextStyle(fontWeight: FontWeight.bold)),
          CloseButton(onPressed: () => Navigator.pop(context)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTitleText10(text: "Status: "),
              textfield(data: leave.status),
              CustomTitleText10(text: "Date:"),
              textfield(
                data: leave.endDate != null
                    ? "${formatDate(leave.startDate)} to ${formatDate(leave.endDate!)}"
                    : formatDate(leave.startDate),
              ),
              CustomTitleText10(text: "Number of Days:"),
              textfield(data: leaveDays),
              CustomTitleText10(text: "Reason:"),
              textfield(data: leave.reason),
              if (leave.imageUrl != null && leave.imageUrl!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Attachment:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          print("Image path (onTap): ${leave.imageUrl}");
                          _showFullSizeImage(context, leave.imageUrl!);
                        },
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              leave.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print("Image loading error: $error");
                                return Container(
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text('Failed to load image'),
                                      if (error != null)
                                        Text(
                                          error.toString(),
                                          style: TextStyle(fontSize: 10),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (leave.status.toLowerCase() == 'pending')
                CustomButton(
                  text: "Delete Request",
                  onPressed: () {},
                ),
            ],
          ),
        ),
      ),
    ),
  );
}


