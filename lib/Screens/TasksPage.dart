import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Components/WrapperWidget.dart';

class TasksPage extends StatefulWidget {
  TasksPage({Key key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  bool _navActive = false;
  List _tasks = new List();
  
  void toggleNav() {
    setState(() {
      _navActive = !_navActive;
    });
  }

  List<Widget> mapTasks() {
    List<Widget> tasks = [];
    _tasks.forEach((task) {
      tasks.add(Dismissible(
        background: Container(color: Colors.red),
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          setState(() {
            _tasks.removeWhere((item) => item["id"] == task["id"]);
          });
        },
        child: new Container(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 15),
                child: FaIcon(FontAwesomeIcons.ellipsisV, size: 15),
              ),
              Text(task["name"], style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              )),
            ],
          ),
          height: 50,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color(0xffe2e2e2)))),
        ),
      ));
    });
    return tasks;
  }

  @override
  void initState() { 
    super.initState();
    List<Object> tasks = [{"id": 1,"name": "AP Bio Reading U7 p37-39"}, {"id": 2, "name": "APUSH Reading p69-420"}];
    setState(() {
      _tasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WrapperWidget(
      nav: true,
      child: Stack(
        children: <Widget>[
          Positioned (
            right: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 38, top: 30,),
              child: Row(
                children: <Widget>[
                  Text("Today", style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),),
                  Container(
                    padding: const EdgeInsets.only(left: 10,),
                    width: 35,
                    child: IconButton(
                      onPressed: () {},
                      icon: FaIcon(FontAwesomeIcons.calendar)
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            top: 100,
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: ReorderableListView(
                header: GestureDetector(
                  onTap: () {},
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 31, right: 11),
                          child: FaIcon(FontAwesomeIcons.plus, size: 15, color: Theme.of(context).hintColor,),
                        ),
                        Text("Add task", style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).hintColor,
                        )),
                      ],
                    ),
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Theme.of(context).dividerColor,))),
                  ),
                ),
                onReorder: ((oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  setState(() {
                    final task = _tasks.removeAt(oldIndex);
                    _tasks.insert(newIndex, task);
                  });
                }),
                children: mapTasks(),
              ),
            ),
          ),
        ]
      ),
    );
  }
}