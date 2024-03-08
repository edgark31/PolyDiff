import 'package:flutter/material.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/chat_message_model.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:provider/provider.dart';

class ChatBox extends StatefulWidget {
  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isTyping = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;
    print("scrolling to bottom");
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final socketService = context.watch<SocketService>();
    final messages = socketService.allMessages;
    final infoService = context.watch<InfoService>();
    final userName = infoService.name;
    return Container(
      width: 500,
      height: 700,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFE6EAEA),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            color: Color(0xFF7DAF9C),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ZONE DE CLAVARDAGE",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isSent = messages[index].userName == userName;
                  return Align(
                    alignment:
                        isSent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isSent
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                            backgroundImage: NetworkImage(
                                'http://127.0.0.1:3000/${messages[index].userName}.png'),
                            radius: 15.0),
                        Text(
                          messages[index].userName,
                          style: TextStyle(color: Colors.black),
                        ),
                        Container(
                          width: 250,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSent ? Colors.blue : Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            messages[index].message,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Text(
                            messages[index].timestamp,
                            style: TextStyle(color: Colors.black, fontSize: 12),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onChanged: (text) {
                      setState(() {
                        isTyping = text.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Entrez un message...",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                if (isTyping)
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      String message = messageController.text;
                      if (message.isNotEmpty) {
                        socketService.sendMessage(
                          ChatMessage(
                            MessageTag.Sent,
                            message,
                            userName,
                            'test',
                          ),
                        );
                        setState(() {});
                        messageController.clear();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          scrollToBottom();
                        });
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
