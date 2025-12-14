````markdown ### Firebase Messaging Setup
        To properly set up Firebase Messaging in your Flutter project, follow these steps:

        1. **Add the following metadata to your AndroidManifest.xml file:**

            ```xml
            <meta-data android:name="com.google.firebase.messaging.default_notification_channel_id"
                          android:value="project_name" />
            ```

        2. **Initialize the NotificationDelegate in your `main.dart` file:**

            ```dart
            void main() async {
              WidgetsFlutterBinding.ensureInitialized();
                NotificationDelegate.initialize();
              runApp(MyApp());
            }
            ```

            Replace `MyApp` with the name of your main application widget.
        ```
````
