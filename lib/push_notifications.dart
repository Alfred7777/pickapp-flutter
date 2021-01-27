import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushNotifications {
  static Future<void> initialize() async {
    var oneSignalAppID = '0b89a425-5d94-4fe2-8efe-ce4a20866fb2';

    // Set received notification handler
    OneSignal.shared.setNotificationReceivedHandler(
      _handleNotificationReceived,
    );

    // Set opened notification handler
    OneSignal.shared.setNotificationOpenedHandler(
      _handleNotificationOpened,
    );

    //Remove this method to stop OneSignal Debugging
    unawaited(
      OneSignal.shared.setLogLevel(
        OSLogLevel.verbose,
        OSLogLevel.none,
      ),
    );

    unawaited(
      OneSignal.shared.init(
        oneSignalAppID,
        iOSSettings: {
          OSiOSSettings.autoPrompt: false,
          OSiOSSettings.inAppLaunchUrl: false,
        },
      ),
    );

    unawaited(
      OneSignal.shared.setInFocusDisplayType(
        OSNotificationDisplayType.notification,
      ),
    );

    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt.
    // We recommend removing the following code and instead using an In-App Message
    // to prompt for notification permission
    unawaited(
      OneSignal.shared.promptUserForPushNotificationPermission(
        fallbackToSettings: true,
      ),
    );
  }

  static Future<void> assignExternalUserID(userID) async {
    unawaited(OneSignal.shared.setExternalUserId(userID));
  }

  // will be called whenever a notification is received
  static void _handleNotificationReceived(OSNotification notification) {
    print('notification received');
  }

  // will be called whenever a notification is opened
  static void _handleNotificationOpened(OSNotificationOpenedResult result) {
    print('notification opened');
  }

  static void unawaited(Future<void> future) {}
}
