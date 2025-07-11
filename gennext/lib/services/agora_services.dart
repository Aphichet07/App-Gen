import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  final String appId = "YOUR_APP_ID";
  final String channelName;
  final String token;

  final void Function(int remoteUid)? onUserJoinedCallback;
  final void Function(int remoteUid)? onUserOfflineCallback;

  late final RtcEngine _engine;

  AgoraService({
    required this.channelName,
    required this.token,
    this.onUserJoinedCallback,
    this.onUserOfflineCallback,
  });

  Future<void> initAgora() async {
    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    await _engine.enableAudio();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          onUserJoinedCallback?.call(remoteUid); // เรียก callback
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("Remote user $remoteUid left");
              onUserOfflineCallback?.call(remoteUid); // เรียก callback
            },
      ),
    );

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void dispose() {
    _engine.leaveChannel();
    _engine.release();
  }
}
