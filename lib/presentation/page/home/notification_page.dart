import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Hàm hiển thị popup cho thông báo Meeting
  void showMeetingPopup(BuildContext context, double screenWidth) {
    // Biến trạng thái để kiểm soát nội dung của popup
    bool isInitialState = true; // Trạng thái ban đầu (chưa nhấn Accept/Decline)
    bool isDeclineState = false; // Trạng thái khi nhấn Decline
    bool isDeclineSubmitted = false; // Trạng thái sau khi nhấn Submit
    TextEditingController declineReasonController = TextEditingController();
    String declineReason = ''; // Lưu lý do từ chối

    showDialog(
      barrierDismissible:false,
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
                  // Nội dung popup
                  Text(
                    "Tuan Bui invited you to a meeting on 10 March 2025 at 10:20AM. Message: “Quick team up meeting for next sprint.”",
                    style: GoogleFonts.baloo2(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Hiển thị nội dung bổ sung dựa trên trạng thái
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
                      'You have decline this event with reason: “${declineReason}”',
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

                  // Nút trong popup
                  if (isInitialState) ...[
                    // Trạng thái ban đầu: Hiển thị nút Accept và Decline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Nút Accept
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInitialState =
                                  false; // Chuyển sang trạng thái Accept
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
                        SizedBox(width: 60,),

                        // Nút Decline
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInitialState =
                                  false; // Chuyển sang trạng thái Decline
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
                    // Trạng thái Decline: Hiển thị ô nhập liệu và nút Submit/Back
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nút Submit
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              declineReason = declineReasonController
                                  .text; // Lưu lý do từ chối
                              isDeclineState = false;
                              isDeclineSubmitted =
                                  true; // Chuyển sang trạng thái Submitted
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

                        // Nút Back
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isInitialState =
                                  true; // Quay lại trạng thái ban đầu
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
                    // Trạng thái Accept hoặc Submitted: Chỉ hiển thị nút Close
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Đóng popup
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

    // Danh sách thông báo (thêm trường color cho thanh màu)
    final List<Map<String, dynamic>> notifications = [
      {
        'category': 'Meeting',
        'description': 'Your absence ticket has been approved',
        'hour': '18:20AM',
        'date': '22/02/25',
        'color': Colors.red, // Thanh màu đỏ
      },
      {
        'category': 'Performance report',
        'description': 'Your performance report of Jan 2025',
        'hour': '10:30AM',
        'date': '22/02/25',
        'color': Colors.green, // Thanh màu xanh lá
      },
      {
        'category': 'Performance report',
        'description': 'You have successfully submit your ...',
        'hour': '18:20AM',
        'date': '19/02/25',
        'color': Colors.blue, // Thanh màu xanh dương
      },
      {
        'category': 'Password change',
        'description': 'Your password has successfully changed',
        'hour': '10:20AM',
        'date': '17/02/25',
        'color': Colors.orange, // Thanh màu cam
      },
      {
        'category': 'Absence request',
        'description': 'Your absence ticket has been approved',
        'hour': '10:20AM',
        'date': '20/01/25',
        'color': Colors.purple, // Thanh màu tím
      },
      {
        'category': 'Performance report',
        'description': 'Your performance report of Jan 2025',
        'hour': '10:30AM',
        'date': '20/01/25',
        'color': Colors.teal, // Thanh màu xanh lam
      },
      {
        'category': 'Performance report',
        'description': 'You have successfully submit your ...',
        'hour': '18:20AM',
        'date': '18/01/25',
        'color': Colors.yellow, // Thanh màu vàng
      },
      {
        'category': 'Password change',
        'description': 'Your password has successfully changed',
        'hour': '10:20AM',
        'date': '17/01/25',
        'color': Colors.pink, // Thanh màu hồng
      },
      {
        'category': 'Event notification',
        'description': 'You have been invited to a new event',
        'hour': '18:20AM',
        'date': '17/01/25',
        'color': Colors.cyan, // Thanh màu xanh cyan
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background_notification.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Danh sách thông báo
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => Divider(
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return GestureDetector(
                      onTap: () {
                        // Hiển thị popup nếu category là 'Meeting'
                        if (notification['category'] == 'Meeting') {
                          showMeetingPopup(context, screenWidth);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        overflow: TextOverflow
                                            .ellipsis, // Cắt ngắn với dấu ...
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: notification['color'],
                                        borderRadius: BorderRadius.circular(
                                            2), // Bo tròn hai đầu
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

          // Nút đóng
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 25, // Căn giữa
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Đóng trang
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
