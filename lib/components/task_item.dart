import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TaskItem extends StatefulWidget {
  String name;
  String id;
  bool completed;
  bool paused;
  bool newTask;
  int order;
  VoidCallback onDismissed;
  Function onUpdate;
  String date;
  int secondsFocused;
  int secondsDistracted;
  int numPaused;
  int numDistracted;

  TaskItem(
      {@required this.name,
      this.id,
      @required this.completed,
      this.paused,
      this.order,
      this.newTask,
      this.onDismissed,
      this.onUpdate,
      @required this.date,
      this.secondsFocused,
      this.secondsDistracted,
      this.numPaused,
      this.numDistracted,
      Key key})
      : super(key: key);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _active = false;
  FocusNode _focus = new FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.newTask == true) {
      _active = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    return Container(
        child: Dismissible(
            background: Container(color: Colors.red),
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) => widget.onDismissed(),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (!widget.completed) {
                    _active = true;
                    Future.delayed(Duration(milliseconds: 50), () {
                      FocusScope.of(context).requestFocus(_focus);
                    });
                  }
                });
              },
              behavior: HitTestBehavior.deferToChild,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(left: 25, right: 15),
                        child: widget.completed
                            ? Image(
                                image: AssetImage(
                                    'assets/images/icons/Task Icon_Filled.png'),
                                width: 10,
                                height: 10,
                              )
                            : Image(
                                image: AssetImage(
                                    'assets/images/icons/Task Icon_Unfilled.png'),
                                width: 10,
                                height: 10,
                              )),
                    SizedBox(
                        height: 55,
                        width: SizeConfig.safeBlockHorizontal * 100 - 75,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Focus(
                              onFocusChange: (focus) {
                                if (!focus &&
                                    _formKey.currentState.validate()) {
                                  setState(() {
                                    _active = false;
                                  });
                                }
                                if (!_formKey.currentState.validate()) {
                                  _focus.requestFocus();
                                }
                              },
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  focusNode: _focus,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  initialValue: widget.name,
                                  autofocus: true,
                                  enabled: _active,
                                  onChanged: (value) {
                                    Future.delayed(Duration.zero, () {
                                      if (_formKey.currentState.validate()) {
                                        widget.onUpdate(value);
                                        firestoreProvider.updateTaskName(
                                            value, widget.id, widget.date);
                                      }
                                    });
                                  },
                                  validator: (value) {
                                    return value.isEmpty
                                        ? 'You cannot add an empty task'
                                        : null;
                                  },
                                ),
                              ),
                            ))),
                  ],
                ),
                height: 55,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
              ),
            )));
  }
}
