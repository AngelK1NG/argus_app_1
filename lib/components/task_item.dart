import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:provider/provider.dart';

class TaskItem extends StatefulWidget {
  final String name;
  final String id;
  final bool completed;
  final int order;
  final VoidCallback onDismissed;
  final String date;

  const TaskItem(
      {@required this.name,
      this.id,
      @required this.completed,
      this.order,
      @required this.onDismissed,
      @required this.date,
      Key key})
      : super(key: key);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _active = false;
  FocusNode _focus = new FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) {
        setState(() {_active = false;});
      }
    });
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
            onDismissed: (direction) {
              firestoreProvider.deleteTask(widget.date, widget.id);
              widget.onDismissed();
            },
            child: GestureDetector(
              onDoubleTap: () {
                setState(() {
                  _active = true;
                });
                _focus.requestFocus();
              },
              behavior: HitTestBehavior.deferToChild,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 35, right: 15),
                      child: FaIcon(FontAwesomeIcons.ellipsisV, size: 15),
                    ),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 56,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _active 
                          ? TextFormField(
                            focusNode: _focus,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            initialValue: widget.name,
                            autofocus: false,
                            onFieldSubmitted: (value) {
                              firestoreProvider.updateTaskName(value, widget.date, widget.id);
                            },
                          )
                          : Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      )
                    ),
                  ],
                ),
                height: 50,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ))),
              ),
            )));
  }
}
