import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

/// Model of the FlutterChat App
class FlutterChatModel extends Model {
  // build context of the root widget of the app
  // required in multiple places
  late BuildContext rootBuildContext;

  // The apps documents directory
  late Directory docsDir;

  // greeting text to be shown on the homescreen
  String greeting = "";

  // Username
  String userName = "";

  // Text to be shown when a user isn't in a room
  static final String DEFAULT_ROOM_NAME = "Not currently in a room";

  // name of the room the user is currently in | the default if they ain't in one
  String currentRoomName = DEFAULT_ROOM_NAME;

  // The list of users in the room the user is currently in
  List currentRoomUserList = [];

  // Whether the current room item has been enabled (if user is in room)
  bool currentRoomEnabled = false;

  // the list of messages in the room the user is currently in
  List currentRoomMessages = [];

  // current list of rooms on the server
  List roomList = [];

  // current list of users on the server
  List userList = [];

  // Whether admin/creator functions are enabled or not
  bool creatorFunctionsEnabled = false;

  // List of invites the user has received
  Map roomInvites = {};

  // Property setters

  // greeting setter
  void setGreeting(final String inGreeting) {
    greeting = inGreeting;
    notifyListeners();
  }

  // username setter
  void setUsername(final String inUserName) {
    userName = inUserName;
    notifyListeners();
  }

  // current room setter
  void setCurrentRoomName(final String inCurrentRoomName) {
    currentRoomName = inCurrentRoomName;
    notifyListeners();
  }

  // creator functions enabled setter
  void setCreatorFunctionsEnabled(final bool inCreatorFunctionsEnabled) {
    creatorFunctionsEnabled = inCreatorFunctionsEnabled;
    notifyListeners();
  }

  // current room enabled setter
  void setCurrentroomEnabled(final bool inCurrentRoomEnabled) {
    currentRoomEnabled = inCurrentRoomEnabled;
    notifyListeners();
  }

  /// Called when the server informs the client of a new message posted to a room
  void addMessage(final String inUserName, final String inMessage) {
    currentRoomMessages.add({"username": inUserName, "message": inMessage});
    notifyListeners();
  }

  /// Set the list of rooms currently on the server
  void setRoomList(final Map inRoomList) {
    List rooms = [];
    for (String roomName in inRoomList.keys) {
      Map room = inRoomList[roomName];
      rooms.add(room);
    }
    roomList = rooms;
    notifyListeners();
  }

  /// set the list of users currently on the server
  void setUserList(final Map inUserList) {
    List users = [];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }
    userList = users;
    notifyListeners();
  }

  /// set the list of users currently in the room the users is currently in
  void setCurrentRoomUserList(final Map inCurrentRoomUserList) {
    List users = [];
    for (String userName in inCurrentRoomUserList.keys) {
      Map userInRoom = inCurrentRoomUserList[userName];
      users.add(userInRoom);
    }
    currentRoomUserList = users;
    notifyListeners();
  }

  /// Notify the client of a new invite
  void addRoomInvite(final String inRoomName) {
    roomInvites[inRoomName] = true;
  }

  /// Remove an invite when the room is closed
  void removeRoomInvite(final String inRoomName) {
    roomInvites.remove(inRoomName);
  }

  /// clear list of messages in a room when a user leaves the room
  void clearCurrentRoomMessages() {
    currentRoomMessages = [];
  }
}

// create the one and only instance of the Model
FlutterChatModel model = FlutterChatModel();
