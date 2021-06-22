import 'package:flutter/material.dart';
import 'Connector.dart' as connector;
import 'package:flutterchat/AppDrawer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'Model.dart' show FlutterChatModel, model;

class CreateRoom extends StatefulWidget {
  const CreateRoom({Key? key}) : super(key: key);

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  late String _title;
  late String _description;
  bool _private = false;
  double _maxPeople = 25;

  // finding the form key
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(final BuildContext inContext) {
    return ScopedModel(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (BuildContext inContext, Widget inWidget,
            FlutterChatModel inModel) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text("Create Room"),
            ),
            /** End of AppBar */
            drawer: AppDrawer(),
            /** End of Drawer */
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 10,
              ),
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        /** Hide the keyboard and pop the screen away */
                        FocusScope.of(inContext).requestFocus(FocusNode());
                        Navigator.of(inContext).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    Spacer(),
                    TextButton(
                      child: Text("Save"),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        _formKey.currentState!.save();
                        /** Truncate value of max people to get an integer value */
                        int maxPeople = _maxPeople.truncate();
                        connector.create(
                          _title,
                          _description,
                          maxPeople,
                          _private,
                          model.userName,
                          (inStatus, inRoomList) {
                            if (inStatus == "created") {
                              model.setRoomList(inRoomList);
                              FocusScope.of(inContext)
                                  .requestFocus(FocusNode());
                              Navigator.of(inContext).pop();
                            } else {
                              ScaffoldMessenger.of(inContext).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                  content:
                                      Text("Sorry, that room already exists"),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            /** End of the BottomNavBar */
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Name"),
                      validator: (String? inValue) {
                        if (inValue!.length == 0 || inValue.length > 14) {
                          return "Please enter a name no more"
                              "than 14 characters long";
                        }
                        return null;
                      },
                      onSaved: (String? inValue) {
                        setState(() {
                          _title = inValue.toString();
                        });
                      },
                    ),
                  ),
                  /** End of Name listTile */
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Description"),
                      onSaved: (String? inValue) {
                        setState(() {
                          _description = inValue.toString();
                        });
                      },
                    ),
                  ),
                  /**End of description listTile */
                  ListTile(
                    title: Row(
                      children: [
                        Text("Max\nPeople"),
                        Slider(
                          min: 0,
                          max: 99,
                          value: _maxPeople,
                          onChanged: (double inValue) {
                            setState(() {
                              _maxPeople = inValue;
                            });
                          },
                        )
                      ],
                    ),
                    trailing: Text(_maxPeople.toStringAsFixed(0)),
                  ),
                  /** End of Mac People Field slider widget */
                  ListTile(
                    title: Row(
                      children: [
                        Text("Private"),
                        Switch(
                          value: _private,
                          onChanged: (inValue) {
                            setState(() {
                              _private = inValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ), /** End of the Private/Public room switch */
                ],
              ),
            ), /** End of Body */
          );
        },
      ),
    );
  }
}
