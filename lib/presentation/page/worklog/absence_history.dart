import 'package:empowerhr_moblie/domain/usecases/absence_history_usecase.dart';
import 'package:empowerhr_moblie/domain/usecases/pending_absence.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<Map<String, dynamic>> getCombinedAbsences() async {
  try {
    final results = await Future.wait([
      getAbsencesHistory(),
      getPendingAbsences(),
    ]);

    final historyResult = results[0];
    final pendingResult = results[1];

    if (historyResult['success'] != true || pendingResult['success'] != true) {
      return {
        'success': false,
        'message': historyResult['success'] != true
            ? historyResult['message']
            : pendingResult['message'],
      };
    }

    List<dynamic> combinedAbsences = [
      ...historyResult['absences'] as List<dynamic>,
      ...pendingResult['absences'] as List<dynamic>,
    ];

    combinedAbsences.sort((a, b) => DateTime.parse(b['createdAt'])
        .compareTo(DateTime.parse(a['createdAt'])));

    return {
      'success': true,
      'message': 'Combined absences retrieved successfully',
      'absences': combinedAbsences,
    };
  } catch (error) {
    print('Error combining absences: $error');
    return {
      'success': false,
      'message': 'Error combining absences: $error',
    };
  }
}

class AbsencesHistoryPage extends StatefulWidget {
  const AbsencesHistoryPage({super.key});

  @override
  State<AbsencesHistoryPage> createState() => _AbsencesHistoryPageState();
}

class _AbsencesHistoryPageState extends State<AbsencesHistoryPage> {
  int _currentPage = 1;
  int _rowsPerPage = 10;
  String _searchQuery = '';
  DateTime? _selectedDate;
  String? _statusFilter;
  String? _absenceFilter;
  late Future<Map<String, dynamic>> _absencesFuture;

  @override
  void initState() {
    super.initState();
    _absencesFuture = getCombinedAbsences(); // Gọi hàm gộp API
  }

  List<Map<String, dynamic>> _filterAbsences(List<dynamic> absences) {
    return absences
        .where((absence) {
          final matchesSearch = _searchQuery.isEmpty ||
              absence['employeeID']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              absence['name']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());

          final matchesDate = _selectedDate == null ||
              absence['dateFrom'].toString().contains(
                  "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}");

          final matchesStatus = _statusFilter == null ||
              _statusFilter == 'All' ||
              absence['status'] == _statusFilter;
          final matchesAbsence = _absenceFilter == null ||
              _absenceFilter == 'All' ||
              absence['type'] == _absenceFilter;

          return matchesSearch &&
              matchesDate &&
              matchesStatus &&
              matchesAbsence;
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  List<Map<String, dynamic>> _paginateAbsences(
      List<Map<String, dynamic>> absences) {
    final start = (_currentPage - 1) * _rowsPerPage;
    final end = start + _rowsPerPage;
    return absences.sublist(
        start, end > absences.length ? absences.length : end);
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _changeRowsPerPage(int value) {
    setState(() {
      _rowsPerPage = value;
      _currentPage = 1;
    });
  }

  void _onSearch(String value) {
    setState(() {
      _searchQuery = value;
      _currentPage = 1;
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _currentPage = 1;
      });
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: const Text('Filter by Status'),
                value: _statusFilter,
                isExpanded: true,
                items: ['All', 'Pending', 'Rejected', 'Approved']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _statusFilter = value;
                    _currentPage = 1;
                  });
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                hint: const Text('Filter by Absence'),
                value: _absenceFilter,
                isExpanded: true,
                items: ['All', 'Full Day', 'Half Day', 'Leave Desk']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _absenceFilter = value;
                    _currentPage = 1;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _statusFilter = null;
                  _absenceFilter = null;
                  _currentPage = 1;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Clear Filters'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.blue[100]!;
      case 'Rejected':
        return Colors.red[100]!;
      case 'Approved':
        return Colors.yellow[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absences History'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _absencesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!['success']) {
              return Center(
                child: Text(
                  snapshot.data?['message'] ?? 'Error loading absences',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final absences = snapshot.data!['absences'] as List<dynamic>;
            final filteredAbsences = _filterAbsences(absences);
            final paginatedAbsences = _paginateAbsences(filteredAbsences);

            if (filteredAbsences.isEmpty) {
              return const Center(child: Text('No absences found'));
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by ID or Name',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: _onSearch,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(context),
                      tooltip: 'Pick Date',
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterDialog(context),
                      tooltip: 'Filter',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16.0,
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Line Manager')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Absence')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: paginatedAbsences.map((absence) {
                        return DataRow(cells: [
                          DataCell(Text(absence['employeeID'] ?? '')),
                          DataCell(Text(
                              absence['lineManagers']?.isNotEmpty == true
                                  ? absence['lineManagers'][0]
                                  : '')),
                          DataCell(Text(
                              '${absence['dateFrom']?.split('T')[0] ?? ''} to ${absence['dateTo']?.split('T')[0] ?? ''}')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(absence['status']),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                absence['status'] ?? '',
                                style: GoogleFonts.baloo2(
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(absence['type'] ?? '')),
                          DataCell(IconButton(
                            icon: const Icon(Icons.more_horiz, size: 20),
                            onPressed: () {},
                            color: Colors.grey,
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 12),
                          onPressed: _currentPage > 1
                              ? () => _changePage(_currentPage - 1)
                              : null,
                          color: _currentPage > 1 ? Colors.black : Colors.grey,
                        ),
                        for (int i = 1;
                            i <=
                                (filteredAbsences.length / _rowsPerPage).ceil();
                            i++)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ElevatedButton(
                              onPressed: () => _changePage(i),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _currentPage == i
                                    ? Colors.green
                                    : Colors.white,
                                foregroundColor: _currentPage == i
                                    ? Colors.white
                                    : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text('$i'),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 12),
                          onPressed: _currentPage <
                                  (filteredAbsences.length / _rowsPerPage)
                                      .ceil()
                              ? () => _changePage(_currentPage + 1)
                              : null,
                          color: _currentPage <
                                  (filteredAbsences.length / _rowsPerPage)
                                      .ceil()
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
