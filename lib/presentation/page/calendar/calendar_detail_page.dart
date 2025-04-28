// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CalendarDetail extends StatelessWidget {
//   final Map<String, dynamic> meeting;

//   const CalendarDetail({super.key, required this.meeting});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Thời gian và thời lượng
//               Row(
//                 children: [
//                   const Icon(Icons.access_time, color: Colors.grey, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     '${meeting['startTime']} -> ${meeting['endTime']}',
//                     style: GoogleFonts.baloo2(
//                       textStyle: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     meeting['duration'],
//                     style: GoogleFonts.baloo2(
//                       textStyle: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.teal,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Ngày
//               Row(
//                 children: [
//                   const Icon(Icons.calendar_today,
//                       color: Colors.grey, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     meeting['date'],
//                     style: GoogleFonts.baloo2(
//                       textStyle: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Địa điểm
//               Row(
//                 children: [
//                   const Icon(Icons.location_on, color: Colors.grey, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     meeting['location'],
//                     style: GoogleFonts.baloo2(
//                       textStyle: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Dự án
//               Row(
//                 children: [
//                   const Icon(Icons.work, color: Colors.grey, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     meeting['project'],
//                     style: GoogleFonts.baloo2(
//                       textStyle: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               // Mô tả
//               Text(
//                 'Description',
//                 style: GoogleFonts.baloo2(
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 meeting['description'],
//                 style: GoogleFonts.baloo2(
//                   textStyle: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Danh sách người tham gia
//               Text(
//                 'Participants',
//                 style: GoogleFonts.baloo2(
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 meeting['participants'],
//                 style: GoogleFonts.baloo2(
//                   textStyle: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
