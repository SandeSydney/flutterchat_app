import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:path/path.dart';
import 'package:flutterchat/Model.dart';
import 'package:path_provider/path_provider.dart';
import 'LoginDialog.dart';
import 'Home.dart';
import 'Lobby.dart';
import 'CreateRoom.dart';
import 'UserList.dart';
import 'Room.dart';

void main() {
  // method that will allow some asynchronous work before program running
  startMeUp() async {
    /** Get the apps document directory */
    Directory docsDir = await getApplicationDocumentsDirectory();
    model.docsDir = docsDir;

    /** File to store user credentials: userName and password */
    var credentialsFile = File(join(model.docsDir.path, "credentials"));
    var exists = await credentialsFile.exists();

    /** Read from the credentials file if it does exist */
    var credentials;
    if (exists) {
      credentials = await credentialsFile.readAsString();
    }

    /** Build the UI */
    runApp(FlutterChat());

    /** Validate the user to the server if there is a credentials file>
     * If no such file, show user the login dialog
    */
    if (exists) {
      List credParts = credentials.split("============");
      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);
    } else {
      await showDialog(
          context: model.rootBuildContext,
          barrierDismissible: false,
          builder: (BuildContext inDialogContext) {
            return LoginDialog();
          });
    }
  }

  /** Where execution actually begins */
  startMeUp();
}

class FlutterChat extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FlutterChatMain(),
      ),
    );
  }
}

/// FlutterChatMain: the main class of FlutterChat app
class FlutterChatMain extends StatelessWidget {
  @override
  Widget build(final BuildContext inContext) {
    model.rootBuildContext = inContext;

    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder:
            (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
          return MaterialApp(
            initialRoute: "/",
            routes: {
              /** Room List */
              "/Lobby": (screenContext) => Lobby(),
              /** Inside a room */
              "/Room": (screenContext) => Room(),
              /** List users on server */
              "/UserList": (screenContext) => UserList(),
              /** Creating a room */
              "/CreateRoom": (screenContext) => CreateRoom(),
            },
            home: Home(),
          );
        },
      ),
    );
  }
}
