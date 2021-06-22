import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:flutterchat/Model.dart';

/// This offers a single module for the communication with the server and that
/// the rest of the app uses

// The Server URL
String serverURL = "http://192.168.9.42";

// Instance of the Socket.io class
late SocketIO _io;

// ----------------------Non-Message Related methods---------------------

/// Show a "Please Wait" Mask over the screen to let users know there is
/// background communication. They should not interfere with it
void showPleaseWait() {
  showDialog(
      context: model.rootBuildContext,
      barrierDismissible: false,
      builder: (BuildContext inDialogContext) {
        return Dialog(
          child: Container(
            width: 150,
            height: 150,
            alignment: AlignmentDirectional.center,
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      value: null,
                      strokeWidth: 10,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                      child: Text(
                    "Please wait, contacting server",
                    style: new TextStyle(color: Colors.white),
                  )),
                ),
              ],
            ),
          ),
        );
      }); // End the show dialog
} // End of the showPleaseWait()

/// Hiding the Please Wait dialog
void hidePleaseWait() {
  Navigator.of(model.rootBuildContext).pop();
} // end of the hidePleaseWait()

/// connectToServer function: called from the login dialog after user enters
/// credentials
void connectToServer(
    final BuildContext inMainBuildContext, final Function inCallback) {
  _io = SocketIOManager().createSocketIO(serverURL, "/", query: "",
      socketStatusCallback: (inData) {
    if (inData == "connect") {
      _io.subscribe("newUser", newUser);
      _io.subscribe("created", created);
      _io.subscribe("closed", closed);
      _io.subscribe("joined", joined);
      _io.subscribe("left", left);
      _io.subscribe("kicked", kicked);
      _io.subscribe("invited", invited);
      _io.subscribe("posted", posted);
      inCallback();
    }
  });

  // THIS IS ONLY FOR DEVELOPMENT SO THAT WE GET A FRESH SOCKET AFTER A HOT RELOAD (THE ABOVE CALLBACK WILL NOT HAVE EXECUTED BECAUSE A SOCKET ALREADY EXISTS, BUT WE NEED IT TO, SO THIS EFFECTIVELY FORCES IT)
  _io.destroy();
  _io = SocketIOManager().createSocketIO(serverURL, "/", query: "",
      socketStatusCallback: (inData) {
    print("## Connector.connectToServer(): callback: inData = $inData");
    if (inData == "connect") {
      print("## Connector.connectToServer(): callback: Connected to server");
      inCallback();
    }
  });

  _io.init();
  _io.connect();
}

// ------------------- Server-Bound Message Functions ------------------

// ----- Functions Emmiting messages to server -----------

/// validate() : validates user's input
void validate(final String inUserName, final String inPassword,
    final Function inCallback) {
  // block screen while we wait for the server
  showPleaseWait();
  _io.sendMessage("validate",
      "{\"userName\" : \"$inUserName\", \"password\" : \"$inPassword\"}",
      (inData) {
    Map<String, dynamic> response = jsonDecode(inData);
    hidePleaseWait();
    inCallback(response["status"]);
  });
}

/// listRooms(): lists the rooms that are in the server
void listRooms(final Function inCallback) {
  showPleaseWait();
  _io.sendMessage("listRooms", "{}", (inData) {
    Map<String, dynamic> response = jsonDecode(inData);
    hidePleaseWait();
    inCallback(response);
  });
}

/// Create() lets the user create a room
void create(
    final String inRoomName,
    final String inDescription,
    final int inMaxPeople,
    final bool inPrivate,
    final String inCreator,
    final Function inCallback) {
  showPleaseWait();
  _io.sendMessage("create",
      "{\"roomName\":\"$inRoomName\", \"description\":\"$inDescription\", \"maxPeople\":\"$inMaxPeople\", \"private\":\"$inPrivate\", \"creator\":\"$inCreator\"}",
      (inData) {
    // pass response json string into a map
    Map<String, dynamic> response = jsonDecode(inData);

    // hide the pleaseWait()
    hidePleaseWait();

    // call the specified callback, passing it the response
    inCallback(response["status"], response["rooms"]);
  });
} /** End create() */

/// Join() : to join a room
void join(final String inUserName, final String inRoomName,
    final Function inCallback) {
  /** Block screen as we call server */
  showPleaseWait();

  _io.sendMessage(
      "join", "{\"userName\":\"$inUserName\", \"roomName\":\"$inRoomName\"}",
      (inData) {
    // pass response json string into a map
    Map<String, dynamic> response = jsonDecode(inData);

    // hide the pleaseWait()
    hidePleaseWait();

    // call specified callback, passing it the response
    inCallback(response["status"], response["room"]);
  });
} /** End the join() */

/// Function for a user to leave a room
void leave(final String inUserName, final String inRoomName,
    final Function inCallback) {
  /** Block screen as we call server */
  showPleaseWait();

  _io.sendMessage(
      "leave", "{\"userName\":\"$inUserName\", \"roomName\", \"$inRoomName\"}",
      (inData) {
    /** pass response json string into map */
    Map<String, dynamic> response = jsonDecode(inData);

    /** Unblock screen */
    hidePleaseWait();

    /** call specific callback with a response */
    inCallback();
  });
} /** End the leave() */

/// listUsers() called to get the updated list of users on the server
void listUsers(final Function inCallback) {
  /** Block screen while server is called */
  showPleaseWait();

  _io.sendMessage("listUsers", "{}", (inData) {
    /** response json string passed into map */
    Map<String, dynamic> response = jsonDecode(inData);

    /** Unblock screen */
    hidePleaseWait();

    /** call respective callback passing the response */
    inCallback(response);
  });
} /** End listUsers() */

/// invite() : called when a user invites another user to a room
void invite(final String inUserName, final String inRoomName,
    final String inInviterName, final Function inCallback) {
  /** Block screen as we load server */
  showPleaseWait();

  _io.sendMessage("invite",
      "{\"userName\":\"$inUserName\", \"roomName\":\"$inRoomName\", \"inviterName\":\"$inInviterName\"}",
      (inData) {
    /** pass json string to map */
    Map<String, dynamic> response = jsonDecode(inData);

    /** display screen */
    hidePleaseWait();

    /** call specific callback passing response */
    inCallback();
  });
} /** End the invite() */

/// post() : called for the purpose of posting a message to the current room
void post(final String inUserName, final String inRoomName,
    final String inMessage, final Function inCallback) {
  /** block screen while loading server */
  showPleaseWait();

  _io.sendMessage("post",
      "{\"userName\":\"$inUserName\", \"roomName\":\"$inRoomName\", \"message\":\"$inMessage\"}",
      (inData) {
    /** pass json string to map */
    Map<String, dynamic> response = jsonDecode(inData);

    /** unblock screen */
    hidePleaseWait();

    /** call specific callback passing it response */
    inCallback(response["status"]);
  });
} /** End post() */

/// close() : called by creator to close a room
void close(final String inRoomName, final Function inCallback) {
  /** block screen while loading server */
  showPleaseWait();

  _io.sendMessage("close", "{\"roomName\":\"$inRoomName\"}", (inData) {
    /** pass json message string to map */
    Map<String, dynamic> response = jsonDecode(inData);

    /** Unblock the screen */
    hidePleaseWait();

    /** call necessarry callback passing in the response */
    inCallback();
  });
} /** End close() */

/// kick() : kick the user out of a room
void kick(final String inUserName, final String inRoomName,
    final Function inCallback) {
  /** block screen while loading server */
  showPleaseWait();

  _io.sendMessage(
      "kick", "{\"userName\":\"$inUserName\", \"roomName\":\"$inRoomName\"}",
      (inData) {
    /** pass json string message to map */
    Map<String, dynamic> response = jsonDecode(inData);

    /** Unblock the screen */
    hidePleaseWait();

    /** call specific callback and pass it the response */
    inCallback();
  });
} /** end of kick() */

// ------------------ Client-Bound Handlers -------------------

///  emits message from server with a complete list of users, setting it in the model
void newUser(inData) {
  Map<String, dynamic> payload = jsonDecode(inData);
  model.setUserList(payload);
}

/// creates a new room
void created(inData) {
  Map<String, dynamic> payload = jsonDecode(inData);
  model.setRoomList(payload);
}

/// closes a room
void closed(inData) {
  // update the list of rooms in the model
  Map<String, dynamic> payload = jsonDecode(inData);
  model.setRoomList(payload);

  // if room closed is one user is currently in
  if (payload["roomName"] == model.currentRoomName) {
    // remove model properties and set them to default
    model.removeRoomInvite(payload["roomName"]);
    model.setCurrentRoomUserList({});
    model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
    model.setCurrentroomEnabled(false);
    model.setGreeting("The room you were in was closed by its creator.");
    // go to the home screen
    Navigator.of(model.rootBuildContext)
        .pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
  }
}

/// user other than the current user joins the room, joined message emitted
void joined(inData) {
  Map<String, dynamic> payload = jsonDecode(inData);
  if (model.currentRoomName == payload["roomName"]) {
    model.setCurrentRoomUserList(payload["users"]);
  }
}

/// user other than the current user leaves the room, left message emitted
void left(inData) {
  Map<String, dynamic> payload = jsonDecode(inData);
  if (model.currentRoomName == payload["room"]["roomName"]) {
    model.setCurrentRoomUserList(payload["room"]["users"]);
  }
}

/// user kicked out of the room
void kicked(inData) {
  Map<String, dynamic> payload = jsonDecode(inData);

  // clear model attributes that reflect user in the room
  model.removeRoomInvite(payload["roomName"]);
  model.setCurrentRoomUserList({});
  model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
  model.setCurrentroomEnabled(false);

  // inform the user of the kick out
  model.setGreeting("What did you do?! You got kicked from the room! D'oh!");

  // route back to the homescreen
  Navigator.of(model.rootBuildContext)
      .pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
}

/// new user is invited to a room
void invited(inData) async {
  Map<String, dynamic> payload = jsonDecode(inData);

  String roomName = payload["roomName"];
  String inviterName = payload["inviterName"];
  model.addRoomInvite(roomName);
  ScaffoldMessenger.of(model.rootBuildContext).showSnackBar(
    SnackBar(
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 60),
      content: Text("You've been invited to the room "
          "'$roomName' by user '$inviterName'.\n\n"
          "You can enter the room from the lobby."),
      action: SnackBarAction(label: "Ok", onPressed: () {}),
    ),
  );
}

/// user makes a post in the room
void posted(inData) {
  Map<String, dynamic> payload = jsonDecode(inData);
  if (model.currentRoomName == payload["roomName"]) {
    model.addMessage(payload["userName"], payload["message"]);
  }
}
