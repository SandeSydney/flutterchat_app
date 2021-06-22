import 'package:flutter/material.dart';
import 'package:flutterchat/AppDrawer.dart';
import 'package:flutterchat/Model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'Connector.dart' as connector;

/// Lobby shows the rooms that are available on the server
/// Lock icon showed to denote a private or public room
/// Also Room name and description if exists

class Lobby extends StatelessWidget {
  @override
  Widget build(final BuildContext inContext) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder:
            (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
          return Scaffold(
            drawer: AppDrawer(),
            appBar: AppBar(
              title: Text("Lobby"),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(inContext, "/CreateRoom");
              },
            ),
            body: model.roomList.length == 0
                ? Center(
                    child: Text("There are no rooms yet. Why not add one?"),
                  )
                : ListView.builder(
                    itemCount: model.roomList.length,
                    itemBuilder: (BuildContext inBuildContext, int inIndex) {
                      Map room = model.roomList[inIndex];
                      String roomName = room["roomName"];
                      return Column(
                        children: [
                          ListTile(
                            /** Lock icon */
                            leading: room["private"]
                                ? Image.asset("assets/private.png")
                                : Image.asset("assets/public.png"),
                            title: Text(roomName),
                            subtitle: Text(room["description"]),
                            /** Each room can be tapped and opened if conditions are true*/
                            onTap: () {
                              if (room["private"] &&
                                  !model.roomInvites.containsKey(roomName) &&
                                  room["creator"] != model.userName) {
                                ScaffoldMessenger.of(inBuildContext)
                                    .showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                    content: Text("Sorry, you can't "
                                        "enter a private room without any invite"),
                                  ),
                                );
                              } else {
                                /** server notified of user entering a room */
                                connector.join(model.userName, roomName,
                                    (inStatus, inRoomDescriptor) {
                                  if (inStatus == "joined") {
                                    model.setCurrentRoomName(
                                        inRoomDescriptor["roomName"]);
                                    model.setCurrentRoomUserList(
                                        inRoomDescriptor["users"]);
                                    model.setCurrentroomEnabled(true);
                                    model.clearCurrentRoomMessages();

                                    /** Enable creator functions if the joined user is the creator */
                                    if (inRoomDescriptor["creator"] ==
                                        model.userName) {
                                      model.setCreatorFunctionsEnabled(true);
                                    } else {
                                      model.setCreatorFunctionsEnabled(false);
                                    }
                                    Navigator.pushNamed(inContext, "/Room");
                                  } else if (inStatus == "full") {
                                    ScaffoldMessenger.of(inBuildContext)
                                        .showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 2),
                                        content:
                                            Text("Sorry, that room is full"),
                                      ),
                                    );
                                  }
                                });
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
