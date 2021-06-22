import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'Model.dart' show FlutterChatModel, model;
import 'package:scoped_model/scoped_model.dart';
import 'Connector.dart' as connector;

/// LoginDialog class offers a login dialog pop up requiring user credentials
/// for the registration and validation by the server

class LoginDialog extends StatelessWidget {
  // getting a unique form key for validation of form input
  static final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();

  late final String _userName;
  late final String _password;

  @override
  Widget build(final BuildContext inContext) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(builder:
          (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
        return AlertDialog(
          content: Container(
            height: 220,
            child: Form(
              key: _loginFormKey,
              child: Column(
                children: <Widget>[
                  Text(
                    "Enter username and password"
                    " to register with the server",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(model.rootBuildContext).accentColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (String? inValue) {
                      if (inValue!.length == 0 || inValue.length > 10) {
                        return "Please enter a username no"
                            "more than 10 characters long";
                      }
                      return null;
                    },
                    onSaved: (String? inValue) {
                      _userName = inValue.toString();
                    },
                    decoration: InputDecoration(
                      hintText: "Username",
                      labelText: "Username",
                    ),
                  ),
                  TextFormField(
                    obscureText: true,
                    validator: (String? inValue) {
                      if (inValue!.length == 0) {
                        return "Please enter a password";
                      }
                      return null;
                    },
                    onSaved: (String? inValue) {
                      _password = inValue.toString();
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      labelText: "Password",
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Log In"),
              onPressed: () {
                if (_loginFormKey.currentState!.validate()) {
                  _loginFormKey.currentState!.save();

                  connector.connectToServer(model.rootBuildContext, () {
                    connector.validate(_userName, _password, (inStatus) async {
                      if (inStatus == "ok") {
                        model.setUsername(_userName);
                        Navigator.of(model.rootBuildContext).pop();
                        model.setGreeting("Welcome back, $_userName!");
                      } else if (inStatus == "fail") {
                        ScaffoldMessenger.of(model.rootBuildContext)
                            .showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content:
                              Text("Sorry, that username is already taken"),
                        ));
                      } else if (inStatus == "created") {
                        var credentialsFile =
                            File(join(model.docsDir.path, "credentials"));
                        await credentialsFile
                            .writeAsString("$_userName============$_password");
                        model.setUsername(_userName);
                        Navigator.of(model.rootBuildContext).pop();
                        model.setGreeting("Welcome to the server, $_userName!");
                      }
                    });
                  });
                }
              },
            )
          ],
        );
      }),
    );
  }

  /// procedure to be followed when the app starts and finds existing credentials.
  /// The server is consulted using this method
  void validateWithStoredCredentials(
      final String inUserName, final String inPassword) {
    connector.connectToServer(model.rootBuildContext, () {
      connector.validate(inUserName, inPassword, (inStatus) {
        if (inStatus == "ok" || inStatus == "created") {
          model.setUsername(inUserName);
          model.setGreeting("Welcome back, $inUserName!");
        } else if (inStatus == "fail") {
          showDialog(
            context: model.rootBuildContext,
            barrierDismissible: false,
            builder: (final BuildContext inDialogContext) => AlertDialog(
              title: Text("Validation Failed!"),
              content: Text(
                "It appears that the server has "
                "restarted and the lastname you last used "
                "was subsequently taken by someone else. "
                "\n\nPlease re-start FlutterChat and choose "
                "a different username.",
              ),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    var credentialsFile =
                        File(join(model.docsDir.path, "credentials"));
                    /**Since we now know that this username can’t be used, we need
                   * to delete the credentials file to avoid a loop at the next app 
                   * startup. */
                    credentialsFile.deleteSync();
                    exit(0);
                  },
                )
              ],
            ),
          );
        }
      });
    });
  }
}
