import 'package:flutter/material.dart';

void main() => runApp(const KangConnectApp());

const ink = Color(0xFF101426);
const panel = Color(0xFF1A2035);
const violet = Color(0xFF8B7CFF);
const mint = Color(0xFF61E6C2);

class KangConnectApp extends StatelessWidget {
  const KangConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kang Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ink,
        colorScheme: ColorScheme.fromSeed(
          seedColor: violet,
          brightness: Brightness.dark,
          surface: panel,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  bool locationSharing = false;
  bool activitySharing = false;
  final List<Member> members = const [
    Member('You', 'You control your sharing', 'Y', Color(0xFF8B7CFF)),
    Member('Cambodia', 'Invite to connect', 'C', Color(0xFFFFB86B)),
    Member('Philippines', 'Invite to connect', 'P', Color(0xFF61E6C2)),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      const ChatScreen(),
      _privacy(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF171D30),
        indicatorColor: violet.withOpacity(.22),
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.shield_outlined), label: 'Privacy'),
        ],
      ),
    );
  }

  Widget _home() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
    children: [
      Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [violet, Color(0xFF5D55C9)]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('KANG CONNECT', style: TextStyle(fontSize: 11, letterSpacing: 2.1, color: mint, fontWeight: FontWeight.w800)),
          Text('Your private circle', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ])),
        IconButton(onPressed: () => setState(() => tab = 2), icon: const Icon(Icons.settings_outlined)),
      ]),
      const SizedBox(height: 28),
      const Text('Stay close,', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.05)),
      const Text('wherever life takes you.', style: TextStyle(fontSize: 25, color: violet, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Text('A private space built around trust and permission.', style: TextStyle(color: Colors.white.withOpacity(.62), fontSize: 14)),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF29274D), Color(0xFF1B2940)]),
          border: Border.all(color: violet.withOpacity(.28)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.lock_outline, color: mint, size: 18),
            SizedBox(width: 8),
            Text('YOUR SHARING STATUS', style: TextStyle(fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 18),
          _shareSwitch('Live location', 'Only share when you choose', Icons.location_on_outlined, locationSharing,
            (v) => setState(() => locationSharing = v)),
          const Divider(height: 24, color: Colors.white12),
          _shareSwitch('Activity summary', 'Optional; never hidden tracking', Icons.insights_outlined, activitySharing,
            (v) => setState(() => activitySharing = v)),
          const SizedBox(height: 10),
          Text('These switches are local demo controls for now. No data is sent to anyone yet.',
            style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 11)),
        ]),
      ),
      const SizedBox(height: 26),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Your circle', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        Text('3 spaces', style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 12)),
      ]),
      const SizedBox(height: 12),
      ...members.map(_memberCard),
      const SizedBox(height: 18),
      OutlinedButton.icon(
        onPressed: () => _message('Invitations will be enabled after we connect the secure backend.'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Invite someone'),
        style: OutlinedButton.styleFrom(foregroundColor: mint, side: BorderSide(color: mint.withOpacity(.5)), padding: const EdgeInsets.symmetric(vertical: 15)),
      ),
    ],
  );

  Widget _shareSwitch(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) =>
    Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: violet.withOpacity(.16), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: violet)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.55))),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: mint),
    ]);

  Widget _memberCard(Member m) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.06))),
    child: Row(children: [
      CircleAvatar(radius: 22, backgroundColor: m.color.withOpacity(.18), child: Text(m.initial, style: TextStyle(color: m.color, fontWeight: FontWeight.w800))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(m.detail, style: TextStyle(color: Colors.white.withOpacity(.52), fontSize: 12)),
      ])),
      Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(.35)),
    ]),
  );

  Widget _privacy() => ListView(padding: const EdgeInsets.all(20), children: [
    const SizedBox(height: 12),
    const Text('Privacy & control', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    Text('Sharing should always be visible, voluntary, and easy to stop.', style: TextStyle(color: Colors.white.withOpacity(.6))),
    const SizedBox(height: 22),
    _privacyTile(Icons.visibility_outlined, 'Clear sharing status', 'Everyone can see whether a feature is enabled.'),
    _privacyTile(Icons.pause_circle_outline, 'Stop sharing anytime', 'A member can turn off sharing without asking.'),
    _privacyTile(Icons.lock_outline, 'Private by design', 'Only invited, authenticated members will access shared data once the backend is connected.'),
    _privacyTile(Icons.phone_android, 'Device permissions', 'Location and usage access must be granted by the device owner.'),
    const SizedBox(height: 18),
    const Text('Build status: UI prototype', style: TextStyle(color: mint, fontWeight: FontWeight.bold)),
    Text('Next: Firebase sign-in, invitations, live location, and real-time messaging.', style: TextStyle(color: Colors.white.withOpacity(.6))),
  ]);

  Widget _privacyTile(IconData icon, String title, String body) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(17)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: mint), const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(body, style: TextStyle(color: Colors.white.withOpacity(.57), fontSize: 12)),
      ])),
    ]),
  );

  void _message(String text) => showDialog(context: context, builder: (_) => AlertDialog(
    backgroundColor: panel, content: Text(text),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
  ));
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const SizedBox(height: 12),
    const Text('Messages', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    Text('A quiet place for your circle.', style: TextStyle(color: Colors.white.withOpacity(.6))),
    const SizedBox(height: 25),
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(20)),
      child: const Column(children: [
        Icon(Icons.forum_outlined, size: 42, color: violet),
        SizedBox(height: 12),
        Text('Your conversations will appear here', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 8),
        Text('Chat is a starter screen. Secure sign-in and message storage will be connected in the next stage.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, height: 1.4)),
      ]),
    ),
  ]);
}

class Member {
  final String name, detail, initial;
  final Color color;
  const Member(this.name, this.detail, this.initial, this.color);
}
