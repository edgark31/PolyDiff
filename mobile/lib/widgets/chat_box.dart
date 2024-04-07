import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:provider/provider.dart';

class ChatBox extends StatefulWidget {
  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode textFocusNode = FocusNode();
  bool isTyping = false;
  bool isGlobalChat = true;
  bool canDisplayLobbyMessages = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setInitialChatMode());
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;
    bool isUserScrolling =
        scrollController.position.userScrollDirection != ScrollDirection.idle;
    if (isUserScrolling) return;
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _setInitialChatMode() {
    final routeName = ModalRoute.of(context)?.settings.name;
    final lobbyService = context.read<LobbyService>();

    setState(() {
      bool canPageShowLobbyMessages =
          routeName == LOBBY_ROUTE || routeName == GAME_ROUTE;
      canDisplayLobbyMessages = canPageShowLobbyMessages &&
          lobbyService.gameModes != GameModes.Practice;
      isGlobalChat = !canDisplayLobbyMessages;
    });
  }

  void _handleMessageSubmit(String message) {
    final chatService = context.read<ChatService>();
    final routeName = ModalRoute.of(context)?.settings.name;
    if (message.isNotEmpty && message.trim().isNotEmpty) {
      if (isGlobalChat) {
        chatService.sendGlobalMessage(message);
      } else if (routeName == LOBBY_ROUTE) {
        chatService.sendLobbyMessage(message);
      } else {
        chatService.sendGameMessage(message);
      }
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    }
    messageController.clear();
    FocusScope.of(context).requestFocus(textFocusNode);
  }

  void _switchChatMode() {
    setState(() {
      isGlobalChat = !isGlobalChat;
    });
  }

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();
    final chatService = context.watch<ChatService>();

    final messages =
        isGlobalChat ? chatService.globalMessages : chatService.lobbyMessages;
    return Container(
      width: 500,
      height: 700,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.chat_box_title,
                ),
                Row(
                  mainAxisAlignment: canDisplayLobbyMessages
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  children: [
                    Text(
                      isGlobalChat
                          ? AppLocalizations.of(context)!.chat_box_globalChat
                          : "Chat",
                    ),
                    canDisplayLobbyMessages
                        ? ElevatedButton(
                            onPressed: _switchChatMode,
                            child: Text(isGlobalChat
                                ? AppLocalizations.of(context)!
                                    .chat_box_goBackChat
                                : AppLocalizations.of(context)!
                                    .chat_box_changeGlobalChat),
                          )
                        : Container(),
                  ],
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
                  final message = messages[index];
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollToBottom();
                  });
                  if (message.tag == MessageTag.Common) {
                    return Center(
                      child: Container(
                        width: 250,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ThemeData.dark().primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(message.raw,
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.center),
                      ),
                    );
                  }
                  bool isSent = message.accountId == infoService.id;
                  String avatarURL =
                      '$BASE_URL/avatar/${message.accountId}.png';
                  return Align(
                    alignment:
                        isSent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isSent
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          key: UniqueKey(),
                          backgroundImage: NetworkImage(avatarURL),
                          radius: 15.0,
                        ),
                        Text(
                          messages[index].name!,
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
                            messages[index].raw,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Text(
                            messages[index].timestamp!,
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
                    focusNode: textFocusNode,
                    controller: messageController,
                    onChanged: (text) {
                      setState(() {
                        isTyping = text.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.chat_box_textHint,
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    onSubmitted: _handleMessageSubmit,
                  ),
                ),
                SizedBox(width: 10),
                if (isTyping)
                  IconButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.secondary),
                      ),
                      icon: Icon(Icons.send),
                      onPressed: () {
                        _handleMessageSubmit(messageController.text);
                      }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
