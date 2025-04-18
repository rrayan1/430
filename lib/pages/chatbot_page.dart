import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> getAIReply(String prompt) async {
  final callable = FirebaseFunctions.instance.httpsCallable('getDoctorRecommendation');
  final response = await callable.call({'prompt': prompt});
  return response.data['reply'];
}

Future<void> saveMessage({
  required String userId,
  required String sender,
  required String text,
}) async {
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('messages');

  print('📤 Saving message: $text from $sender to $userId');

  try {
    await ref.add({
      'sender': sender,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('✅ Message saved successfully');
  } catch (e) {
    print('❌ Error saving message: $e');
  }
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void sendMessage() async {
    print("📤 User pressed send");
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ No user signed in.");
      return;
    }

    final userId = user.uid;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });

    await saveMessage(userId: userId, sender: 'user', text: text);
    _controller.clear();

    try {
      print('⚡ Calling AI...');
      final aiReply = await getAIReply(text);
      print('✅ AI Reply: $aiReply');

      setState(() {
        _messages.add({'sender': 'ai', 'text': aiReply});
      });

      await saveMessage(userId: userId, sender: 'ai', text: aiReply);
    } catch (e) {
      print('❌ Error calling AI: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _messages.map((msg) {
                return Align(
                  alignment: msg['sender'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg['sender'] == 'user'
                          ? Colors.blue[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text'] ?? ''),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: "Enter your message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
