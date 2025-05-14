import 'package:empowerhr_moblie/data/models/noti_model.dart';
import 'package:empowerhr_moblie/data/service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationListen extends StatefulWidget {
  final Widget child;

  const NotificationListen({Key? key, required this.child}) : super(key: key);

  @override
  _NotificationListenerState createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<NotificationListen> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _listenForNotifications();
  }

  void _listenForNotifications() {
    NotificationService().notificationStream.listen((notifications) {
      if (notifications.isNotEmpty) {
        final latest = notifications.first;
        if (!latest.read) {
          _showPopup(latest);
        }
      }
    });
  }

  void _showPopup(NotificationModel notification) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notification.category,
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (notification.category == 'Meeting')
                      TextButton(
                        onPressed: () {
                          _overlayEntry?.remove();
                          _showMeetingPopup(context, notification);
                        },
                        child: const Text('View Details'),
                      ),
                    TextButton(
                      onPressed: () {
                        _overlayEntry?.remove();
                      },
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 5), () {
      _overlayEntry?.remove();
    });
  }

  void _showMeetingPopup(BuildContext context, NotificationModel notification) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isInitialState = true;
    bool isDeclineState = false;
    bool isDeclineSubmitted = false;
    TextEditingController declineReasonController = TextEditingController();
    String declineReason = '';

    String meetingDetails = notification.description;
    if (notification.data != null) {
      meetingDetails =
          "${notification.data!['inviter'] ?? 'Someone'} invited you to a meeting on ${notification.data!['date'] ?? ''} at ${notification.data!['time'] ?? ''}. Message: “${notification.data!['message'] ?? ''}”";
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 25),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth - 50),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    meetingDetails,
                    style: GoogleFonts.baloo2(
                      textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isInitialState && !isDeclineState && !isDeclineSubmitted)
                    const SizedBox(height: 10),
                  if (!isInitialState && !isDeclineState && !isDeclineSubmitted)
                    Text(
                      "You have accepted this event. Event detail will be added to your calendar",
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (isDeclineState) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: declineReasonController,
                      decoration: InputDecoration(
                        hintText: "Enter your decline reason",
                        hintStyle: GoogleFonts.baloo2(
                          textStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ],
                  if (isDeclineSubmitted) ...[
                    const SizedBox(height: 10),
                    Text(
                      'You have declined this event with reason: “$declineReason”',
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (isInitialState) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInitialState = false;
                              isDeclineState = false;
                              isDeclineSubmitted = false;
                            });
                          },
                          child: Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                "Accept",
                                style: GoogleFonts.baloo2(
                                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 60),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInitialState = false;
                              isDeclineState = true;
                              isDeclineSubmitted = false;
                            });
                          },
                          child: Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                "Decline",
                                style: GoogleFonts.baloo2(
                                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (isDeclineState) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              declineReason = declineReasonController.text;
                              isDeclineState = false;
                              isDeclineSubmitted = true;
                            });
                          },
                          child: Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                "Submit",
                                style: GoogleFonts.baloo2(
                                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInitialState = true;
                              isDeclineState = false;
                              isDeclineSubmitted = false;
                            });
                          },
                          child: Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                "Back",
                                style: GoogleFonts.baloo2(
                                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            "Close",
                            style: GoogleFonts.baloo2(
                              textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}