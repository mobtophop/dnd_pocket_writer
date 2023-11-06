import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dnd_pocket_writer/app/pages/main/cubit/state_main.dart';
import 'package:dnd_pocket_writer/app/pages/main/page_main.dart';

class CubitMain extends Cubit<StateMain> {
  CubitMain() : super(const StateMain());

  void changeStoryText(String text) {
    emit(StateMain.fromState(state, text: text));
  }

  void changeImageUrl(String text) {
    print("$text");
    emit(StateMain.fromState(state, imageURL: text));
  }

  void clearImageUrl() => changeImageUrl("");

  void changeLoadingStatus(bool status) {
    emit(StateMain.fromState(state, isAwaitingResponse: status));
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
