import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Background handler must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Handle background message
  debugPrint('BG message ${message.messageId}: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Keep permission request here so iOS prompts on first run.
  await FirebaseMessaging.instance.requestPermission();

  // Optional: log token once at startup
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint('FCM token: $token');

  runApp(const MainApp());
}

class NotificationEntry {
  final String source; // foreground | opened | initial
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final String? id;
  final DateTime receivedAt;

  NotificationEntry({
    required this.source,
    required this.title,
    required this.body,
    required this.data,
    required this.id,
    required this.receivedAt,
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? _token;
  NotificationSettings? _settings;
  final List<NotificationEntry> _messages = [];
  bool _subscribed = false;
  final String _topic = 'test';

  @override
  void initState() {
    super.initState();
    _initFCMUI();
  }

  Future<void> _initFCMUI() async {
    // Load current token and permission state
    final t = await FirebaseMessaging.instance.getToken();
    final s = await FirebaseMessaging.instance.getNotificationSettings();

    // Handle if app was launched by tapping a notification
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _addMessage('initial', initial);
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen((m) => _addMessage('foreground', m));

    // App opened from background by tapping a notification
    FirebaseMessaging.onMessageOpenedApp
        .listen((m) => _addMessage('opened', m));

    setState(() {
      _token = t;
      _settings = s;
    });
  }

  void _addMessage(String source, RemoteMessage m) {
    final entry = NotificationEntry(
      source: source,
      title: m.notification?.title,
      body: m.notification?.body,
      data: m.data,
      id: m.messageId,
      receivedAt: DateTime.now(),
    );
    setState(() => _messages.insert(0, entry));
    debugPrint(
        '$source message ${m.messageId}: ${m.notification?.title} | ${m.data}');
  }

  Future<void> _requestPermission() async {
    final s = await FirebaseMessaging.instance.requestPermission();
    setState(() => _settings = s);
  }

  Future<void> _refreshToken() async {
    final t = await FirebaseMessaging.instance.getToken();
    setState(() => _token = t);
    debugPrint('Refreshed FCM token: $t');
  }

  Future<void> _copyToken() async {
    if (_token == null) return;
    await Clipboard.setData(ClipboardData(text: _token.toString()));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token copied to clipboard')),
    );
  }

  Future<void> _toggleTopic() async {
    if (_subscribed) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(_topic);
    } else {
      await FirebaseMessaging.instance.subscribeToTopic(_topic);
    }
    setState(() => _subscribed = !_subscribed);
  }

  @override
  Widget build(BuildContext context) {
    final granted =
        _settings?.authorizationStatus == AuthorizationStatus.authorized ||
            _settings?.authorizationStatus == AuthorizationStatus.provisional;

    print('token: $_token');

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FCM Demo'),
          actions: [
            IconButton(
              tooltip: 'Clear log',
              onPressed: () => setState(() => _messages.clear()),
              icon: const Icon(Icons.delete_sweep),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!(granted)) ...[
              Card(
                color: Colors.amber.shade100,
                child: const ListTile(
                  leading: Icon(Icons.notifications_off),
                  title: Text('Notifications not allowed'),
                  subtitle: Text(
                      'Tap "Request permission" below to enable notifications.'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _requestPermission,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Request permission'),
                ),
                ElevatedButton.icon(
                  onPressed: _refreshToken,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh token'),
                ),
                ElevatedButton.icon(
                  onPressed: _copyToken,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy token'),
                ),
                OutlinedButton.icon(
                  onPressed: _toggleTopic,
                  icon: Icon(
                      _subscribed ? Icons.unsubscribe : Icons.subscriptions),
                  label: Text(
                      _subscribed ? 'Unsubscribe "test"' : 'Subscribe "test"'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
                'Permission: ${_settings?.authorizationStatus.name ?? 'unknown'}'),
            const SizedBox(height: 8),
            SelectableText(
              'FCM token:\n${_token ?? '(loading...)'}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Received messages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_messages.isEmpty)
              const Text(
                  'No messages yet. Send one from Firebase Console or via HTTP v1.'),
            for (final m in _messages)
              Card(
                child: ListTile(
                  leading: Icon(
                    m.source == 'foreground'
                        ? Icons.message
                        : m.source == 'opened'
                            ? Icons.touch_app
                            : Icons.launch,
                  ),
                  title: Text(m.title ?? '(no title)'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (m.body != null) Text(m.body!),
                      Text(
                        'source: ${m.source} • id: ${m.id ?? '-'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'data: ${m.data}',
                        style: const TextStyle(
                            fontSize: 12, fontFamily: 'monospace'),
                      ),
                      Text(
                        m.receivedAt.toIso8601String(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
