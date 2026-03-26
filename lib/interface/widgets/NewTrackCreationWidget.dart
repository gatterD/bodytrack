import 'package:bodytrack/interface/screens/AppBar.dart';
import 'package:flutter/material.dart';

import '../screens/NewTrackCreation.dart';

class NewTrackCreationState extends State<NewTrackCreation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BTAppBar(
        title: "New track",
        actions: [],
        showBackButton: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              textAlign: TextAlign.center,
              maxLength: 50,
              decoration: InputDecoration(label: Text("Name of track")),
            ),
          ),
        ],
      ),
    );
  }
}
