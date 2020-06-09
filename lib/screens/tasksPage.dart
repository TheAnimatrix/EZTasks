import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:getflutter/components/list_tile/gf_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';
import 'package:tasks/auth/AuthService.dart';
import 'package:tasks/getIt.dart';
import 'package:tasks/helpers/loaderDialog.dart';
import 'package:tasks/helpers/newTaskDialog.dart';
import 'package:tasks/helpers/pubfunctions.dart';
import 'package:tasks/helpers/task.dart';
import 'package:tasks/services/taskManager.dart';
import 'package:intl/intl.dart';
import '../register.dart';

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  ScrollController _controller = ScrollController();
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      getIt<TaskManager>().getAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withAlpha(230),
        body: Stack(
          fit: StackFit.expand,
          overflow: Overflow.visible,
          alignment: Alignment.topCenter,
          children: [
            Positioned(top:0,left:0,right:0,child:getNavBar()),
            Transform.translate(
              offset: Offset(0, navBarHeight + 10),
              child: placeholderDataPage(),
            ),
          ],
        ));
  }

  ScrollController _scrollController = ScrollController();

  placeholderDataPage() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: FractionallySizedBox(
        widthFactor: MediaQuery.of(context).size.width < 600 ? 1 : 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LimitedBox(
              maxHeight: 200,
              child: StreamBuilder<Object>(
                  stream: getIt<TaskManager>().taskStream.stream,
                  builder: (context, snapshot) {
                    var taskList = getIt<TaskManager>().getTasksInProgress();
                    print("${taskList.length}");
                    if (taskList.length > 0)
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                              child: Text(
                                "In Progress",
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 150,
                              child: _inProgressList(taskList),
                            ),
                          ),
                        ],
                      );
                    else
                      return SizedBox.shrink();
                  }),
            ),
            Container(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text("All Tasks", style: TextStyle(fontSize: 22)),
                  ),
                  Spacer(),
                  Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        child: Icon(Icons.filter_list),
                        onPressed: () {
                          showFilterDialog(context);
                        },
                      ))
                ],
              ),
            ),
            StreamBuilder<bool>(
                stream: getIt<TaskManager>().taskStream.stream,
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        int len = getIt<TaskManager>().taskList.length;

                        if (len == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 100,
                              child: Card(
                                color: Colors.white12,
                                child: ListTile(
                                  title: Text("No Tasks"),
                                ),
                              ),
                            ),
                          );
                        }
                        if (len - 1 == i)
                          return _listItem(context, i,
                              const EdgeInsets.fromLTRB(8, 8, 8, 30));
                        return _listItem(context, i, const EdgeInsets.fromLTRB(8,8,8,16));
                      },
                      itemCount: getIt<TaskManager>().taskList.length == 0
                          ? 1
                          : getIt<TaskManager>().taskList.length,
                    );
                  } else
                    return CircularProgressIndicator();
                }),
            StreamBuilder<Object>(
              stream: getIt<TaskManager>().taskStream.stream,
              builder: (context, snapshot) {
                if(snapshot.data == true)
                return (getIt<TaskManager>().completedList.length==0)?SizedBox.shrink():Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text("Completed Tasks", style: TextStyle(fontSize: 22)),
                      ),
                      Spacer(),
                      Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        onPressed: () {
                          print("tap");
                          getIt<TaskManager>().showCompletedTasks = !getIt<TaskManager>().showCompletedTasks;
                          getIt<TaskManager>().notifyListeners();
                        },
                                              child: (getIt<TaskManager>().showCompletedTasks)?Icon(Icons.arrow_upward):Icon(Icons.arrow_downward),
                      ))
                    ],
                  ),
                );
                else return SizedBox.shrink();
              }
            ),
            StreamBuilder<bool>(
                stream: getIt<TaskManager>().taskStream.stream,
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return (getIt<TaskManager>().completedList.length==0 || (!getIt<TaskManager>().showCompletedTasks))?Container(height: 20):ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        int len = getIt<TaskManager>().completedList.length;

                        if (len == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 100,
                              child: Card(
                                color: Colors.white12,
                                child: ListTile(
                                  title: Text("No Tasks"),
                                ),
                              ),
                            ),
                          );
                        }
                        if (len - 1 == i)
                          return _listItem(context, i,
                              const EdgeInsets.fromLTRB(8, 8, 8, 150),taskList: getIt<TaskManager>().completedList);
                        return _listItem(context, i, const EdgeInsets.all(8),taskList: getIt<TaskManager>().completedList);
                      },
                      itemCount:  getIt<TaskManager>().completedList.length,
                    );
                  } else
                    return SizedBox.shrink();
                })
          ],
        ),
      ),
    );
  }

  var dateFormatter = new DateFormat('d MMMM yyyy').add_jm();
  _listItem(context, i, padding , {List<Task> taskList}) {
    bool isCompletedList = false;
    if(taskList == null) {taskList = getIt<TaskManager>().taskList;}else{print("random bs ${taskList.length}");isCompletedList=true;}
    
    return Padding(
      padding: padding,
      child: LimitedBox(
        maxHeight: 500,
        child: Stack(
          fit: StackFit.loose,
          overflow: Overflow.visible,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: taskList[i].getColor(),
                  child: GFListTile(
                    title: Text("task: ${taskList[i].task}",style:TextStyle(color:taskList[i].getColor().computeLuminance() > 0.5 ? Colors.black : Colors.white)),
                    description: Text(
                      "status: ${taskList[i].status}\nlabel: ${taskList[i].labels}",
                      style: TextStyle(color:taskList[i].getColor().computeLuminance() > 0.5 ? Colors.black54 : Colors.white70),
                    ),
                    icon: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                            onTap: () async {
                              print("delete");
                              showLoadingDialog(context);
                              Map response = await getIt<TaskManager>().deleteAt(i,fromCompletedList: isCompletedList);
                              if (response["error"]) {
                                Navigator.of(context).pop();
                                showErrorDialog(context, response["message"]);
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Icon(Icons.delete,color:taskList[i].getColor().computeLuminance() > 0.5 ? Colors.black : Colors.white),
                            )),
                        (taskList[i].getUpdateStatusIndex() !=
                                2)
                            ? InkWell(
                                onTap: () async {
                                  print("filter 2");
                                  getIt<TaskManager>().updateAt(i);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: _updateChildIcon(taskList,i),
                                ))
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: -5,top:-10,
                          child: Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: Color.alphaBlend(Colors.white24,(taskList[i].getColor() as Color)),
                 child: Padding(
                   padding: const EdgeInsets.all(12),
                   child: Text("${dateFormatter.format(DateTime.fromMillisecondsSinceEpoch(taskList[i].dueDateTimeStamp))}    ",style: TextStyle(color:taskList[i].getColor().computeLuminance() > 0.5 ? Colors.black : Colors.white,fontSize: 16,fontWeight: FontWeight.w800),),
                 ),
                          )
            ),
          ],
        ),
      ),
    );
  }

  _updateChildIcon(taskList,i) {
    switch (getIt<TaskManager>().taskList[i].getUpdateStatusIndex()) {
      case 2:
        return SizedBox.shrink();
      case 1:
        return Icon(
          Icons.done_all,
          color:taskList[i].getColor().computeLuminance() > 0.5 ? Colors.black : Colors.white
        );
      case 0:
      default:
        return Icon(Icons.done, color:taskList[i].getColor().computeLuminance() > 0.5 ? Colors.black54 : Colors.white70);
    }
  }

  int selected = 0;
  List<String> buttonNames = ["all", "personal", "work", "shopping", "others"];

  showFilterDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState1) {
            return AlertDialog(
              actions: [
                FlatButton(
                  child: Text("close"),
                  onPressed: () {
                    Navigator.of(context).pop(selected);
                  },
                )
              ],
              contentPadding: EdgeInsets.all(20),
              title: Text("Filter"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    value: selected == 0,
                    groupValue: true,
                    onChanged: (c) {
                      setState1(() {
                        if (!c) selected = 0;
                      });
                    },
                    title: Text(buttonNames[0]),
                  ),
                  RadioListTile(
                    value: selected == 1,
                    groupValue: true,
                    onChanged: (c) {
                      setState1(() {
                        if (!c) selected = 1;
                      });
                    },
                    title: Text(buttonNames[1]),
                  ),
                  RadioListTile(
                    value: selected == 2,
                    groupValue: true,
                    onChanged: (c) {
                      setState1(() {
                        if (!c) selected = 2;
                      });
                    },
                    title: Text(buttonNames[2]),
                  ),
                  RadioListTile(
                    value: selected == 3,
                    groupValue: true,
                    onChanged: (c) {
                      setState1(() {
                        if (!c) selected = 3;
                      });
                    },
                    title: Text(buttonNames[3]),
                  ),
                ],
              ),
            );
          });
        }).then((value) {
      print("changed");
      if (selected != 0)
        getIt<TaskManager>().search2(buttonNames[value]);
      else
        getIt<TaskManager>().search2("");
    });
  }

  showLoadingDialog(context) {
    print("show dialog");
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Dialog(child: LoaderDialog()),
          );
        });
  }

  _inProgressList(List<Task> taskList) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, i) {
        return LimitedBox(
          maxWidth: 250,
          maxHeight: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: taskList[i].getColor(),
              child: Stack(
                fit: StackFit.loose,
                children: [
                  Positioned(
                      left: 10,
                      top: 10,
                      right: 20,
                      child:
                          Text("${taskList[i].task}\n${taskList[i].labels}",style:TextStyle(color:taskList[i].getColor().computeLuminance() > 0.5 ? Colors.black : Colors.white))),
                  Positioned(
                      left: 10,
                      bottom: 10,
                      right: 0,
                      child: Text(
                          "${dateFormatter.format(DateTime.fromMillisecondsSinceEpoch(taskList[i].dueDateTimeStamp))}",
                          style: TextStyle(color:taskList[i].getColor().computeLuminance() > 0.5 ? Colors.black54 : Colors.white70)))
                ],
              ),
            ),
          ),
        );
      },
      itemCount: taskList.length,
    );
  }

  double navBarHeight = 70;

  getNavBar() {
    return Container(
      color: Colors.black.withAlpha(110),
      height: navBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: getLogo(context),
            fit: FlexFit.tight,
          ),
          Flexible(
            flex:2,
            child: Card(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: TextField(
                onChanged: (v) {
                  getIt<TaskManager>().search(v);
                },
                decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none),
              ),
            ),
            fit: FlexFit.tight,
          ),
          Spacer(),
          Flexible(
              fit: FlexFit.tight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FlatButton(
                    child: Row(
                      children: [
                        Icon(Icons.add_circle),
                        MediaQuery.of(context).size.width < 750
                            ? SizedBox.shrink()
                            : Text(
                                "  Add Task",
                                style: TextStyle(fontSize: 18),
                              ),
                      ],
                    ),
                    onPressed: () {
                      showAddDialog(context);
                    },
                  ),
                ],
              )),
          Flexible(
              fit: FlexFit.tight,
              child: FlatButton(
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app),
                    MediaQuery.of(context).size.width < 750
                        ? SizedBox.shrink()
                        : Text(
                            "Logout",
                            style: TextStyle(fontSize: 18),
                          ),
                    Spacer(flex: 1),
                  ],
                ),
                onPressed: () {
                  AuthService().logoutCurrentUser();
                },
              ))
        ],
      ),
    );
  }

  String label, dueDate;

  showErrorDialog(context, string) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              FlatButton(
                child: Text("close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            contentPadding: EdgeInsets.all(20),
            title: Text("Error"),
            content: Text("$string"),
          );
        });
  }

  showAddDialog(context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: NewTaskDialog(
                onFailedValidation: () {
                  print("failed validation");
                },
                onSubmit: (context, Task task) async {
                  //use dio add task.
                  Map result = await getIt<TaskManager>().addTask(task);
                  if (result["error"]) {
                    showErrorDialog(context, result["message"]);
                    return false;
                  } else {
                    print("success");
                    return true;
                  }
                },
              ));
        });
  }
}
