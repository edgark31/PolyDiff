import 'package:flutter/material.dart';

import 'classes.dart';

class ChatBox extends StatefulWidget {
  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  List<ChatMessage> messages = [
    ChatMessage('sent', 'hello Zak', 'Mark', '15:05:57'),
    ChatMessage(
        'sent',
        'wanted to test out that writing a super long message wouldnt ruin the display of these text messages. Sorry for bothering you right now, even though I know your probably having fun at home with your raccoon friends you little raccoon',
        'Mark',
        '15:07:10'),
    ChatMessage('received', 'good day mate', 'Zak', '15:48:10'),
    ChatMessage(
        'received',
        'No worries bro I was testing it out myself over here. Did you buy yo mamas christmas gift? She precisely said that she wanted something for her kitchen, something expensive',
        'Zak',
        '15:49:57'),
  ];
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isTyping = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  "Chat user #2",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
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
                  bool isSent = messages[index].tag == 'sent';
                  return Align(
                    alignment:
                        isSent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isSent
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
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
                  ElevatedButton(
                    onPressed: () {
                      String message = messageController.text;
                      if (message.isNotEmpty) {
                        setState(() {
                          messages.add(
                              ChatMessage('sent', message, 'Mark', 'test'));
                        });
                        messageController.clear();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          scrollToBottom();
                        });
                      }
                    },
                    child: Text("Send"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
