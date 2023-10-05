import 'dart:developer';

import 'package:chat_gpt/constants/constants.dart';
import 'package:chat_gpt/models/chat_model.dart';
import 'package:chat_gpt/providers/chat_provider.dart';
import 'package:chat_gpt/providers/models_provider.dart';
import 'package:chat_gpt/services/assets_manager.dart';
import 'package:chat_gpt/services/services.dart';
import 'package:chat_gpt/widgets/chat_widget.dart';
import 'package:chat_gpt/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;

  late FocusNode focusNode;
  late TextEditingController textEditingController;
  late ScrollController scrollController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetManager.openaiLogo),
        ),
        title: const Text("ChatGPT"),
        actions: [
          IconButton(
              onPressed: () async {
                await Services.showModalSheet(context: context);
              },
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
              ))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: chatProvider.getChatList.length, //chatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                        msg: chatProvider
                            .getChatList[index].msg, //chatList[index].msg,
                        chatIndex: chatProvider.getChatList[index]
                            .chatIndex //chatList[index].chatIndex,
                        );
                  }),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 15,
            ),
            Material(
              color: cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextField(
                        focusNode: focusNode,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        controller: textEditingController,
                        onSubmitted: (value) async {
                          await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        decoration: const InputDecoration.collapsed(
                            hintText: "How can I help you",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await sendMessageFCT(
                          modelsProvider: modelsProvider,
                          chatProvider: chatProvider);
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scrollListToEnd() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.easeIn,
    );
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You can't send multiple messages at a time!",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (textEditingController.text.isEmpty) {
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        // chatList.add(ChatModel(
        //   msg: textEditingController.text,
        //   chatIndex: 0,
        // ));
        chatProvider.addUserMessage(msg: msg);
        textEditingController.clear();
        focusNode.unfocus();
      });
      // chatList.addAll(await ApiService.sendMessage(
      //   msg: textEditingController.text,
      //   modelId: modelsProvider.getCurrentModel,
      // ));
      await chatProvider.sendMessageAndGetAnswer(
        msg: msg,
        chosenModelId: modelsProvider.getCurrentModel,
        memory: modelsProvider.hasMemory,
      );
      setState(() {});
    } catch (error) {
      log("error $error");
      var errorText = error.toString();
      // disable memory if max token length reached
      if (error.toString().contains("max_length")) {
        errorText =
            'Maximum token length reached. Memory disabled for this session';
        modelsProvider.setMemoryEnabled(false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            label: errorText,
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTyping = false;
        scrollListToEnd();
      });
    }
  }
}
