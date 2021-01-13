import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/database.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/components/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskInput extends StatefulWidget {
  TaskInput({Key key}) : super(key: key);

  @override
  _TaskInputState createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  bool _loading = true;
  SharedPreferences _prefs;
  FocusNode _focusNode = FocusNode();
  TextEditingController _input = TextEditingController();

  void submit(UserStatus user, List uncompletedTasks) {
    if (_input.text.isNotEmpty) {
      int index = 0;
      uncompletedTasks.forEach((task) {
        if (task.date == getDateString(DateTime.now())) {
          index += 1;
        }
      });
      Task newTask = Task(
        index: index,
        name: _input.text,
        date: getDateString(DateTime.now()),
        completed: false,
        paused: false,
        seconds: 0,
      );
      newTask.addDoc(user);
      _prefs.setString('taskInput', null);
      _input.clear();
      _focusNode.requestFocus();
      HapticFeedback.heavyImpact();
    } else {
      _focusNode.requestFocus();
      HapticFeedback.vibrate();
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
        _input.text = _prefs.getString('taskInput');
        _input.selection = TextSelection.fromPosition(
          TextPosition(offset: _input.text.length),
        );
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserStatus>(context);
    var uncompletedTasks = Provider.of<UncompletedTasks>(context).tasks;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _loading ? 0 : 0.1,
            duration: keyboardDuration,
            curve: keyboardCurve,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _loading = true;
                });
                _focusNode.unfocus();
                Future.delayed(keyboardDuration, () {
                  Navigator.of(context).pop();
                });
              },
              child: SizedBox.expand(
                child: Container(color: black),
              ),
            ),
          ),
          AnimatedPositioned(
            left: 0,
            right: 0,
            bottom:
                _loading ? -100 - MediaQuery.of(context).viewInsets.bottom : 0,
            duration: keyboardDuration,
            curve: keyboardCurve,
            child: Container(
              height: 100 + MediaQuery.of(context).viewInsets.bottom,
              decoration: BoxDecoration(
                color: white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(0, -4),
                    color: Theme.of(context).shadowColor,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Container(
                      height: 50,
                      width: SizeConfig.safeWidth - 30,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Add a new task",
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: black,
                        ),
                        autofocus: true,
                        focusNode: _focusNode,
                        controller: _input,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            _prefs.setString('taskInput', value);
                          });
                        },
                        onFieldSubmitted: (_) => submit(user, uncompletedTasks),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: GestureDetector(
                          child: Container(
                            height: 50,
                            width: 100,
                            child: Row(
                              children: [
                                Icon(
                                  FeatherIcons.calendar,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text(
                                    'Today',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => submit(user, uncompletedTasks),
                        child: Container(
                          height: 50,
                          width: 50,
                          color: Colors.transparent,
                          child: Icon(
                            FeatherIcons.plusCircle,
                            size: 20,
                            color: _input.text.isEmpty
                                ? Theme.of(context).hintColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
