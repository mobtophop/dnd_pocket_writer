import 'package:dnd_pocket_writer/domain/providers/open_ai_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dnd_pocket_writer/app/pages/main/cubit/state_main.dart';
import 'package:dnd_pocket_writer/app/pages/main/page_main.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CubitMain extends Cubit<StateMain> {
  CubitMain(TextEditingController controller) : super(const StateMain()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SharedPreferences.getInstance().then((prefs) {
        String key = prefs.getString("api_key") ?? "";

        changeApiKey(key);
        controller.text = key;
      });
    });
  }

  void changeApiKey(String key) {
    emit(StateMain.fromState(state, apiKey: key));
  }

  void changeStoryText(String text) {
    emit(StateMain.fromState(state, text: text));
  }

  void changeImageUrl(String text) {
    debugPrint(text);
    emit(StateMain.fromState(state, imageURL: text));
  }

  void clearImageUrl() => changeImageUrl("");

  void changeLoadingStatus(bool status, [bool? imageLoadingStatus]) {
    emit(
      StateMain.fromState(
        state,
        isAwaitingResponse: status,
        isLoadingImage: imageLoadingStatus,
      ),
    );
  }

  void changeParameter(PromptParameters parameter, String? value) {
    Map<PromptParameters, String> newParameters = {...state.promptParameters};

    if (value == null) {
      newParameters.remove(parameter);
    } else {
      newParameters.addAll({parameter: value});
    }

    emit(StateMain.fromState(state, promptParameters: newParameters));
  }

  void saveLastParameters(Map<PromptParameters, String> parameters) {
    emit(StateMain.fromState(state, lastUsedPromptParameters: {...parameters}));
  }

  void changeWarning(String warning) {
    emit(StateMain.fromState(state, warning: warning));
  }

  Future<StreamedResponse> generateStory(
    String apiKey,
    String completeRequest,
  ) async {
    var result = await GetIt.I.get<OpenAiProvider>().generateStory(
          apiKey: apiKey,
          prompt: completeRequest,
        );

    if (result.isRight) {
      return result.right;
    } else {
      throw Exception(result.left.message);
    }
  }

  Future<Response> generatePrompts(
    String apiKey,
    String story,
  ) async {
    var result = await GetIt.I.get<OpenAiProvider>().generatePrompts(
          apiKey: apiKey,
          story: story,
        );

    if (result.isRight) {
      return result.right;
    } else {
      throw Exception(result.left.message);
    }
  }

  Future<Response> generateImage(
    String apiKey,
    String prompt,
  ) async {
    var result = await GetIt.I.get<OpenAiProvider>().generateImage(
          apiKey: apiKey,
          prompt: prompt,
        );

    if (result.isRight) {
      return result.right;
    } else {
      throw Exception(result.left.message);
    }
  }

  void clearWarning() => changeWarning("");
}
