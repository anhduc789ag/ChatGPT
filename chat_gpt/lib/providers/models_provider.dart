import 'package:chat_gpt/models/models_model.dart';
import 'package:chat_gpt/services/api_services.dart';
import 'package:flutter/material.dart';

class ModelsProvider with ChangeNotifier {
  String currentModel = "gpt-3.5-turbo-0301";
  bool hasMemory = false;

  String get getCurrentModel {
    return currentModel;
  }

  void setMemoryEnabled(bool enabled) {
    hasMemory = enabled;
    notifyListeners();
  }

  void setCurrentModel(String newModel) {
    currentModel = newModel;
    notifyListeners();
  }

  List<ModelsModel> modelsList = [];

  List<ModelsModel> get getModelsList {
    return modelsList;
  }

  Future<List<ModelsModel>> getAllModels() async {
    modelsList = await ApiService.getModels();

    return modelsList;
  }
}
