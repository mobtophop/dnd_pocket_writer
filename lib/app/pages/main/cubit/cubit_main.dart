import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dnd_pocket_writer/app/pages/main/cubit/state_main.dart';
import 'package:dnd_pocket_writer/app/pages/main/page_main.dart';
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

  void clearWarning() => changeWarning("");
}
