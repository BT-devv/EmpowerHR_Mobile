import 'package:empowerhr_moblie/domain/usecases/sumary_atendance_usecase.dart';
import 'package:empowerhr_moblie/presentation/page/worklog/absence_history.dart';
import 'package:empowerhr_moblie/presentation/page/worklog/create_request.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkLogPage extends StatefulWidget {
  const WorkLogPage({super.key});

  @override
  State<WorkLogPage> createState() => _WorkLogPageState();
}

class _WorkLogPageState extends State<WorkLogPage> {
  late Future<Map<String, dynamic>> _attendanceSummaryFuture;

  @override
  void initState() {
    super.initState();
    // _attendanceSummaryFuture = getAttendanceSummary();
  }

  Widget _buildStatCard(String title, String value, Color backgroundColor, Color textColor) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 26,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(String title, Color color) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            Container(
              width: 22,
              height: 2,
              color: color,
            ),
          ],
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildUtilityItem(String title, {bool comingSoon = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 15, left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                if (comingSoon) ...[
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Colors.red, Colors.orange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      "coming soon",
                      style: GoogleFonts.baloo2(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Image.asset(
                  "assets/icons/arrow-small-right.png",
                  height: 20,
                  width: 20,
                  color: const Color(0xFF2EB67D),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Image.asset(
                  'assets/headerWorklog.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: const EdgeInsets.only(left: 15, top: 25),
                child: Text(
                  "Your monthly report",
                  style: GoogleFonts.baloo2(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _attendanceSummaryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || !snapshot.data!['success']) {
                      return Center(
                        child: Text(
                          snapshot.data?['message'] ?? 'Error loading attendance summary',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final data = snapshot.data!['data'] as Map<String, dynamic>;
                    final total = data['total'].toString();
                    final onTimeCount = data['onTimeCount'].toString();
                    final absentCount = data['absentCount'].toString();
                    final lateCount = data['lateCount'].toString();

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard(
                              'Total',
                              total,
                              const Color.fromARGB(255, 166, 237, 172),
                              Colors.black,
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey,
                            ),
                            _buildStatCard(
                              'Early',
                              onTimeCount,
                              Colors.white,
                              Colors.green,
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey,
                            ),
                            _buildStatCard(
                              'Absence',
                              absentCount,
                              Colors.white,
                              Colors.red,
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey,
                            ),
                            _buildStatCard(
                              'OT',
                              lateCount,
                              Colors.white,
                              Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Work log summary',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _buildLegend('Early', Colors.green),
                                    const SizedBox(width: 10),
                                    _buildLegend('Late', Colors.red),
                                    const SizedBox(width: 10),
                                    _buildLegend('OT', Colors.blue),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 220,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: 12 * 60.0,
                                    child: Stack(
                                      children: [
                                        LineChart(
                                          LineChartData(
                                            clipData: const FlClipData(
                                              left: true,
                                              right: true,
                                              top: true,
                                              bottom: false,
                                            ),
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              drawHorizontalLine: true,
                                              horizontalInterval: 10,
                                              getDrawingHorizontalLine: (value) {
                                                if (value == 0) {
                                                  return FlLine(
                                                    color: Colors.grey[600]!,
                                                    strokeWidth: 2,
                                                  );
                                                }
                                                return FlLine(
                                                  color: Colors.grey[400]!,
                                                  strokeWidth: 1,
                                                );
                                              },
                                            ),
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 40,
                                                  getTitlesWidget: (value, meta) {
                                                    if (value == 40) {
                                                      return const Text('');
                                                    }
                                                    return Text(
                                                      value.toInt().toString(),
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                axisNameWidget: Text(
                                                  'Times',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  interval: 1,
                                                  getTitlesWidget: (value, meta) {
                                                    switch (value.toInt()) {
                                                      case 0:
                                                        return Text(
                                                          'Jan',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 1:
                                                        return Text(
                                                          'Feb',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 2:
                                                        return Text(
                                                          'Mar',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 3:
                                                        return Text(
                                                          'Apr',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 4:
                                                        return Text(
                                                          'May',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 5:
                                                        return Text(
                                                          'Jun',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 6:
                                                        return Text(
                                                          'Jul',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 7:
                                                        return Text(
                                                          'Aug',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 8:
                                                        return Text(
                                                          'Sep',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 9:
                                                        return Text(
                                                          'Oct',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 10:
                                                        return Text(
                                                          'Nov',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      case 11:
                                                        return Text(
                                                          'Dec',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      default:
                                                        return const Text('');
                                                    }
                                                  },
                                                ),
                                                axisNameWidget: Text(
                                                  'Month',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              topTitles: const AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                              rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border.all(color: Colors.grey[300]!),
                                            ),
                                            minX: 0,
                                            maxX: 13,
                                            minY: -10,
                                            maxY: 40,
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: const [
                                                  FlSpot(0, 20),
                                                  FlSpot(1, 15),
                                                  FlSpot(2, 25),
                                                  FlSpot(3, 30),
                                                  FlSpot(4, 20),
                                                  FlSpot(5, 18),
                                                  FlSpot(6, 22),
                                                  FlSpot(7, 15),
                                                  FlSpot(8, 25),
                                                  FlSpot(9, 20),
                                                  FlSpot(10, 10),
                                                  FlSpot(11, 28),
                                                ],
                                                isCurved: true,
                                                color: Colors.green,
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent, barData, index) =>
                                                      FlDotCirclePainter(
                                                    radius: 4,
                                                    color: Colors.green,
                                                    strokeWidth: 2,
                                                    strokeColor: Colors.white,
                                                  ),
                                                ),
                                                belowBarData: BarAreaData(show: false),
                                              ),
                                              LineChartBarData(
                                                spots: const [
                                                  FlSpot(0, 5),
                                                  FlSpot(1, 10),
                                                  FlSpot(2, 0),
                                                  FlSpot(3, 5),
                                                  FlSpot(4, 0),
                                                  FlSpot(5, 3),
                                                  FlSpot(6, 7),
                                                  FlSpot(7, 2),
                                                  FlSpot(8, 4),
                                                  FlSpot(9, 1),
                                                  FlSpot(10, 6),
                                                  FlSpot(11, 0),
                                                ],
                                                isCurved: true,
                                                color: Colors.red,
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent, barData, index) =>
                                                      FlDotCirclePainter(
                                                    radius: 4,
                                                    color: Colors.red,
                                                    strokeWidth: 2,
                                                    strokeColor: Colors.white,
                                                  ),
                                                ),
                                                belowBarData: BarAreaData(show: false),
                                              ),
                                              LineChartBarData(
                                                spots: const [
                                                  FlSpot(0, 15),
                                                  FlSpot(1, 5),
                                                  FlSpot(2, -5),
                                                  FlSpot(3, 20),
                                                  FlSpot(4, 10),
                                                  FlSpot(5, 12),
                                                  FlSpot(6, 8),
                                                  FlSpot(7, 15),
                                                  FlSpot(8, 5),
                                                  FlSpot(9, 18),
                                                  FlSpot(10, 7),
                                                  FlSpot(11, 20),
                                                ],
                                                isCurved: true,
                                                color: Colors.blue,
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent, barData, index) =>
                                                      FlDotCirclePainter(
                                                    radius: 4,
                                                    color: Colors.blue,
                                                    strokeWidth: 2,
                                                    strokeColor: Colors.white,
                                                  ),
                                                ),
                                                belowBarData: BarAreaData(show: false),
                                              ),
                                            ],
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
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Other Utilities',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildUtilityItem('Create new request', onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const CreateRequest(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    }),
                    const Divider(),
                    _buildUtilityItem('Request history', onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const AbsencesHistoryPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    }),
                    const Divider(),
                    _buildUtilityItem('Report history', comingSoon: true, onTap: () {}),
                    const Divider(),
                    _buildUtilityItem('Incoming feature', comingSoon: true, onTap: () {}),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}