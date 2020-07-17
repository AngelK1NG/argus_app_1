import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:provider/provider.dart';

class TaskItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);

    return Container(
        child: Dismissible(
            background: Container(color: Colors.red),
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              firestoreProvider.deleteTask(date, id);
              onDismissed();
            },
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
                      onFieldSubmitted: (value) {
                        firestoreProvider.updateTaskName(value, date, id);
                      },
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
