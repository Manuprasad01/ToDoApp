import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TasksPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const TasksPage(
      {super.key, required this.categoryId, required this.categoryName});

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isSearching = false;

  void _addTaskDialog() {
    TextEditingController taskController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(hintText: 'Enter task'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(selectedDate == null
                  ? 'Pick Due Date'
                  : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (taskController.text.isNotEmpty && selectedDate != null) {
                _addTask(taskController.text, selectedDate!);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter task and pick a date")),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTask(String task, DateTime dueDate) async {
    await _firestore.collection('tasks').add({
      'categoryId': widget.categoryId,
      'title': task,
      'completed': false,
      'dueDate': Timestamp.fromDate(dueDate),
      'titleLowerCase': task.toLowerCase(), // For case-insensitive search
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _firestore
        .collection('tasks')
        .doc(taskId)
        .update({'completed': !isCompleted});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Text(
                widget.categoryName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchController.clear();
                _searchQuery = "";
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tasks')
            .where('categoryId', isEqualTo: widget.categoryId)
            .orderBy('dueDate') // ✅ Keeps sorting by due date
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var tasks = snapshot.data!.docs;

          // ✅ Apply search locally
          if (_searchQuery.isNotEmpty) {
            tasks = tasks.where((task) {
              var taskData = task.data() as Map<String, dynamic>;
              return taskData['title']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery);
            }).toList();
          }

          // 🔹 Group tasks by formatted date
          Map<String, List<DocumentSnapshot>> groupedTasks = {};
          for (var task in tasks) {
            var taskData = task.data() as Map<String, dynamic>;
            DateTime dueDate = (taskData['dueDate'] as Timestamp).toDate();
            String formattedDate = _getFormattedDate(dueDate);

            if (!groupedTasks.containsKey(formattedDate)) {
              groupedTasks[formattedDate] = [];
            }
            groupedTasks[formattedDate]!.add(task);
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: groupedTasks.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ...entry.value.map((task) {
                    var taskData = task.data() as Map<String, dynamic>;

                    return ListTile(
                      leading: Icon(
                        taskData['completed']
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color:
                            taskData['completed'] ? Colors.green : Colors.grey,
                      ),
                      title: Text(taskData['title'],
                          style: TextStyle(fontSize: 16)),
                      onTap: () =>
                          _toggleTaskCompletion(task.id, taskData['completed']),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskDialog,
        child: Icon(Icons.add, size: 30),
      ),
    );
  }

  /// Formats the date for grouping
  String _getFormattedDate(DateTime date) {
    DateTime today = DateTime.now();
    DateTime tomorrow = today.add(Duration(days: 1));

    if (_isSameDay(date, today)) {
      return "Today";
    } else if (_isSameDay(date, tomorrow)) {
      return "Tomorrow";
    } else {
      return "${_getWeekday(date)}, ${_formatDate(date)}";
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getWeekday(DateTime date) {
    List<String> weekdays = [
      "Sun",
      "Mon",
      "Tues",
      "Wed",
      "Thurs",
      "Fri",
      "Sat"
    ];
    return weekdays[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_getMonth(date)} ${date.year}";
  }

  String _getMonth(DateTime date) {
    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[date.month - 1];
  }
}
