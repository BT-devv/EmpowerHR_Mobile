import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Trang chi tiết cuộc họp
class CalendarStaffDetail extends StatelessWidget {
  final Map<String, dynamic> meeting;

  const CalendarStaffDetail({super.key, required this.meeting});

  String _getHeaderImageForMonth(int month) {
    switch (month) {
      case 1:
        return 'assets/header_calender/header_1.png';
      case 2:
        return 'assets/header_calender/header_2.png';
      case 3:
        return 'assets/header_calender/header_3.png';
      case 4:
        return 'assets/header_calender/header_4.png';
      case 5:
        return 'assets/header_calender/header_5.png';
      case 6:
        return 'assets/header_calender/header_6.png';
      case 7:
        return 'assets/header_calender/header_7.png';
      case 8:
        return 'assets/header_calender/header_8.png';
      case 9:
        return 'assets/header_calender/header_9.png';
      case 10:
        return 'assets/header_calender/header_10.png';
      case 11:
        return 'assets/header_calender/header_11.png';
      case 12:
        return 'assets/header_calender/header_12.png';
      default:
        return 'assets/header_calender/header_12.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String headerImage = _getHeaderImageForMonth(now.month);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar cho header
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Hình nền
                  Container(
                    color: Colors.white,
                    child: Image.asset(
                      headerImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Nút Back
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 35,
                        width: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromRGBO(255, 255, 255, 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/chevron-left.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Back',
                              style: GoogleFonts.baloo2(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Nội dung chính
          SliverList(
            delegate: SliverChildListDelegate([
              // Thời gian và thời lượng
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${meeting['startTime']} -> ${meeting['endTime']}',
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      meeting['durationText'],
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Ngày
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      meeting['date'],
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Địa điểm
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      meeting['location'],
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Dự án
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    const Icon(Icons.work, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      meeting['project'],
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              // Mô tả
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  'Description',
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  meeting['description'],
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              // Danh sách người tham gia
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  'Participants',
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  meeting['participants'],
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  // Hàm để lấy tên file ảnh dựa trên tháng
  String _getHeaderImageForMonth(int month) {
    switch (month) {
      case 1:
        return 'assets/header_calender/header_1.png';
      case 2:
        return 'assets/header_calender/header_2.png';
      case 3:
        return 'assets/header_calender/header_3.png';
      case 4:
        return 'assets/header_calender/header_4.png';
      case 5:
        return 'assets/header_calender/header_5.png';
      case 6:
        return 'assets/header_calender/header_6.png';
      case 7:
        return 'assets/header_calender/header_7.png';
      case 8:
        return 'assets/header_calender/header_8.png';
      case 9:
        return 'assets/header_calender/header_9.png';
      case 10:
        return 'assets/header_calender/header_10.png';
      case 11:
        return 'assets/header_calender/header_11.png';
      case 12:
        return 'assets/header_calender/header_12.png';
      default:
        return 'assets/header_calender/header_12.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final now = DateTime.now();
    String todayDate = DateFormat('MMMM yyyy').format(now);

    // Lấy ảnh header dựa trên tháng hiện tại
    String headerImage = _getHeaderImageForMonth(now.month);

    // Tạo danh sách các ngày trong tuần
    List<Map<String, dynamic>> daysOfWeek = [];
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    for (int i = 0; i < 7; i++) {
      DateTime day = startOfWeek.add(Duration(days: i));
      String dayName = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'][i];
      daysOfWeek.add({
        'name': dayName,
        'date': day.day,
        'isToday': day.day == now.day &&
            day.month == now.month &&
            day.year == now.year,
      });
    }

    // Danh sách các cuộc họp (có thể thay bằng dữ liệu từ API)
    List<Map<String, dynamic>> meetings = [
      {
        'title': 'Stake holder meeting\nProject Crysis',
        'startHour': 10,
        'duration': 1,
        'color': Colors.orange,
        'startTime': '10:00AM',
        'endTime': '11:00AM',
        'durationText': '1 hour',
        'date': 'Mon, 10 March 2025',
        'location': 'Level 8, 9.01 Meeting Room',
        'project': 'Project Crysis',
        'description':
            'This meeting is to discuss with the stakeholder about future function of the website',
        'participants':
            'You, anhthung.dol89, thaiivy.le77, quoctung.dong21, and 21 others.',
      },
      {
        'title': 'Lunch time with Mr Bills Gate',
        'startHour': 12,
        'duration': 2,
        'color': Colors.red,
        'startTime': '12:00PM',
        'endTime': '2:00PM',
        'durationText': '2 hours',
        'date': 'Mon, 10 March 2025',
        'location': 'Level 8, 9.02 Meeting Room',
        'project': 'General',
        'description': 'Lunch meeting to discuss general updates',
        'participants': 'You, Mr Bills Gate, and 5 others.',
      },
      {
        'title': 'Final test for web backend\nOddessy Team PJ',
        'startHour': 15,
        'duration': 3,
        'color': const Color(0xFF2EB67D),
        'startTime': '3:00PM',
        'endTime': '6:00PM',
        'durationText': '3 hours',
        'date': 'Mon, 10 March 2025',
        'location': 'Level 8, 9.03 Meeting Room',
        'project': 'Oddessy Team PJ',
        'description': 'Final testing session for the web backend',
        'participants': 'You, dev.team, qa.team, and 10 others.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar cho header
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 150,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Image.asset(
                  headerImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Nội dung chính
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Text(
                          todayDate,
                          style: GoogleFonts.baloo2(
                            textStyle: const TextStyle(
                              fontSize: 34,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Days of Week
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
                      child: Row(
                        children: daysOfWeek.map((day) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: day['isToday']
                                    ? const Color(0xFF2EB67D)
                                    : const Color.fromARGB(255, 159, 160, 160),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    day['date'].toString(),
                                    style: GoogleFonts.baloo2(
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        color: day['isToday']
                                            ? Colors.white
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    day['name'],
                                    style: GoogleFonts.baloo2(
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color: day['isToday']
                                            ? Colors.white
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Today's Schedule
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's schedule",
                            style: GoogleFonts.baloo2(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              // Các mốc giờ từ 8:00 đến 20:00
                              Column(
                                children: List.generate(13, (index) {
                                  int hour = 8 + index;
                                  return Container(
                                    height: 40,
                                    margin: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$hour:00',
                                          style: GoogleFonts.baloo2(
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.withOpacity(0.3),
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                              // Các cuộc họp từ danh sách
                              ...meetings.map((meeting) {
                                return Positioned(
                                  top: ((meeting['startHour'] - 8) * 44)
                                      .toDouble(),
                                  left: 50,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CalendarStaffDetail(
                                            meeting: meeting,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: (meeting['duration'] * 40 +
                                              (meeting['duration'] - 1) * 4)
                                          .toDouble(),
                                      decoration: BoxDecoration(
                                        color: meeting['color'],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Stack(
                                        children: [
                                          Text(
                                            meeting['title'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Reminder Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REMINDER',
                            style: GoogleFonts.baloo2(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildReminderItem(
                            'Drink at lease 2 litter water',
                            'ALL DAY',
                            Colors.black,
                          ),
                          const Divider(),
                          _buildReminderItem(
                            'Deadline of backend developing',
                            'TOMORROW',
                            Colors.red,
                          ),
                          const Divider(),
                          _buildReminderItem(
                            'Web performance test',
                            'TOMORROW',
                            Colors.red,
                          ),
                          const Divider(),
                          _buildReminderItem(
                            'Stakeholders showcase website',
                            'TUE',
                            Colors.black,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(String title, String time, Color timeColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.baloo2(
              textStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.baloo2(
              textStyle: TextStyle(
                fontSize: 14,
                color: timeColor,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}