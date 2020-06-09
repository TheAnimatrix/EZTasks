import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tasks/helpers/task.dart';

class NewTaskDialog extends StatefulWidget {
  final onSubmit, onFailedValidation;
  NewTaskDialog({this.onSubmit, this.onFailedValidation});

  @override
  _NewTaskDialogState createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  final _formkey = GlobalKey<FormState>();
  String tags, description, finalDate, timestamp;
  DateTime finalDateTime;
  TextEditingController _tagController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Form(
        key: _formkey,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                width: 300,
                              child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    BasicDateTimeField(onchanged: (DateTime val) {
                      print(val.toString());
                      setState(() {
                        this.finalDate = val.toString();
                        this.finalDateTime = val;
                        this.timestamp = val.millisecondsSinceEpoch.toString();
                      });
                      _formkey.currentState.validate();
                      // this.finalDate=val.toString();
                      // this.timestamp = new DateTime(val).millisecondsSinceEpoch.toString();
                    }, validator: (c) {
                      if (finalDate == null || finalDate.isEmpty)
                        return "Cannot be empty";
                      if (finalDateTime != null &&
                          finalDateTime.isBefore(
                              new DateTime.now().add(const Duration(minutes: 5))))
                        return "End date needs to be atleast 5 min in the future";
                      return null;
                      // if(new DateTime(int.parse(timestamp)).isBefore(new DateTime.now())) return "End date must be in the future";
                      // return null;
                    }),
                    SizedBox(height: 12),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Text("Task Details",
                            style: TextStyle(fontWeight: FontWeight.w800))),
                    TextFormField(
                      maxLines: 4,
                      maxLengthEnforced: true,
                      maxLength: 150,
                      decoration: InputDecoration(
                          hintText:
                              "Enter your task description here"),
                      onChanged: (val) {
                        setState(() {
                          this.description = val;
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(decoration: TextDecoration.none),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Label ',
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800)),
                              TextSpan(
                                  text: 'separated by ,(commas)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      decoration: TextDecoration.none,
                                      color: Colors.redAccent)),
                            ],
                          ),
                        )),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _tagController,
                      onChanged: (val) {
                        if (val.startsWith(",")) val = "";
                        if (val.endsWith(",,"))
                          val = val.substring(0, val.length - 1);
                        final _newValue = val;
                        _tagController.value = TextEditingValue(
                          text: _newValue,
                          selection: TextSelection.fromPosition(
                            TextPosition(offset: _newValue.length),
                          ),
                        );
                        setState(() {
                          this.tags = val;
                        });
                      },
                      inputFormatters: [
                        new WhitelistingTextInputFormatter(
                            RegExp("[a-zA-Z0-9,]")),
                      ],
                      validator: (tag) {
                        if (tag.endsWith(","))
                          _tagController.text = tag.substring(0, tag.length - 1);

                        var tags = tag.split(',');
                        if (tags.length > 4) return "Maximum of 4 tags";
                        for (tag in tags)
                          if (tag.length > 15)
                            return "A tag can only have a maximum of 14 characters";

                        return null;
                      },
                    ),
                    SizedBox(height: 40)
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 40,
              child: ButtonTheme(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                  ),
                  minWidth: double.infinity,
                  child: FlatButton(
                    onPressed: () async {
                      if (_formkey.currentState.validate()) {

                        //doSomethingHere;
                        bool shouldClose =  await widget.onSubmit(context,
                            new Task(
                                dueDateTimeStamp: int.parse(timestamp), labels: tags,status: "new",task: description));
                        if (shouldClose) Navigator.of(context).pop();
                      } else {
                         await widget.onFailedValidation(context);
                      }
                    },
                    child:
                        Text("Submit", style: TextStyle(color: Colors.white)),
                    color: Colors.black,
                  )),
            )
          ],
        ),
      ),
    );
  }
}

class BasicDateTimeField extends StatelessWidget {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  final onchanged, validator;
  BasicDateTimeField({this.onchanged, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Align(
          alignment: Alignment.bottomLeft,
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                    text: 'Due Date',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                TextSpan(
                    text: ' (${format.pattern})',
                    style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          )),
      SizedBox(height: 8),
      DateTimeField(
        format: format,
        onChanged: onchanged,
        validator: validator,
        decoration: InputDecoration(hintText: "Click here"),
        onShowPicker: (context, currentValue) async {
          DateTime now = new DateTime.now();
          final date = await showDatePicker(
              context: context,
              firstDate: now,
              initialDate: currentValue != null
                  ? currentValue.isBefore(DateTime.now())
                      ? DateTime.now()
                      : currentValue
                  : DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            DateTime finalValue = DateTimeField.combine(date, time);
            // if (finalValue.isBefore(now))
            //   finalValue = new DateTime.now().add(const Duration(minutes: 0));
            return finalValue;
          } else {
            return currentValue;
          }
        },
      ),
    ]);
  }
}
