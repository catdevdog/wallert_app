// lib/screens/calendar/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/setting_event.dart';
import '../../services/api_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _apiService = ApiService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<SettingEvent>> _events = {};
  List<SettingEvent> _selectedEvents = [];
  bool _isLoading = false;

  // 브랜드별 색상 정의 (모든 암장에 색상 부여)
  final Map<String, Color> _brandColors = {
    'theclimb_nonhyeon': Colors.red.shade400,
    'theclimb_yangjae': Colors.blue.shade400,
    'theclimb_b_hongdae': Colors.green.shade400,
    'theclimb_sinsa': Colors.orange.shade400,
    'theclimb_yeonnam': Colors.purple.shade400,
    'theclimb_snu': Colors.teal.shade400,
    'theclimb_silim': Colors.pink.shade400,
    'theclimb_sadang': Colors.indigo.shade400,
    'theclimb_gangnam': Colors.amber.shade400,
    'theclimb_magok': Colors.cyan.shade400,
    'theclimb_life': Colors.deepOrange.shade400,
    'theclimb_mullae': Colors.lightGreen.shade400,
    'theclimb_seongsu': Colors.brown.shade400,
    'theclimb_isu': Colors.blueGrey.shade400,
    'theclimb_ilsan': Colors.deepPurple.shade400,
  };

  // 선택된 브랜드 필터 (null이면 모든 브랜드 표시)
  String? _selectedBrandFilter;

  @override
  void initState() {
    super.initState();
    _fetchMonthlySchedule();
  }

  // 월별 일정 데이터 가져오기
  Future<void> _fetchMonthlySchedule() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _apiService.fetchMonthlySchedule(
          year: _focusedDay.year,
          month: _focusedDay.month
      );

      // 날짜별로 이벤트 그룹화
      final Map<DateTime, List<SettingEvent>> eventMap = {};
      for (var event in events) {
        final date = DateTime(event.date.year, event.date.month, event.date.day);

        if (!eventMap.containsKey(date)) {
          eventMap[date] = [];
        }
        eventMap[date]!.add(event);
      }

      if (mounted) {
        setState(() {
          _events = eventMap;
          _isLoading = false;

          // 선택된 날짜가 있으면 해당 날짜의 이벤트 업데이트
          if (_selectedDay != null) {
            _selectedEvents = _getEventsForDay(_selectedDay!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error fetching schedule: $e');

      // 오류 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('일정을 불러오는 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 특정 날짜의 이벤트 가져오기
  List<SettingEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  // 브랜드 색상 가져오기 (정의되지 않은 브랜드는 기본 색상 반환)
  Color _getBrandColor(String brandName) {
    return _brandColors[brandName] ?? Colors.grey;
  }

  // 브랜드 이름을 한글 이름으로 변환하는 메서드
  String _getBrandKoreanName(String brandName) {
    // 브랜드 이름 변환 맵
    final Map<String, String> brandKoreanNames = {
      'theclimb_nonhyeon': '더클라임 논현점',
      'theclimb_yangjae': '더클라임 양재점',
      'theclimb_b_hongdae': '더클라임 B 홍대점',
      'theclimb_sinsa': '더클라임 신사점',
      'theclimb_yeonnam': '더클라임 연남점',
      'theclimb_snu': '더클라임 서울대점',
      'theclimb_silim': '더클라임 신림점',
      'theclimb_sadang': '더클라임 사당점',
      'theclimb_gangnam': '더클라임 강남점',
      'theclimb_magok': '더클라임 마곡점',
      'theclimb_life': '더클라임 라이프',
      'theclimb_mullae': '더클라임 문래점',
      'theclimb_seongsu': '더클라임 성수점',
      'theclimb_isu': '더클라임 이수점',
      'theclimb_ilsan': '더클라임 일산점',
    };

    return brandKoreanNames[brandName] ?? brandName;
  }

  // 필터 선택을 위한 다이얼로그 표시
  void _showBrandFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('암장 필터'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('모든 암장'),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: _selectedBrandFilter,
                    onChanged: (value) {
                      Navigator.pop(context);
                      setState(() {
                        _selectedBrandFilter = value;
                      });
                    },
                  ),
                ),
                Container(
                  height: 300,
                  child: ListView(
                    shrinkWrap: true,
                    children: _brandColors.keys.map((brandName) {
                      return ListTile(
                        title: Text(_getBrandKoreanName(brandName)),
                        leading: Radio<String?>(
                          value: brandName,
                          groupValue: _selectedBrandFilter,
                          onChanged: (value) {
                            Navigator.pop(context);
                            setState(() {
                              _selectedBrandFilter = value;
                            });
                          },
                        ),
                        trailing: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _getBrandColor(brandName),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('세팅 일정'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMonthlySchedule,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 로딩 중일 때 진행 표시줄 표시
          if (_isLoading)
            const LinearProgressIndicator(),

          // 캘린더 위젯
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month, // 항상 월 형식만 사용
            availableCalendarFormats: const {
              CalendarFormat.month: '월간',
            },
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _getEventsForDay(selectedDay);
              });
            },
            onPageChanged: (focusedDay) {
              // 페이지 변경 시 데이터 다시 로드
              if (_focusedDay.month != focusedDay.month ||
                  _focusedDay.year != focusedDay.year) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                _fetchMonthlySchedule();
              }
            },
            // 커스텀 마커 빌더
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox();

                // 브랜드별로 그룹화
                final Map<String, List<SettingEvent>> brandGroups = {};
                for (var event in events) {
                  // null 체크와 타입 캐스팅 추가
                  if (event is SettingEvent) {
                    final brandName = event.brandName;
                    if (!brandGroups.containsKey(brandName)) {
                      brandGroups[brandName] = [];
                    }
                    brandGroups[brandName]!.add(event);
                  }
                }

                // 각 브랜드별 색상 점 표시
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: brandGroups.keys.map((brandName) {
                      final color = _getBrandColor(brandName);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        width: 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
              // 선택된 날짜에 동그란 표시 추가
              selectedBuilder: (context, date, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              todayBuilder: (context, date, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
            // 캘린더 스타일 설정
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // 포맷 변경 버튼 제거
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            calendarStyle: CalendarStyle(
              markersMaxCount: 5,
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red.withOpacity(0.7)),
              holidayTextStyle: TextStyle(color: Colors.red.withOpacity(0.7)),
              // 더 플랫한 선택 스타일
              selectedDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              todayDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
            ),
          ),

          const Divider(height: 1),

          // 선택된 날짜 표시
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    DateFormat('yyyy년 MM월 dd일').format(_selectedDay!),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Text(
                  //   '(${_selectedEvents.length}개의 세팅)',
                  //   style: TextStyle(color: Colors.grey[600]),
                  // ),
                ],
              ),
            ),

          // 선택된 날짜의 이벤트가 없을 때 메시지
          if (_selectedEvents.isEmpty && _selectedDay != null)
            const Expanded(
              child: Center(
                child: Text('이 날짜에 예정된 세팅이 없습니다.'),
              ),
            )
          else if (_selectedDay != null)
          // 선택된 날짜의 이벤트 리스트
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: _selectedEvents.length,
                itemBuilder: (context, index) {
                  final event = _selectedEvents[index];
                  final brandColor = _getBrandColor(event.brandName);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: brandColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_getBrandKoreanName(event.brandName)} : ${event.wallName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (event.description != null && event.description!.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.info_outline, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                // 이벤트 상세정보 표시
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('${_getBrandKoreanName(event.brandName)} - ${event.wallName}'),
                                    content: event.description != null && event.description!.isNotEmpty
                                        ? Text(event.description!)
                                        : const Text('추가 정보가 없습니다.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('확인'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}