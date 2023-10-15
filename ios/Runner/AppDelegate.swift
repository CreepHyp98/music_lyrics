import UIKit
import Flutter
import MediaPlayer

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // ーーーーー追加ーーーーー
    do {
        if #available(iOS 10.0, *){
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
    } catch {
        print(error)
    }

    //// MPRemoteCommandCenterのインスタンスを取得
    //let commandCenter = MPRemoteCommandCenter.shared()
//
    //// リモートコントロールイベントのハンドラを設定
    //commandCenter.playCommand.addTarget { [unowned self] event in
    //    if canPlayMedia() {
    //        // メディア再生のためのカスタムロジック
    //        return .success
    //    }
    //    return .commandFailed
    //}
//
    //commandCenter.pauseCommand.addTarget { [unowned self] event in
    //    if canPauseMedia() {
    //        // メディア一時停止のためのカスタムロジック
    //        return .success
    //    }
    //    return .commandFailed
    //}
//
    //// 他のリモートコントロールイベントのハンドラを設定
    //return true
    // ーーーーーーーーーー

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
