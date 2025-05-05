import 'dart:convert';
import 'package:empowerhr_moblie/data/service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final SocketService _socketService = SocketService(); // Khởi tạo SocketService
  String? _employeeID;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _loadInitialNotifications();
  }

  Future<void> _connectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    _employeeID = prefs.getString('employeeID');
    if (_employeeID == null) {
      print('Không tìm thấy employeeID trong SharedPreferences');
      setState(() => _isLoading = false);
      return;
    }

    _socketService.connect(_employeeID!);

    _socketService.onMessage((data) {
      final notificationType = data['type'];
      final messageContent = data['message'];
      final additionalData = data['data'];

      setState(() {
        _notifications.insert(0, {
          'category': notificationType,
          'description': messageContent,
          'hour': _formatTime(DateTime.now()),
          'date': _formatDate(DateTime.now()),
          'color': _getColorForCategory(notificationType),
        });
      });

      if (notificationType == 'Meeting') {
        showMeetingPopup(
          context,
          MediaQuery.of(context).size.width,
          messageContent,
          additionalData,
        );
      }
    });

    setState(() => _isLoading = false);
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute$period';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString().substring(2);
    return '$day/$month/$year';
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Meeting':
        return Colors.red;
      case 'Performance report':
        return Colors.green;
      case 'Password change':
        return Colors.orange;
      case 'Absence request':
        return Colors.purple;
      case 'Event notification':
        return Colors.cyan;
      default:
        return Colors.blue;
    }
  }

  void _loadInitialNotifications() {
    _notifications = [
      {
        'category': 'Meeting',
        'description': 'Your absence ticket has been approved',
        'hour': '18:20AM',
        'date': '22/02/25',
        'color': Colors.red,
      },
      {
        'category': 'Performance report',
        'description': 'Your performance report of Jan 2025',
        'hour': '10:30AM',
        'date': '22/02/25',
        'color': Colors.green,
      },
      {
        'category': 'Performance report',
        'description': 'You have successfully submit your ...',
        'hour': '18:20AM',
        'date': '19/02/25',
        'color': Colors.blue,
      },
      {
        'category': 'Password change',
        'description': 'Your password has successfully changed',
        'hour': '10:20AM',
        'date': '17/02/25',
        'color': Colors.orange,
      },
      {
        'category': 'Absence request',
        'description': 'Your absence ticket has been approved',
        'hour': '10:20AM',
        'date': '20/01/25',
        'color': Colors.purple,
      },
      {
        'category': 'Performance report',
        'description': 'Your performance report of Jan 2025',
        'hour': '10:30AM',
        'date': '20/01/25',
        'color': Colors.teal,
      },
      {
        'category': 'Performance report',
        'description': 'You have successfully submit your ...',
        'hour': '18:20AM',
        'date': '18/01/25',
        'color': Colors.yellow,
      },
      {
        'category': 'Password change',
        'description': 'Your password has successfully changed',
        'hour': '10:20AM',
        'date': '17/01/25',
        'color': Colors.pink,
      },
      {
        'category': 'Event notification',
        'description': 'You have been invited to a new event',
        'hour': '18:20AM',
        'date': '17/01/25',
        'color': Colors.cyan,
      },
    ];
  }

  void showMeetingPopup(
      BuildContext context, double screenWidth, String message, dynamic data) {
    bool isInitialState = true;
    bool isDeclineState = false;
    bool isDeclineSubmitted = false;
    TextEditingController declineReasonController = TextEditingController();
    String declineReason = '';

    String meetingDetails = message;
    if (data != null) {
      meetingDetails =
          "${data['inviter'] ?? 'Someone'} invited you to a meeting on ${data['date'] ?? ''} at ${data['time'] ?? ''}. Message: “${data['message'] ?? ''}”";
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 25),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth - 50,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    meetingDetails,
                    style: GoogleFonts.baloo2(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isInitialState &&
                      !isDeclineState &&
                      !isDeclineSubmitted) ...[
                    const SizedBox(height: 10),
                    Text(
                      "You have accepted this event. Event detail will be added to your calendar",
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (isDeclineState) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: declineReasonController,
                      decoration: InputDecoration(
                        hintText: "Enter your decline reason",
                        hintStyle: GoogleFonts.baloo2(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                  if (isDeclineSubmitted) ...[
                    const SizedBox(height: 10),
                    Text(
                      'You have declined this event with reason: “$declineReason”',
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
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
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
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
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
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
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
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
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
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
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: 120.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background_notification.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          itemCount: _notifications.length,
                          separatorBuilder: (context, index) => const Divider(
                            thickness: 1,
                          ),
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return GestureDetector(
                              onTap: () {
                                if (notification['category'] == 'Meeting') {
                                  showMeetingPopup(
                                    context,
                                    screenWidth,
                                    notification['description'],
                                    null,
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notification['category'],
                                                style: GoogleFonts.baloo2(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                notification['description'],
                                                style: GoogleFonts.baloo2(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: notification['color'],
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            Text(
                                              notification['hour'],
                                              style: GoogleFonts.baloo2(
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              notification['date'],
                                              style: GoogleFonts.baloo2(
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
          ),
          SliverToBoxAdapter(
            child: Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width / 2 - 25,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socketService.disconnect(); 
    super.dispose();
  }
}