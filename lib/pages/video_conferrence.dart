import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class VideoConfireabce extends StatelessWidget {
  const VideoConfireabce({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
          color: Colors.red,
          width: 2000,
          height: 15000,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                color: Colors.white54,
                child: JitsiMeetConferencing(
                  extraJS: [
                    // extraJs setup example
                    '<script>function echo(){console.log("echo!!!")};</script>',
                    '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                  ],
                )),
          ))
    );
  }
}
