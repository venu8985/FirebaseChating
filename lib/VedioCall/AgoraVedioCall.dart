import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "4a9cb4cd52184e76bbe739983fa0b7d0";
const token =
    "007eJxTYBD1PuoT+fvJ5opVt4p1N3FNX5untfbLNFWpSx3fNyufeHZWgcEk0TI5ySQ5xdTI0MIk1dwsKSnV3NjS0sI4LdEgyTzF4H/p09SGQEYGjUwnJkYGCATxWRjKUvNKGRgA+wQh3g==";
const channel = "venu";
const appCertificate = "YOUR_APP_CERTIFICATE";

class VedioCall extends StatefulWidget {
  const VedioCall({Key? key}) : super(key: key);

  @override
  State<VedioCall> createState() => _VedioCallState();
}

class _VedioCallState extends State<VedioCall> {
  int? _remoteUid;
  bool _localUserJoined = false;
  RtcEngine? _engine;

  late String _channelName;
  late String _token;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();

    await _engine?.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine?.enableVideo();
    await _engine?.startPreview();

    await _engine?.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _dispose();
  }

  Future<void> _dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Center(
        child: Text('Channel Name: $_channelName'),
      ),
      // Stack(
      //   children: [
      //     Center(
      //       child: _remoteVideo(),
      //     ),
      //     Align(
      //       alignment: Alignment.topLeft,
      //       child: SizedBox(
      //         width: 100,
      //         height: 150,
      //         child: Center(
      //           child: _localUserJoined
      //               ? AgoraVideoView(
      //                   controller: VideoViewController(
      //                     rtcEngine: _engine!,
      //                     canvas: const VideoCanvas(uid: 0),
      //                   ),
      //                 )
      //               : const CircularProgressIndicator(),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
