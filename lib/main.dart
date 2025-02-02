import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Remove the debug banner
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ollama Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OllamaChatPage(),
    );
  }
}

class OllamaChatPage extends StatefulWidget {
  @override
  _OllamaChatPageState createState() => _OllamaChatPageState();
}

class _OllamaChatPageState extends State<OllamaChatPage> {
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Create an instance of the Ollama client
  // final client = OllamaClient(baseUrl: 'http://localhost:11434/api');
  final client = OllamaClient(baseUrl: 'https://3a23-2601-547-782-35c0-756c-7b8f-3c93-4596.ngrok-free.app/api');

_sendMessage(String messageText) async {
  if (messageText.isEmpty) return;
  setState(() {
    _messages.add(ChatMessage(text: messageText, isUser: true));
  _isLoading = true;
  });
  
   final stream = client.generateCompletionStream(
  request: GenerateCompletionRequest(
    model: 'llama3.2:1b',
    prompt: messageText,
  ),
);
 ChatMessage botMessage = ChatMessage(text: '', isUser: false);
    setState(() {
      _messages.add(botMessage);
    });

    try {
      await for (final res in stream) {
        setState(() {
          botMessage.text += res.response!;
        });
            }
    } catch (e) {
      setState(() {
        botMessage.text = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
 
 _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ollama Chat'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(message: message);
                },
              ),
            ),
            if (_isLoading) LinearProgressIndicator(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Enter your message',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ));
  }
}

class ChatMessage {
  String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment =
    message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = message.isUser ? Colors.blue[100] : Colors.grey[200];
    final textColor = Colors.black;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            message.text.trim(),
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    );
  }
}