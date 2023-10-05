import 'package:chat_gpt/constants/constants.dart';
import 'package:chat_gpt/models/chat_model.dart';
import 'package:chat_gpt/services/api_services.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUserMessage({required String msg}) {
    chatList
        .add(ChatModel(msg: msg, chatIndex: 0, role: ResponseType.user.name));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswer({
    required String msg,
    required String chosenModelId,
    required bool memory,
  }) async {
    if (chosenModelId.toLowerCase().startsWith("gpt")) {
      chatList.addAll(await ApiService.sendMessageGPT(
        message: msg,
        modelId: chosenModelId,
        chatsList: chatList,
        memory: memory,
      ));
      notifyListeners();
    } else {
      chatList.addAll(await ApiService.sendMessage(
        message: msg,
        modelId: chosenModelId,
      ));
    }
    notifyListeners();
  }
}
