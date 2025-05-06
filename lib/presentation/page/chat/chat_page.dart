import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'message_detail_page.dart'; // Import trang chi tiết tin nhắn

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Phần cố định (fixed) - Header
          SliverAppBar(
            pinned: true, // Giữ cố định khi cuộn
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false, // Xóa nút quay lại
            expandedHeight: 120, // Tăng chiều cao của SliverAppBar
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Image.asset(
                  'assets/backgroundMess.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Thanh tìm kiếm
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Group Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Text(
                'Group',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 10),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  GroupItem(name: 'Jaden Team', avatarColor: Colors.orange),
                  GroupItem(name: 'Crysiss', avatarColor: Colors.red),
                  GroupItem(name: 'Raumainan', avatarColor: Colors.blue),
                  GroupItem(name: 'HR Group', avatarColor: Colors.grey),
                  GroupItem(name: 'Jaden Team', avatarColor: Colors.green),
                  GroupItem(name: 'Jaden Team', avatarColor: Colors.purple),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const Divider(
                height: 30, thickness: 1, indent: 16, endIndent: 16),
          ),

          // People Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'People',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 10),
          ),
          // Danh sách chat
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Mở trang chi tiết tin nhắn khi nhấn
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MessageDetailPage(
                                userName: 'Trung Tuan Bui',
                              ),
                            ),
                          );
                        },
                        child: const ChatItem(
                          name: 'Trung Tuan Bui | HR',
                          message: 'Thằng này trì trương em 3 ngày nhé',
                          time: '10:20 AM',
                          unreadCount: 3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MessageDetailPage(
                                userName: 'Trung Tuan Bui',
                              ),
                            ),
                          );
                        },
                        child: const ChatItem(
                          name: 'Trung Tuan Bui | HR',
                          message: 'Thằng này trì trương em 3 ngày nhé',
                          time: '10:20 AM',
                          unreadCount: 3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MessageDetailPage(
                                userName: 'Trung Tuan Bui',
                              ),
                            ),
                          );
                        },
                        child: const ChatItem(
                          name: 'Trung Tuan Bui | HR',
                          message: 'Thằng này trì trương em 3 ngày nhé',
                          time: '10:20 AM',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MessageDetailPage(
                                userName: 'Trung Tuan Bui',
                              ),
                            ),
                          );
                        },
                        child: const ChatItem(
                          name: 'Trung Tuan Bui | HR',
                          message: 'Thằng này trì trương em 3 ngày nhé',
                          time: '10:20 AM',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MessageDetailPage(
                                userName: 'Trung Tuan Bui',
                              ),
                            ),
                          );
                        },
                        child: const ChatItem(
                          name: 'Trung Tuan Bui | HR',
                          message: 'Thằng này trì trương em 3 ngày nhé',
                          time: '10:20 AM',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Thêm padding dưới cùng
              ],
            ),
          ),
        ],
      ),
      // FloatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Tạo chat mới');
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

// Widget for Group Item (Horizontal List)
class GroupItem extends StatelessWidget {
  final String name;
  final Color avatarColor;

  const GroupItem({
    super.key,
    required this.name,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: avatarColor,
            child: const Icon(Icons.group, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Widget for Chat Item (Vertical List)
class ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final int? unreadCount;

  const ChatItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          // Avatar with notification badge
          Stack(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              if (unreadCount != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      unreadCount.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          // Name and message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Timestamp
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}