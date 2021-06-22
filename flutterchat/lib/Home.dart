import 'package:flutter/material.dart';
import 'package:flutterchat/Model.dart' show FlutterChatModel, model;
import 'package:scoped_model/scoped_model.dart';
import 'AppDrawer.dart';

class Home extends StatelessWidget {
  @override
  Widget build(final BuildContext inContext) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder:
            (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
          return Scaffold(
            drawer: AppDrawer(),
            appBar: AppBar(title: Text("FlutterChat")),
            body: Center(child: Text(model.greeting)),
          );
        },
      ),
    );
  }
}
