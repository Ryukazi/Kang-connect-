import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://qbrabirtabdfwdygghda.supabase.co';
// This is a Supabase publishable key. It is intended for client apps.
// Database safety must come from the SQL policies, never from hiding this key.
const supabasePublishableKey = 'sb_publishable_HAHoBS4h0dgHLXwNicTsgg_C2XRGM6g';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabasePublishableKey);
  runApp(const KangConnectApp());
}

final supabase = Supabase.instance.client;
const ink = Color(0xFF101426);
const panel = Color(0xFF1A2035);
const violet = Color(0xFF8B7CFF);
const mint = Color(0xFF61E6C2);

class KangConnectApp extends StatelessWidget {
  const KangConnectApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Kang Connect', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark, scaffoldBackgroundColor: ink,
      colorScheme: ColorScheme.fromSeed(seedColor: violet, brightness: Brightness.dark, surface: panel),
      useMaterial3: true,
    ),
    home: const AuthGate(),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: supabase.auth.onAuthStateChange,
    builder: (context, snapshot) {
      final session = supabase.auth.currentSession;
      return session == null ? const AuthScreen() : const MainScreen();
    },
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController(), password = TextEditingController(), name = TextEditingController();
  bool registering = false, busy = false;
  String? error, notice;
  Future<void> submit() async {
    setState(() { busy = true; error = null; notice = null; });
    try {
      if (registering) {
        final result = await supabase.auth.signUp(
          email: email.text.trim(),
          password: password.text,
          data: {'display_name': name.text.trim().isEmpty ? email.text.split('@').first : name.text.trim()},
        );
        final user = result.user;
        if (user != null && result.session != null) {
          await supabase.from('profiles').upsert({'id': user.id, 'display_name': name.text.trim().isEmpty ? email.text.split('@').first : name.text.trim()});
        } else {
          notice = 'Account created. Check your email to confirm, then sign in.';
        }
      } else {
        final result = await supabase.auth.signInWithPassword(email: email.text.trim(), password: password.text);
        final user = result.user;
        if (user != null) {
          final displayName = (user.userMetadata?['display_name'] ?? email.text.split('@').first).toString();
          await supabase.from('profiles').upsert({'id': user.id, 'display_name': displayName});
        }
      }
    } on AuthException catch (e) { error = e.message; }
      catch (e) { error = e.toString(); }
    if (mounted) setState(() => busy = false);
  }
  @override
  void dispose() { email.dispose(); password.dispose(); name.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Icon(Icons.hub_rounded, color: violet, size: 58),
            const SizedBox(height: 12),
            const Text('KANG CONNECT', textAlign: TextAlign.center, style: TextStyle(color: mint, fontWeight: FontWeight.w900, letterSpacing: 3)),
            const SizedBox(height: 8),
            Text(registering ? 'Create your account' : 'Welcome back', textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Private conversations, one connection at a time.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 28),
            if (registering) ...[
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Display name', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 12),
            ],
            TextField(controller: email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.redAccent))),
            if (notice != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(notice!, style: const TextStyle(color: mint))),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: busy ? null : submit,
              style: FilledButton.styleFrom(backgroundColor: violet, padding: const EdgeInsets.symmetric(vertical: 15)),
              child: busy ? const CircularProgressIndicator() : Text(registering ? 'Create account' : 'Sign in'),
            ),
            TextButton(onPressed: busy ? null : () => setState(() { registering = !registering; error = null; notice = null; }),
              child: Text(registering ? 'Already have an account? Sign in' : 'New here? Create an account')),
          ],
        ),
      ),
    ))),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int tab = 0;
  Future<void> createInvite() async {
    try {
      final code = await supabase.rpc('create_private_invitation');
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('Your private invite code'),
        content: SelectableText('$code\n\nSend this code only to the person you want to connect with. It expires in 7 days.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ));
    } catch (e) { if (mounted) _showError('Could not create invitation: $e'); }
  }
  Future<void> acceptInvite() async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Join a private connection'),
      content: TextField(controller: c, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Invitation code')),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Join'))],
    ));
    if (ok == true && c.text.trim().isNotEmpty) {
      try { await supabase.rpc('accept_private_invitation', params: {'invite_code': c.text.trim().toUpperCase()}); if (mounted) _showInfo('Connected! Your private chat is ready.'); }
      catch (e) { if (mounted) _showError('Could not accept invitation: $e'); }
    }
    c.dispose();
  }
  void _showInfo(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  void _showError(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s), backgroundColor: Colors.red.shade800));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(children: [Icon(Icons.hub_rounded, color: violet), SizedBox(width: 10), Text('Kang Connect', style: TextStyle(fontWeight: FontWeight.w800))]),
      actions: [IconButton(tooltip: 'Sign out', onPressed: () => supabase.auth.signOut(), icon: const Icon(Icons.logout))],
    ),
    body: IndexedStack(index: tab, children: [
      HomeTab(onCreateInvite: createInvite, onAcceptInvite: acceptInvite),
      const ConversationsTab(),
      const PrivacyTab(),
    ]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
        NavigationDestination(icon: Icon(Icons.shield_outlined), label: 'Privacy'),
      ],
    ),
  );
}

class HomeTab extends StatelessWidget {
  final VoidCallback onCreateInvite, onAcceptInvite;
  const HomeTab({super.key, required this.onCreateInvite, required this.onAcceptInvite});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const SizedBox(height: 8),
    const Text('Your private circle', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    const Text('Each invitation creates a separate one-to-one conversation. Members cannot browse other members or their chats.', style: TextStyle(color: Colors.white60, height: 1.45)),
    const SizedBox(height: 22),
    _ActionCard(icon: Icons.person_add_alt_1, title: 'Invite someone', subtitle: 'Create a one-time private invitation code', onTap: onCreateInvite),
    const SizedBox(height: 12),
    _ActionCard(icon: Icons.key_outlined, title: 'Join with a code', subtitle: 'Accept an invitation you received', onTap: onAcceptInvite),
    const SizedBox(height: 22),
    const Text('How privacy works', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    const _InfoTile(icon: Icons.lock_outline, title: 'Separate conversations', body: 'There is no group chat or shared member directory.'),
    const _InfoTile(icon: Icons.verified_user_outlined, title: 'Account-based access', body: 'Database rules limit each conversation to its two participants.'),
    const _InfoTile(icon: Icons.visibility_outlined, title: 'No hidden tracking', body: 'Location sharing is not enabled in this release. It will require clear opt-in and device permission.'),
  ]);
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(color: panel, child: ListTile(
    contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(backgroundColor: violet.withOpacity(.18), child: Icon(icon, color: violet)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
    trailing: const Icon(Icons.chevron_right), onTap: onTap,
  ));
}
class _InfoTile extends StatelessWidget {
  final IconData icon; final String title, body;
  const _InfoTile({required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Card(color: panel, child: ListTile(
    leading: Icon(icon, color: mint), title: Text(title), subtitle: Text(body, style: const TextStyle(color: Colors.white60))));
}

class ConversationsTab extends StatelessWidget {
  const ConversationsTab({super.key});
  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
    future: supabase.rpc('get_my_private_chats').then((v) => List<dynamic>.from(v)),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Could not load chats: ${snapshot.error}')));
      final chats = snapshot.data ?? [];
      if (chats.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.forum_outlined, size: 52, color: violet), SizedBox(height: 12),
        Text('No conversations yet', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        SizedBox(height: 8), Text('Create an invitation or join using a code from the Home tab.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
      ])));
      return ListView(padding: const EdgeInsets.all(16), children: [
        const Padding(padding: EdgeInsets.all(8), child: Text('Your private chats', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800))),
        ...chats.map((c) => Card(color: panel, child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text((c['other_display_name'] ?? 'Private connection').toString()),
          subtitle: const Text('Private one-to-one chat', style: TextStyle(color: Colors.white60)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(chatId: c['chat_id'].toString(), title: (c['other_display_name'] ?? 'Private chat').toString()))),
        ))),
      ]);
    },
  );
}

class ChatPage extends StatefulWidget {
  final String chatId, title;
  const ChatPage({super.key, required this.chatId, required this.title});
  @override
  State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final input = TextEditingController();
  bool sending = false;
  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty || sending) return;
    setState(() => sending = true);
    try {
      await supabase.from('messages').insert({'chat_id': widget.chatId, 'sender_id': supabase.auth.currentUser!.id, 'body': text});
      input.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message failed: $e')));
    }
    if (mounted) setState(() => sending = false);
  }
  @override
  void dispose() { input.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Column(children: [
      Expanded(child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('messages').stream(primaryKey: ['id']).eq('chat_id', widget.chatId).order('created_at'),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Message error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data!;
          if (rows.isEmpty) return const Center(child: Text('Say hello 👋', style: TextStyle(color: Colors.white60)));
          return ListView.builder(reverse: false, padding: const EdgeInsets.all(14), itemCount: rows.length, itemBuilder: (_, i) {
            final mine = rows[i]['sender_id'] == supabase.auth.currentUser?.id;
            return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft, child: Container(
              constraints: const BoxConstraints(maxWidth: 300), margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: mine ? violet.withOpacity(.28) : panel, borderRadius: BorderRadius.circular(16)),
              child: Text(rows[i]['body'].toString()),
            ));
          });
        },
      )),
      SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), child: Row(children: [
        Expanded(child: TextField(controller: input, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'Write a message…', border: OutlineInputBorder()))),
        const SizedBox(width: 8), IconButton.filled(onPressed: sending ? null : send, icon: sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send), style: IconButton.styleFrom(backgroundColor: violet)),
      ]))),
    ]),
  );
}

class PrivacyTab extends StatelessWidget {
  const PrivacyTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: const [
    Text('Privacy & control', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
    SizedBox(height: 12),
    _InfoTile(icon: Icons.lock, title: 'Separate private chats', body: 'Only the two accounts in a conversation can read its messages.'),
    _InfoTile(icon: Icons.person_off_outlined, title: 'No member directory', body: 'Members cannot list or discover your other connections.'),
    _InfoTile(icon: Icons.location_off_outlined, title: 'Location is off', body: 'This release does not collect or share device location.'),
    _InfoTile(icon: Icons.security, title: 'Account security', body: 'Use a unique password and never share your sign-in details.'),
  ]);
}
