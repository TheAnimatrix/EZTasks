import 'dart:ui';

import 'package:random_color/random_color.dart';

class Task {
  String labels, task, status, id;
  int dueDateTimeStamp;
  Color randomColor;

  getColor()
  {
    if(randomColor == null) {
      RandomColor _randomColor = RandomColor();
      randomColor = _randomColor.randomColor(
                                colorBrightness: ColorBrightness.dark);
    }

    return randomColor;
  }

  Task(
      {this.labels,
      this.task,
      this.dueDateTimeStamp,
      this.status,
      this.id = ""});

  String getTask() {
    return "{\"task\":\"$task\",\"status\":\"$status\",\"dueDate\":\"$dueDateTimeStamp\",\"label\":\"$labels\"}";
  }

  List<String> _statuses= ["new","in-progress","completed"];
  String updateStatus() {
    int currentStatusIndex = 0;
    for(String s in _statuses)
    {
      if(s==status)break;
      if(currentStatusIndex<=1)currentStatusIndex++;
    }
    return "{\"status\":\"${_statuses[currentStatusIndex+1]}\"}";
  }

  String getUpdateStatus() {
    int currentStatusIndex = 0;
    for(String s in _statuses)
    {
      if(s==status)break;
      if(currentStatusIndex<=1)currentStatusIndex++;
    }
    return "${_statuses[currentStatusIndex+1]}";
  }

    int getUpdateStatusIndex() {
    int currentStatusIndex = 0;
    for(String s in _statuses)
    {
      if(s==status)break;
      if(currentStatusIndex<=1)currentStatusIndex++;
    }
    return currentStatusIndex;
  }

  Task.fromJson(Map<String, dynamic> json)
      : labels = json["label"],
        task = json["task"],
        dueDateTimeStamp = json["dueDate"],
        status = json["status"],
        id = json["_id"];
}
