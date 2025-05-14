import 'package:empowerhr_moblie/presentation/page/calendar/Calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:empowerhr_moblie/presentation/page/account/account_page.dart';
import 'package:empowerhr_moblie/presentation/page/chat/chat_page.dart';
import 'package:empowerhr_moblie/presentation/page/home/home_page.dart';
import 'package:empowerhr_moblie/presentation/page/worklog/worklog_page.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0; // Current selected tab index

  final List<Widget> _pages = [
    HomePage(),
    ChatPage(),
    CalendarPage(),
    WorkLogPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex], // Display the current page
      bottomNavigationBar: BottomNavigationBar(
        
        currentIndex: _currentIndex,
       
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          _buildNavItem('Home', 'assets/icons/home_icon2.png',
              'assets/icons/home_icon1.png', 0),
          _buildNavItem('Chat', 'assets/icons/chat_icon1.png',
              'assets/icons/chat_icon2.png', 1),
          _buildNavItem('Calendar', 'assets/calendar-day.png',
              'assets/calendar-daysColor.png', 2),
          _buildNavItem('WorkLog', 'assets/icons/report_icon1.png',
              'assets/icons/report_icon2.png', 3),
          _buildNavItem('Account', 'assets/icons/account_icon1.png',
              'assets/icons/account_icon2.png', 4),
        ],
        selectedItemColor: const Color(0xFF2EB67D),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      String label, String inactiveIconPath, String activeIconPath, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gạch ngang phía trên khi active
          if (_currentIndex == index)
            Container(
              width: 66,
              height: 2,
              color: const Color(0xFF2EB67D), // Màu xanh khi active
            ),
          if (_currentIndex == index) const SizedBox(height: 10),
          Image.asset(
            _currentIndex == index ? activeIconPath : inactiveIconPath,
            width: 24,
            height: 24,
          ),
        ],
      ),
      label: label,
    );
  }
}
