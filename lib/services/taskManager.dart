import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:tasks/helpers/task.dart';

import 'TokenInterceptor.dart';

class TaskManagerNotifier with ChangeNotifier {
  List<Task> taskList;
  bool isDisposed = false;

  TaskManagerNotifier() {
    taskList = [];
  }

  setList(tasklist) {
    this.taskList = taskList;
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    isDisposed = true;
  }

  notify() {
    notifyListeners();
  }
}

class TaskManager {
  String baseUrl = "https://stackhacktaskapi.herokuapp.com";
  Dio dio;

  List<Task> taskList;
  StreamController<bool> taskStream;

  dispose() {
    taskStream.close();
  }

  getStream() {
    getAllTasks();
    return taskStream.stream;
  }

  notifyListeners() {
    getCompletedTasks();
    taskStream.sink.add(true);
  }
  // TaskManagerNotifier notifier;

  // getNotifier()
  // {
  //   if(notifier ==null || notifier.isDisposed) {notifier = TaskManagerNotifier();notifier.taskList = taskList;}
  //   return notifier;
  // }

  // notifyListeners()
  // {
  //   notifier.setList(taskList);
  // }

  List<Task> temp,tempC;
  search(String v) {
    if (temp == null) {
      temp = taskList;
      tempC = completedList;
    }
    if (v == "") {
      taskList = temp;
      completedList = tempC;
      notifyListeners();
      return;
    }
    List<Task> temp2 = temp;
    List<Task> temp2c = tempC;
    taskList = [];
    completedList = [];
    for (Task task in temp2) {
      if (task.task.contains(v) || task.status.contains(v)) taskList.add(task);
    }
    for (Task task in temp2c) {
      if (task.task.contains(v) || task.status.contains(v)) completedList.add(task);
    }
    notifyListeners();
  }

  List<Task> temp2,temp2c;
  search2(String v) {
    if (temp2 == null) {
      temp2 = taskList;
      temp2c = completedList;
    }
    if (v == "") {
      taskList = temp2;
      completedList = temp2c;
      notifyListeners();
      return;
    }
    List<Task> temp3 = temp2;
    List<Task> temp3c = temp2c;
    taskList = [];
    completedList = [];
    for (Task task in temp3) {
      if (task.labels.contains(v)) taskList.add(task);
    }
        for (Task task in temp3c) {
      if (task.labels.contains(v)) completedList.add(task);
    }
    notifyListeners();
  }

  sort({bool asc = true}) {}

  getTasksInProgressSortedByTimeStamp() {}

  bool showCompletedTasks = true;

  Future<Map> deleteAt(int i,{bool fromCompletedList:false}) async {
    initDio();
    try {
      var response = await dio.delete("/task/${(!fromCompletedList)?taskList[i].id:completedList[i].id}",
          options: Options(
            validateStatus: (status) => true,
          ));
      if (response.statusCode == 200) {
        (fromCompletedList)?completedList.removeAt(i):taskList.removeAt(i);
        notifyListeners();
        return {"error": false, "message": "success"};
      } else {
        return {"error": true, "message": "${response.data}"};
      }
    } catch (e) {
      print("${e.toString()}");
      return {"error": true, "message": "${e.toString()}"};
    }
  }

  List<Task> getTasksInProgress() {
    List<Task> inProgress = [];
    for (Task t in taskList) {
      if (t.status == "in-progress") inProgress.add(t);
    }
    return inProgress;
  }

  List<Task> completedList = [];
  List<Task> getCompletedTasks() {
    for (Task t in taskList) {
      if (t.status == "completed") {
        completedList.add(t);
        
      }
    }
    for(Task t in completedList)
    {
      taskList.remove(t);
    }
    return completedList;
  }

  Future<Map> updateAt(int i) async {
    initDio();
    try {
      var response = await dio.patch("/task/${taskList[i].id}",
          options: Options(
            validateStatus: (status) => true,
          ),
          data: taskList[i].updateStatus());
      if (response.statusCode == 200) {
        taskList[i].status = taskList[i].getUpdateStatus();
        notifyListeners();
        return {"error": false, "message": "success"};
      } else {
        return {"error": true, "message": "${response.data}"};
      }
    } catch (e) {
      print("${e.toString()}");
      return {"error": true, "message": "${e.toString()}"};
    }
  }

  Future<Map> getAllTasks() async {
    print("ran");
    initDio();
    try {
      var response = await dio.get(
        "/task?date=asc",
        options: Options(
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 404) {
        try {
          var decodedJson;
          if ((response.data as Map).containsKey("task"))
            decodedJson = response.data["task"];
          else
            decodedJson = response.data["tasks"];
          taskList = [];
          for (int i = 0; i < decodedJson.length; i++) {
            taskList.add(Task.fromJson(decodedJson[i]));
          }
          completedList=[];
          notifyListeners();
          print({"error": false, "message": taskList});
          return {"error": false, "message": taskList};
        } catch (e) {
          print({
            "error": true,
            "errormessage": "${e.toString()}",
            "message": "${response.data}"
          });
          return {"error": true, "message": "${response.data}"};
        }
      } else {
        print({
          "error": true,
          "message": "${response.data} ${response.statusCode}"
        });
        return {"error": true, "message": "${response.data}"};
      }
    } catch (e) {
      print("${e.toString()}");
      return {"error": true, "data": "${e.toString()}"};
    }
  }

  Future<dynamic> addTask(Task task) async {
    initDio();
    try {
      var response = await dio.post("/task",
          options: Options(
            validateStatus: (status) => true,
          ),
          data: task.getTask());
      if (response.statusCode == 200) {
        task.id =
            response.data["_id"]; //TODO: add _id return on backend add task
        taskList.add(task);
        notifyListeners();
        return {"error": false, "message": "success"};
      } else {
        return {"error": true, "message": "${response.data}"};
      }
    } catch (e) {
      print("${e.toString()}");
      return {"error": true, "message": "${e.toString()}"};
    }
  }

  TaskManager() {
    initDio();
    taskList = [];
    taskStream = StreamController<bool>.broadcast();
  }

  initDio() {
    if (dio == null) {
      dio = Dio()..options.baseUrl = baseUrl;
      dio.interceptors.add(TokenInterceptor(dio: dio));
    }
  }
}
