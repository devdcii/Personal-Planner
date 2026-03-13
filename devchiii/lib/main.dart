import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Folder model for Hive storage
@HiveType(typeId: 1)
class Folder extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String icon;

  @HiveField(2)
  DateTime createdAt;

  Folder({
    required this.name,
    this.icon = '📁',
    required this.createdAt,
  });
}

// Calendar Note model for Hive storage
@HiveType(typeId: 2)
class CalendarNote extends HiveObject {
  @HiveField(0)
  String content;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  bool isTask;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  CalendarNote({
    required this.content,
    required this.date,
    this.isTask = false,
    this.isCompleted = false,
    required this.createdAt,
  });
}

// Calendar Note adapter for Hive
class CalendarNoteAdapter extends TypeAdapter<CalendarNote> {
  @override
  final int typeId = 2;

  @override
  CalendarNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarNote(
      content: fields[0] as String,
      date: fields[1] as DateTime,
      isTask: fields[2] as bool? ?? false,
      isCompleted: fields[3] as bool? ?? false,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CalendarNote obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.isTask)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CalendarNoteAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// Folder adapter for Hive
class FolderAdapter extends TypeAdapter<Folder> {
  @override
  final int typeId = 1;

  @override
  Folder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Folder(
      name: fields[0] as String,
      icon: fields[1] as String? ?? '📁',
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Folder obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FolderAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// Updated Task model with folder reference
@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String notes;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  String? folderId;

  Task({
    required this.title,
    this.notes = '',
    this.isCompleted = false,
    required this.dueDate,
    this.folderId,
  });
}

// Updated Task adapter
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      title: fields[0] as String,
      notes: fields[1] as String? ?? '',
      isCompleted: fields[2] as bool? ?? false,
      dueDate: fields[3] as DateTime,
      folderId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.notes)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.folderId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(FolderAdapter());
  Hive.registerAdapter(CalendarNoteAdapter());
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Folder>('folders');
  await Hive.openBox<CalendarNote>('calendar_notes');
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'CpE Planner',
      theme: CupertinoThemeData(
        primaryColor: Color(0xFF007AFF),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF2F2F7),
        barBackgroundColor: Colors.white,
        textTheme: CupertinoTextThemeData(
          primaryColor: Colors.black,
        ),
      ),
      home: MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<_TodoListScreenState> _todoKey = GlobalKey();
  final GlobalKey<_FoldersScreenState> _foldersKey = GlobalKey();
  final GlobalKey<_StatsScreenState> _statsKey = GlobalKey();
  final GlobalKey<_CalendarScreenState> _calendarKey = GlobalKey();

  void _refreshAllScreens() {
    _todoKey.currentState?.refreshStats();
    _foldersKey.currentState?.refreshStats();
    _statsKey.currentState?.refreshStats();
    _calendarKey.currentState?.refreshCalendar();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        activeColor: const Color(0xFF007AFF),
        inactiveColor: CupertinoColors.systemGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder),
            label: 'Folders',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: 'Stats',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return TodoListScreen(key: _todoKey, onDataChanged: _refreshAllScreens);
          case 1:
            return FoldersScreen(key: _foldersKey, onDataChanged: _refreshAllScreens);
          case 2:
            return CalendarScreen(key: _calendarKey, onDataChanged: _refreshAllScreens);
          case 3:
            return StatsScreen(key: _statsKey);
          default:
            return TodoListScreen(key: _todoKey, onDataChanged: _refreshAllScreens);
        }
      },
    );
  }
}

class CalendarScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const CalendarScreen({Key? key, this.onDataChanged}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Box<CalendarNote> calendarBox;
  late Box<Task> taskBox;
  DateTime selectedDate = DateTime.now();
  DateTime displayedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    calendarBox = Hive.box<CalendarNote>('calendar_notes');
    taskBox = Hive.box<Task>('tasks');
  }

  void refreshCalendar() {
    if (mounted) {
      setState(() {});
    }
  }

  List<CalendarNote> getNotesForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return calendarBox.values
        .where((note) {
      final noteDate = DateTime(note.date.year, note.date.month, note.date.day);
      return noteDate == dateKey;
    })
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<Task> getTasksForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return taskBox.values
        .where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate == dateKey;
    })
        .toList();
  }

  bool hasContentForDate(DateTime date) {
    return getNotesForDate(date).isNotEmpty || getTasksForDate(date).isNotEmpty;
  }

  void _showDayDetails(DateTime date) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => DayDetailScreen(
          selectedDate: date,
          onDataChanged: () {
            refreshCalendar();
            widget.onDataChanged?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text(
          _getMonthYearString(displayedMonth),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1);
            });
          },
          child: const Icon(CupertinoIcons.chevron_left, color: Color(0xFF007AFF)),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1);
            });
          },
          child: const Icon(CupertinoIcons.chevron_right, color: Color(0xFF007AFF)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Calendar grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Day headers
                    Row(
                      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                          .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.systemGrey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    // Calendar days
                    ..._buildCalendarWeeks(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCalendarWeeks() {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final List<Widget> weeks = [];
    final List<Widget> currentWeek = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      currentWeek.add(const Expanded(child: SizedBox()));
    }

    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(displayedMonth.year, displayedMonth.month, day);
      final isToday = _isSameDay(date, DateTime.now());
      final isSelected = _isSameDay(date, selectedDate);
      final hasContent = hasContentForDate(date);

      currentWeek.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
              _showDayDetails(date);
            },
            child: Container(
              height: 44,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF007AFF)
                    : isToday
                    ? const Color(0xFF007AFF).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday && !isSelected
                    ? Border.all(color: const Color(0xFF007AFF), width: 1)
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? const Color(0xFF007AFF)
                            : Colors.black,
                      ),
                    ),
                  ),
                  if (hasContent)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF007AFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      if (currentWeek.length == 7) {
        weeks.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: List.from(currentWeek)),
          ),
        );
        currentWeek.clear();
      }
    }

    // Add empty cells for remaining days in the last week
    while (currentWeek.length < 7) {
      currentWeek.add(const Expanded(child: SizedBox()));
    }

    if (currentWeek.isNotEmpty) {
      weeks.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: currentWeek),
        ),
      );
    }

    return weeks;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSelectedDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class DayDetailScreen extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback? onDataChanged;

  const DayDetailScreen({
    Key? key,
    required this.selectedDate,
    this.onDataChanged,
  }) : super(key: key);

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late Box<CalendarNote> calendarBox;
  late Box<Task> taskBox;
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    calendarBox = Hive.box<CalendarNote>('calendar_notes');
    taskBox = Hive.box<Task>('tasks');
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  List<CalendarNote> getNotesForDate() {
    final dateKey = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    return calendarBox.values
        .where((note) {
      final noteDate = DateTime(note.date.year, note.date.month, note.date.day);
      return noteDate == dateKey;
    })
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<Task> getTasksForDate() {
    final dateKey = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    return taskBox.values
        .where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate == dateKey;
    })
        .toList();
  }

  void _addNote({bool isTask = false}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: Text(
            isTask ? 'Add Task' : 'Add Note',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxHeight: 400),
            padding: const EdgeInsets.only(top: 20),
            child: CupertinoTextField(
              controller: noteController,
              placeholder: isTask ? 'Enter task...' : 'Enter note...',
              style: const TextStyle(color: Colors.black, fontSize: 16),
              placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
              maxLines: null,
              minLines: 6,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                noteController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 18)),
            ),
            CupertinoDialogAction(
              onPressed: () {
                if (noteController.text.trim().isNotEmpty) {
                  final note = CalendarNote(
                    content: noteController.text.trim(),
                    date: widget.selectedDate,
                    isTask: isTask,
                    createdAt: DateTime.now(),
                  );
                  calendarBox.add(note);
                  noteController.clear();
                  setState(() {});
                  widget.onDataChanged?.call();
                }
                Navigator.pop(context);
              },
              isDefaultAction: true,
              child: const Text('Add', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _editNote(CalendarNote note) {
    noteController.text = note.content;
    showCupertinoDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: Text(
            note.isTask ? 'Edit Task' : 'Edit Note',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxHeight: 400),
            padding: const EdgeInsets.only(top: 20),
            child: CupertinoTextField(
              controller: noteController,
              placeholder: note.isTask ? 'Enter task...' : 'Enter note...',
              style: const TextStyle(color: Colors.black, fontSize: 16),
              placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
              maxLines: null,
              minLines: 6,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                noteController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 18)),
            ),
            CupertinoDialogAction(
              onPressed: () {
                if (noteController.text.trim().isNotEmpty) {
                  note.content = noteController.text.trim();
                  note.save();
                  noteController.clear();
                  setState(() {});
                  widget.onDataChanged?.call();
                }
                Navigator.pop(context);
              },
              isDefaultAction: true,
              child: const Text('Update', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleNoteTask(CalendarNote note) {
    note.isCompleted = !note.isCompleted;
    note.save();
    setState(() {});
    widget.onDataChanged?.call();
  }

  void _deleteNote(CalendarNote note) {
    note.delete();
    setState(() {});
    widget.onDataChanged?.call();
  }

  void _toggleTaskStatus(Task task) {
    task.isCompleted = !task.isCompleted;
    task.save();
    setState(() {});
    widget.onDataChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final notes = getNotesForDate();
    final tasks = getTasksForDate();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: Color(0xFF007AFF)),
        ),
        middle: Text(
          _formatDate(widget.selectedDate),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showAddOptions(),
          child: const Icon(CupertinoIcons.add, color: Color(0xFF007AFF)),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tasks section
              if (tasks.isNotEmpty) ...[
                const Text(
                  'Tasks Due Today',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: tasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      final isLast = index == tasks.length - 1;

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: isLast
                                ? BorderSide.none
                                : BorderSide(color: const Color(0xFFF2F2F7), width: 1),
                          ),
                        ),
                        child: CupertinoListTile(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          leading: GestureDetector(
                            onTap: () => _toggleTaskStatus(task),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: task.isCompleted
                                      ? const Color(0xFF007AFF)
                                      : CupertinoColors.systemGrey3,
                                  width: 2,
                                ),
                                color: task.isCompleted ? const Color(0xFF007AFF) : Colors.transparent,
                              ),
                              child: task.isCompleted
                                  ? const Icon(CupertinoIcons.check_mark, color: Colors.white, size: 14)
                                  : null,
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                              color: task.isCompleted ? CupertinoColors.systemGrey2 : Colors.black,
                            ),
                            maxLines: null,
                            softWrap: true,
                          ),
                          subtitle: task.notes.isNotEmpty
                              ? Text(
                            task.notes,
                            style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                            maxLines: null,
                            softWrap: true,
                          )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Notes section
              const Text(
                'Daily Planner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 12),

              if (notes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(CupertinoIcons.book, size: 48, color: CupertinoColors.systemGrey3),
                      SizedBox(height: 16),
                      Text(
                        'No notes for this day',
                        style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap + to add notes or activities',
                        style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey2),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: notes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final note = entry.value;
                      final isLast = index == notes.length - 1;

                      return Dismissible(
                        key: Key(note.key.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemRed,
                            borderRadius: BorderRadius.only(
                              topRight: index == 0 ? const Radius.circular(16) : Radius.zero,
                              bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
                            ),
                          ),
                          child: const Icon(CupertinoIcons.delete, color: Colors.white, size: 24),
                        ),
                        confirmDismiss: (direction) async {
                          return await showCupertinoDialog<bool>(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Delete Note', style: TextStyle(color: Colors.black, fontSize: 18)),
                              content: const Text(
                                'Are you sure you want to delete this note?',
                                style: TextStyle(color: Colors.black, fontSize: 16),
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                                ),
                                CupertinoDialogAction(
                                  onPressed: () => Navigator.pop(context, true),
                                  isDestructiveAction: true,
                                  child: const Text('Delete', style: TextStyle(fontSize: 18)),
                                ),
                              ],
                            ),
                          ) ?? false;
                        },
                        onDismissed: (direction) => _deleteNote(note),
                        child: GestureDetector(
                          onLongPress: () => _editNote(note),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: isLast
                                    ? BorderSide.none
                                    : BorderSide(color: const Color(0xFFF2F2F7), width: 1),
                              ),
                            ),
                            child: CupertinoListTile(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              leading: note.isTask
                                  ? GestureDetector(
                                onTap: () => _toggleNoteTask(note),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: note.isCompleted
                                          ? const Color(0xFF007AFF)
                                          : CupertinoColors.systemGrey3,
                                      width: 2,
                                    ),
                                    color: note.isCompleted ? const Color(0xFF007AFF) : Colors.transparent,
                                  ),
                                  child: note.isCompleted
                                      ? const Icon(CupertinoIcons.check_mark, color: Colors.white, size: 14)
                                      : null,
                                ),
                              )
                                  : Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF007AFF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(CupertinoIcons.book, color: Colors.white, size: 12),
                              ),
                              title: Text(
                                note.content,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration: note.isTask && note.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: note.isTask && note.isCompleted
                                      ? CupertinoColors.systemGrey2
                                      : Colors.black,
                                ),
                                maxLines: null,
                                softWrap: true,
                              ),
                              subtitle: Text(
                                note.isTask ? 'Task' : 'Note',
                                style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddOptions() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Add Daily Planner', style: TextStyle(fontSize: 18, color: Colors.black)),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              _addNote(isTask: true);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.pin_slash_fill, color: Color(0xFF007AFF)),
                SizedBox(width: 8),
                Text('Add Task', style: TextStyle(fontSize: 26)),
              ],
            ),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              _addNote(isTask: false);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.book, color: Color(0xFF007AFF)),
                SizedBox(width: 8),
                Text('Add Note', style: TextStyle(fontSize: 26)),
              ],
            ),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            isDefaultAction: true,
            child: const Text('Cancel', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return '${days[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }
}

class TodoListScreen extends StatefulWidget {
  final String? folderId;
  final String? folderName;
  final VoidCallback? onDataChanged;

  const TodoListScreen({Key? key, this.folderId, this.folderName, this.onDataChanged}) : super(key: key);

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Box<Task> taskBox;
  late Box<Folder> folderBox;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? selectedFolderId;

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('tasks');
    folderBox = Hive.box<Folder>('folders');
    selectedFolderId = widget.folderId;
  }

  void refreshStats() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  List<Task> get filteredTasks {
    final allTasks = taskBox.values.toList();
    if (widget.folderId != null) {
      return allTasks.where((task) => task.folderId == widget.folderId).toList();
    }
    return allTasks;
  }

  Map<String, List<Task>> get groupedTasks {
    final Map<String, List<Task>> grouped = {};
    for (final task in filteredTasks) {
      final dateKey = _formatDate(task.dueDate);
      if (!grouped.containsKey(dateKey)) grouped[dateKey] = [];
      grouped[dateKey]!.add(task);
    }
    grouped.forEach((key, tasks) {
      tasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return a.title.compareTo(b.title);
      });
    });
    return grouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    if (taskDate == today) return 'Today';
    if (taskDate == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (taskDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  int get totalTasks => filteredTasks.length;
  int get completedTasks => filteredTasks.where((task) => task.isCompleted).length;

  void _addTask() {
    if (titleController.text.trim().isEmpty) return;
    final task = Task(
      title: titleController.text.trim(),
      notes: notesController.text.trim(),
      dueDate: selectedDate,
      folderId: selectedFolderId,
    );
    taskBox.add(task);
    titleController.clear();
    notesController.clear();
    selectedDate = DateTime.now();
    setState(() {});
    widget.onDataChanged?.call();
  }

  void _editTask(Task task) {
    titleController.text = task.title;
    notesController.text = task.notes;
    selectedDate = task.dueDate;
    selectedFolderId = task.folderId;
    _showTaskDialog(isEditing: true, taskToEdit: task);
  }

  void _updateTask(Task task) {
    if (titleController.text.trim().isEmpty) return;
    task.title = titleController.text.trim();
    task.notes = notesController.text.trim();
    task.dueDate = selectedDate;
    task.folderId = selectedFolderId;
    task.save();
    titleController.clear();
    notesController.clear();
    selectedDate = DateTime.now();
    setState(() {});
    widget.onDataChanged?.call();
  }

  void _toggleTaskStatus(Task task) {
    task.isCompleted = !task.isCompleted;
    task.save();
    setState(() {});
    widget.onDataChanged?.call();
  }

  void _deleteTask(Task task) {
    task.delete();
    setState(() {});
    widget.onDataChanged?.call();
  }

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('About', style: TextStyle(color: Colors.black, fontSize: 18)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            Text('Developer:', style: TextStyle(color: Colors.black, fontSize: 14)),
            SizedBox(height: 4),
            Text(
              'Digman, Christian D.',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog({bool isEditing = false, Task? taskToEdit}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: Text(
            isEditing ? 'Edit Task' : 'Add New Task',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoTextField(
                    controller: titleController,
                    placeholder: 'Task title',
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
                    maxLines: null,
                    minLines: 2,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: notesController,
                    placeholder: 'Notes (optional)',
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
                    maxLines: null,
                    minLines: 4,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Due Date: ',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          color: const Color(0xFF007AFF),
                          borderRadius: BorderRadius.circular(8),
                          onPressed: () => _showDatePickerDialog(setDialogState),
                          child: Text(
                            _formatDate(selectedDate),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (folderBox.values.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Folder: ',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        Expanded(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            color: const Color(0xFF007AFF),
                            borderRadius: BorderRadius.circular(8),
                            onPressed: () => _showFolderPicker(setDialogState),
                            child: Text(
                              selectedFolderId != null
                                  ? folderBox.values
                                  .firstWhere(
                                    (f) => f.key.toString() == selectedFolderId,
                                orElse: () => Folder(name: 'Unknown', createdAt: DateTime.now()),
                              )
                                  .name
                                  : 'No folder',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                titleController.clear();
                notesController.clear();
                selectedDate = DateTime.now();
                selectedFolderId = widget.folderId;
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 18)),
            ),
            CupertinoDialogAction(
              onPressed: () {
                if (isEditing && taskToEdit != null) {
                  _updateTask(taskToEdit);
                } else {
                  _addTask();
                }
                Navigator.pop(context);
              },
              isDefaultAction: true,
              child: Text(isEditing ? 'Update' : 'Add', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFolderPicker(StateSetter setDialogState) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Select Folder',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: SizedBox(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              if (index == 0) {
                selectedFolderId = null;
              } else {
                selectedFolderId = folderBox.values.elementAt(index - 1).key.toString();
              }
              setDialogState(() {});
            },
            children: [
              const Center(child: Text('No folder', style: TextStyle(color: Colors.black, fontSize: 16))),
              ...folderBox.values.map((folder) => Center(
                child: Text(
                  '${folder.icon} ${folder.name}',
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              )),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _showDatePickerDialog(StateSetter setDialogState) {
    DateTime tempDate = selectedDate;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Select Due Date',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: SizedBox(
          height: 250,
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(initialItem: tempDate.month - 1),
                  onSelectedItemChanged: (index) {
                    tempDate = DateTime(tempDate.year, index + 1, tempDate.day);
                  },
                  children: const [
                    Center(child: Text('January', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('February', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('March', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('April', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('May', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('June', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('July', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('August', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('September', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('October', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('November', style: TextStyle(color: Colors.black, fontSize: 16))),
                    Center(child: Text('December', style: TextStyle(color: Colors.black, fontSize: 16))),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(initialItem: tempDate.day - 1),
                        onSelectedItemChanged: (index) {
                          tempDate = DateTime(tempDate.year, tempDate.month, index + 1);
                        },
                        children: List.generate(31, (index) => Center(
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.black, fontSize: 16)),
                        )),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(initialItem: tempDate.year - 2020),
                        onSelectedItemChanged: (index) {
                          tempDate = DateTime(2020 + index, tempDate.month, tempDate.day);
                        },
                        children: List.generate(20, (index) => Center(
                          child: Text('${2020 + index}', style: const TextStyle(color: Colors.black, fontSize: 16)),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 18)),
          ),
          CupertinoDialogAction(
            onPressed: () {
              selectedDate = tempDate;
              setDialogState(() {});
              Navigator.pop(context);
            },
            isDefaultAction: true,
            child: const Text('Done', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupedTasks;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text(
          widget.folderName ?? 'All Tasks',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showTaskDialog(),
          child: const Icon(CupertinoIcons.add, color: Color(0xFF007AFF)),
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.folderId != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Icon(CupertinoIcons.back, color: Color(0xFF007AFF)),
              ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showAboutDialog,
              child: const Icon(CupertinoIcons.info, color: Color(0xFF007AFF)),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Text('$totalTasks', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
                          const Text('Total Tasks', style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Text('$completedTasks', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
                          const Text('Completed', style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Text('${totalTasks - completedTasks}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
                          const Text('Pending', style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: grouped.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.checkmark_circle, size: 80, color: CupertinoColors.systemGrey3),
                    SizedBox(height: 20),
                    Text('No tasks yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: CupertinoColors.systemGrey)),
                    SizedBox(height: 8),
                    Text('Tap + to add your first task', style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey2)),
                  ],
                ),
              )
                  : CupertinoScrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, index) {
                    final dateKey = grouped.keys.elementAt(index);
                    final tasks = grouped[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
                          child: Text(
                            dateKey,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: CupertinoColors.systemGrey),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            children: tasks.asMap().entries.map((entry) {
                              final taskIndex = entry.key;
                              final task = entry.value;
                              final isLast = taskIndex == tasks.length - 1;

                              return Dismissible(
                                key: Key(task.key.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemRed,
                                    borderRadius: BorderRadius.only(
                                      topRight: taskIndex == 0 ? const Radius.circular(16) : Radius.zero,
                                      bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
                                    ),
                                  ),
                                  child: const Icon(CupertinoIcons.delete, color: Colors.white, size: 24),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showCupertinoDialog<bool>(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Delete Task', style: TextStyle(color: Colors.black, fontSize: 18)),
                                      content: const Text(
                                        'Are you sure you want to delete this task?',
                                        style: TextStyle(color: Colors.black, fontSize: 16),
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                                        ),
                                        CupertinoDialogAction(
                                          onPressed: () => Navigator.pop(context, true),
                                          isDestructiveAction: true,
                                          child: const Text('Delete', style: TextStyle(fontSize: 18)),
                                        ),
                                      ],
                                    ),
                                  ) ?? false;
                                },
                                onDismissed: (direction) => _deleteTask(task),
                                child: GestureDetector(
                                  onLongPress: () => _editTask(task),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: isLast
                                            ? BorderSide.none
                                            : BorderSide(color: const Color(0xFFF2F2F7), width: 1),
                                      ),
                                    ),
                                    child: CupertinoListTile(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      leading: GestureDetector(
                                        onTap: () => _toggleTaskStatus(task),
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: task.isCompleted
                                                  ? const Color(0xFF007AFF)
                                                  : CupertinoColors.systemGrey3,
                                              width: 2,
                                            ),
                                            color: task.isCompleted ? const Color(0xFF007AFF) : Colors.transparent,
                                          ),
                                          child: task.isCompleted
                                              ? const Icon(CupertinoIcons.check_mark, color: Colors.white, size: 16)
                                              : null,
                                        ),
                                      ),
                                      title: Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: task.isCompleted ? CupertinoColors.systemGrey2 : Colors.black,
                                        ),
                                        maxLines: null,
                                        softWrap: true,
                                      ),
                                      subtitle: task.notes.isNotEmpty
                                          ? Text(
                                        task.notes,
                                        style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                                        maxLines: null,
                                        softWrap: true,
                                      )
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoldersScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const FoldersScreen({Key? key, this.onDataChanged}) : super(key: key);

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  late Box<Folder> folderBox;
  late Box<Task> taskBox;
  final TextEditingController folderNameController = TextEditingController();
  String selectedIcon = '📁';

  final List<String> folderIcons = [
    '📁', '📂', '🏠', '💼', '🎯', '💡', '📚', '🛍️',
    '🏋️', '🍳', '🧘', '🎨', '💻', '📱', '🚗', '✈️',
  ];

  @override
  void initState() {
    super.initState();
    folderBox = Hive.box<Folder>('folders');
    taskBox = Hive.box<Task>('tasks');
  }

  void refreshStats() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    folderNameController.dispose();
    super.dispose();
  }

  int getTaskCountForFolder(String folderId) {
    return taskBox.values.where((task) => task.folderId == folderId).length;
  }

  void _addFolder() {
    if (folderNameController.text.trim().isEmpty) return;
    final folder = Folder(
      name: folderNameController.text.trim(),
      icon: selectedIcon,
      createdAt: DateTime.now(),
    );
    folderBox.add(folder);
    folderNameController.clear();
    selectedIcon = '📁';
    setState(() {});
    widget.onDataChanged?.call();
  }

  void _editFolder(Folder folder) {
    folderNameController.text = folder.name;
    selectedIcon = folder.icon;
    _showFolderDialog(isEditing: true, folderToEdit: folder);
  }

  void _updateFolder(Folder folder) {
    if (folderNameController.text.trim().isEmpty) return;
    folder.name = folderNameController.text.trim();
    folder.icon = selectedIcon;
    folder.save();
    folderNameController.clear();
    selectedIcon = '📁';
    setState(() {});
    widget.onDataChanged?.call();
  }

  void _deleteFolder(Folder folder) {
    final tasksToDelete = taskBox.values.where((task) => task.folderId == folder.key.toString()).toList();
    for (final task in tasksToDelete) {
      task.delete();
    }
    folder.delete();
    setState(() {});
    widget.onDataChanged?.call();
  }

  void _showFolderDialog({bool isEditing = false, Folder? folderToEdit}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: Text(
            isEditing ? 'Edit Folder' : 'Add New Folder',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxHeight: 350),
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoTextField(
                  controller: folderNameController,
                  placeholder: 'Folder name',
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Choose Icon:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: folderIcons.length,
                    itemBuilder: (context, index) {
                      final icon = folderIcons[index];
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () {
                          selectedIcon = icon;
                          setDialogState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF007AFF).withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected ? Border.all(color: const Color(0xFF007AFF), width: 2) : null,
                          ),
                          child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                folderNameController.clear();
                selectedIcon = '📁';
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 18)),
            ),
            CupertinoDialogAction(
              onPressed: () {
                if (isEditing && folderToEdit != null) {
                  _updateFolder(folderToEdit);
                } else {
                  _addFolder();
                }
                Navigator.pop(context);
              },
              isDefaultAction: true,
              child: Text(isEditing ? 'Update' : 'Add', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: const Text('Folders', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showFolderDialog(),
          child: const Icon(CupertinoIcons.add, color: Color(0xFF007AFF)),
        ),
      ),
      child: SafeArea(
        child: folderBox.values.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.folder, size: 80, color: CupertinoColors.systemGrey3),
              SizedBox(height: 20),
              Text('No folders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: CupertinoColors.systemGrey)),
              SizedBox(height: 8),
              Text('Tap + to create your first folder', style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey2)),
            ],
          ),
        )
            : CupertinoScrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: folderBox.values.length,
            itemBuilder: (context, index) {
              final folder = folderBox.values.elementAt(index);
              final taskCount = getTaskCountForFolder(folder.key.toString());

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Dismissible(
                  key: Key(folder.key.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(color: CupertinoColors.systemRed, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(CupertinoIcons.delete, color: Colors.white, size: 24),
                  ),
                  confirmDismiss: (direction) async {
                    return await showCupertinoDialog<bool>(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Delete Folder', style: TextStyle(color: Colors.black, fontSize: 18)),
                        content: Text(
                          'Are you sure you want to delete "${folder.name}"? This will also delete all tasks in this folder.',
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                          ),
                          CupertinoDialogAction(
                            onPressed: () => Navigator.pop(context, true),
                            isDestructiveAction: true,
                            child: const Text('Delete', style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) => _deleteFolder(folder),
                  child: GestureDetector(
                    onLongPress: () => _editFolder(folder),
                    child: CupertinoListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => TodoListScreen(
                              folderId: folder.key.toString(),
                              folderName: folder.name,
                              onDataChanged: widget.onDataChanged,
                            ),
                          ),
                        );
                      },
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text(folder.icon, style: const TextStyle(fontSize: 24))),
                      ),
                      title: Text(
                        folder.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                        maxLines: null,
                        softWrap: true,
                      ),
                      subtitle: Text('$taskCount tasks', style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey)),
                      trailing: GestureDetector(
                        onTap: () => _editFolder(folder),
                        child: const Icon(CupertinoIcons.ellipsis_vertical, color: CupertinoColors.systemGrey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Box<Task> taskBox;
  late Box<Folder> folderBox;
  late Box<CalendarNote> calendarBox;

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('tasks');
    folderBox = Hive.box<Folder>('folders');
    calendarBox = Hive.box<CalendarNote>('calendar_notes');
  }

  void refreshStats() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = taskBox.length;
    final completedTasks = taskBox.values.where((task) => task.isCompleted).length;
    final totalFolders = folderBox.length;
    final totalNotes = calendarBox.length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;
    final recentTasks = taskBox.values.toList()..sort((a, b) => b.dueDate.compareTo(a.dueDate));
    final tasksToShow = recentTasks.take(5).toList();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: Text('Statistics', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard(title: 'Total Tasks', value: '$totalTasks', icon: CupertinoIcons.list_bullet)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(title: 'Folders', value: '$totalFolders', icon: CupertinoIcons.folder)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard(title: 'Completed', value: '$completedTasks', icon: CupertinoIcons.checkmark_circle_fill)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(title: 'Notes', value: '$totalNotes', icon: CupertinoIcons.book)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    const Text('Completion Rate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 16),
                    Text('$completionRate%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
                    const SizedBox(height: 12),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(4)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: completionRate / 100,
                        child: Container(decoration: BoxDecoration(color: const Color(0xFF007AFF), borderRadius: BorderRadius.circular(4))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 16),
              ...tasksToShow.map((task) {
                String? folderName;
                if (task.folderId != null) {
                  try {
                    final folder = folderBox.values.firstWhere((f) => f.key.toString() == task.folderId);
                    folderName = folder.name;
                  } catch (e) {
                    folderName = null;
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        task.isCompleted ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                        color: task.isCompleted ? const Color(0xFF007AFF) : CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: task.isCompleted ? CupertinoColors.systemGrey2 : Colors.black,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                              maxLines: null,
                              softWrap: true,
                            ),
                            if (task.notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.notes,
                                style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                                maxLines: null,
                                softWrap: true,
                              ),
                            ],
                            if (folderName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Folder: $folderName',
                                style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey2, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (taskBox.values.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: const Column(
                    children: [
                      Icon(CupertinoIcons.chart_bar, size: 48, color: CupertinoColors.systemGrey3),
                      SizedBox(height: 16),
                      Text('No data yet', style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey)),
                      SizedBox(height: 8),
                      Text('Create some tasks to see your statistics', style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey2)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF007AFF)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
        ],
      ),
    );
  }
}