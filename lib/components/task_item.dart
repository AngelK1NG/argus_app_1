import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TaskItem extends StatelessWidget {
  final String name;

  const TaskItem({@required this.name, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Dismissible(
            background: Container(color: Colors.red),
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) => {},
            child: Container(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 35, right: 15),
                    child: FaIcon(FontAwesomeIcons.ellipsisV, size: 15),
                  ),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 100,
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      initialValue: name,
                      autofocus: false,
                      onSaved: (value) {},
                    ),
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
            )));
  }
}
