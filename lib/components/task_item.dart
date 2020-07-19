import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TaskItem extends StatefulWidget {
  final String name;
  String id;
  final bool completed;
  final int order;
  final VoidCallback onDismissed;
  final String date;

  TaskItem(
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
        setState(() {
          _active = false;
        });
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
              firestoreProvider.deleteTask(
                  widget.date, widget.id, widget.completed);
              widget.onDismissed();
            },
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (!widget.completed) {
                    _active = true;
                  }
                });
              },
              behavior: HitTestBehavior.deferToChild,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(left: 33, right: 15),
                        child: widget.completed
                            ? Image(
                                image:
                                    AssetImage('images/Task Icon_Filled.png'),
                                width: 10,
                                height: 10,
                              )
                            : Image(
                                image:
                                    AssetImage('images/Task Icon_Unfilled.png'),
                                width: 10,
                                height: 10,
                              )),
                    SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 58,
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
                                  autofocus: true,
                                  onFieldSubmitted: (value) {
                                    firestoreProvider.updateTaskName(
                                        value, widget.date, widget.id);
                                  },
                                )
                              : Text(
                                  widget.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: widget.completed
                                        ? Theme.of(context).hintColor
                                        : Colors.black,
                                  ),
                                ),
                        )),
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
