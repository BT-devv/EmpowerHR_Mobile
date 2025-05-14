import 'package:empowerhr_moblie/data/models/noti_model.dart';
import 'package:empowerhr_moblie/data/service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _notifications = NotificationService().getNotifications();
    print('Initial notifications in NotificationPage: ${_notifications.length}');
    NotificationService().notificationStream.listen((notifications) {
      print('Stream updated with ${notifications.length} notifications');
      setState(() {
        _notifications = notifications;
      });
    });
    NotificationService().markAllAsRead();
  }

  void showMeetingPopup(BuildContext context, double screenWidth, NotificationModel notification) {
    bool isInitialState = true;
    bool isDeclineState = false;
    bool isDeclineSubmitted = false;
    TextEditingController declineReasonController = TextEditingController();
    String declineReason = '';

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
                    "${notification.category} invited you to a meeting on ${notification.date} at ${notification.hour}. Message: “${notification.description}”",
                    style: GoogleFonts.baloo2(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isInitialState && !isDeclineState && !isDeclineSubmitted) ...[
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
                      'You have declined this event with reason: “${declineReason}”',
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // SliverAppBar cho header
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                expandedHeight: 150,
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
              // Danh sách thông báo
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.02,
                ),
                sliver: _notifications.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'No notifications available',
                            style: GoogleFonts.baloo2(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final notification = _notifications[index];
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (notification.category == 'Meeting') {
                                      showMeetingPopup(context, screenWidth, notification);
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.01),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notification.category,
                                                style: GoogleFonts.baloo2(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                notification.description,
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
                                                color: notification.color ??
                                                    Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            Text(
                                              notification.hour,
                                              style: GoogleFonts.baloo2(
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              notification.date,
                                              style: GoogleFonts.baloo2(
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (!notification.read)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (index < _notifications.length - 1)
                                  const Divider(thickness: 1),
                              ],
                            );
                          },
                          childCount: _notifications.length,
                        ),
                      ),
              ),
              // Khoảng trống dưới cùng để tránh che nút đóng
              const SliverToBoxAdapter(
                child: SizedBox(height: 70),
              ),
            ],
          ),
          // Nút đóng
          Positioned(
            bottom: 20,
            left: screenWidth / 2 - 25,
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
        ],
      ),
    );
  }
}