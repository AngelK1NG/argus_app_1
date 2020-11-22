import 'package:Focal/utils/user.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:provider/provider.dart';
import 'package:Focal/constants.dart';

// ignore: must_be_immutable
class TaskItem extends StatefulWidget {
  String name;
  String id;
  bool completed;
  bool paused;
  int order;
  Function onDismissed;
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
  }

  @override
  Widget build(BuildContext context) {
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0,
          left: 25,
          right: 25,
          child: Container(height: 1, color: Theme.of(context).dividerColor),
        ),
        Dismissible(
          background: Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.only(left: 25),
            alignment: AlignmentDirectional.centerStart,
            child: Icon(
              FeatherIcons.sunrise,
              color: Colors.white,
              size: 20,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            padding: EdgeInsets.only(right: 25),
            alignment: AlignmentDirectional.centerEnd,
            child: Icon(
              FeatherIcons.trash,
              color: Colors.white,
              size: 20,
            ),
          ),
          key: UniqueKey(),
          direction: widget.completed
              ? DismissDirection.endToStart
              : DismissDirection.horizontal,
          onDismissed: widget.onDismissed,
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
                        : widget.order <= 3
                            ? Container(
                                alignment: Alignment.center,
                                width: 10,
                                child: Text(
                                  widget.order.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                            : Image(
                                image: AssetImage(
                                    'assets/images/icons/Task Icon_Unfilled.png'),
                                width: 10,
                                height: 10,
                              ),
                  ),
                  SizedBox(
                    height: 55,
                    width: SizeConfig.safeBlockHorizontal * 100 - 75,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Focus(
                        onFocusChange: (focus) {
                          if (!focus && _formKey.currentState.validate()) {
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
                            style: widget.completed
                                ? TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.lineThrough,
                                    color: Theme.of(context).hintColor)
                                : TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: widget.paused
                                        ? Theme.of(context).primaryColor
                                        : jetBlack),
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
                                  ? 'A task cannot be empty'
                                  : null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              height: 55,
              width: SizeConfig.safeBlockHorizontal * 100,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }
}
