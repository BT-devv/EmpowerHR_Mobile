import 'package:empowerhr_moblie/data/service/socket_service.dart';
import 'package:empowerhr_moblie/presentation/page/home/notification_page.dart';
import 'package:flutter/material.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({Key? key}) : super(key: key);

  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    NotificationService().notificationStream.listen((notifications) {
      setState(() {
        _unreadCount = notifications.where((n) => !n.read).length;
      });
    });
  }

  Future<void> _loadUnreadCount() async {
    final notifications = NotificationService().getNotifications();
    setState(() {
      _unreadCount = notifications.where((n) => !n.read).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        ).then((_) {
          _loadUnreadCount();
        });
      },
      child: Stack(
        children: [
          Container(
            height: screenWidth * 0.11,
            width: screenWidth * 0.11,
            margin: EdgeInsets.only(
              left: screenWidth * 0.02,
              top: screenHeight * 0.02,
              right: screenWidth * 0.035,
            ),
            decoration:  BoxDecoration(
              color: Color(0xFF80C0A5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset('assets/thongbao.png'),
          ),
          if (_unreadCount > 0)
            Positioned(
              right: screenWidth * 0.035,
              top: screenHeight * 0.02,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}