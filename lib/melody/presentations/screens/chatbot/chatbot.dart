import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';


void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

// Class to store conversation state
class ConversationState {
  static String conversationId = DateTime.now().millisecondsSinceEpoch.toString();

  static void resetConversation() {
    conversationId = DateTime.now().millisecondsSinceEpoch.toString();
  }
}

Future<String> getResponseFromCozeAPI(String userMessage) async {
  var url = 'https://api.coze.com/v3/chat';

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization':
            'Bearer pat_gwhDw6wlPQkXnwklGSAOd0i59JbYefaV14uPgkxU6pWEf5kf1zH5RLJsSFMpTjBh',
      },
      body: jsonEncode({
        'bot_id': '7505016460880904193',
        'user_id': '7363947110343458824',
        'query': userMessage,
        'stream': false,
      }),
    );

    print('Coze API response: ${response.body}');
    var data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['code'] == 0) {
      if (data['data'] != null && data['data']['messages'] != null) {
        var messages = data['data']['messages'];
        if (messages.isNotEmpty) {
          // Tìm message có type là 'answer'
          var answerMessage = messages.firstWhere(
            (msg) => msg['type'] == 'answer',
            orElse: () => messages.last,
          );

          if (answerMessage['content'] != null) {
            return answerMessage['content'];
          }
        }
      }
    }
    return 'Không nhận được phản hồi từ bot.';
  } catch (e) {
    print('Error communicating with Coze API: $e');
    return "Sorry, I couldn't connect to the assistant. Please try again later.";
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const ChatPage(),
      );
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, AnimationController? animationController});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  bool _isLoading = false;
  
  final _user = const types.User(
    id: '123333333',
    firstName: 'User',
  );
  
  final _bot = const types.User(
    id: 'bot',
    firstName: 'Assistant',
  );
  
  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: 'Hello! How can I help you today?',
    );
    _addMessage(welcomeMessage);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
      // Note: You would need to add file handling for the Coze API here
      // Currently the API examples don't show file uploads
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
      // Note: You would need to add image handling for the Coze API here
      // Currently the API examples don't show image uploads
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFile.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    // Prevent empty messages
    if (message.text.trim().isEmpty) return;
    
    // Prevent multiple simultaneous requests
    if (_isLoading) return;
    
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
    
    // Set loading state
    setState(() {
      _isLoading = true;
    });
    
    // Add a typing indicator
    final loadingMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: '...',
      metadata: {'isTyping': true},
    );

    _addMessage(loadingMessage);
    
    try {
      // Get response from Coze API
      var cozeResponse = await getResponseFromCozeAPI(message.text);
      
      // Create the bot message
      final botMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: cozeResponse,
      );

      setState(() {
        // Remove the loading message
        _messages.removeWhere((msg) => 
          msg.id == loadingMessage.id || 
          (msg.metadata != null && msg.metadata!['isTyping'] == true)
        );
        // Add the bot's response
        _messages.insert(0, botMessage);
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors gracefully
      setState(() {
        // Remove the loading message
        _messages.removeWhere((msg) => 
          msg.id == loadingMessage.id || 
          (msg.metadata != null && msg.metadata!['isTyping'] == true)
        );
        
        // Add an error message
        _messages.insert(0, types.TextMessage(
          author: _bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: 'Sorry, I encountered an error. Please try again.',
        ));
        _isLoading = false;
      });
      print('Failed to get response from Coze API: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Chat Assistant'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Reset conversation
                setState(() {
                  _messages = [];
                  ConversationState.resetConversation();
                });
                _addWelcomeMessage();
              },
            ),
          ],
        ),
        body: Chat(
          messages: _messages,
          onAttachmentPressed: _handleAttachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
          theme: const DefaultChatTheme(
            seenIcon: Text(
              'read',
              style: TextStyle(
                fontSize: 10.0,
              ),
            ),
            inputBackgroundColor: Color.fromARGB(255, 19, 8, 8),
            backgroundColor: Color(0xFFF7F7FC),
            primaryColor: Colors.blue,
            secondaryColor: Color(0xFFEAEAF2),
          ),
        ),
      );
}