import 'package:flutter/material.dart';

class Player extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Player"),
            Padding(padding: EdgeInsets.all(50)),
            ElevatedButton(
              onPressed: () {},
              child: Icon(Icons.play_arrow),
            )
          ],
        ),
      ),
    );
  }
}
