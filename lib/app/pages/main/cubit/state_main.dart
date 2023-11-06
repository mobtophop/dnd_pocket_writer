import 'package:equatable/equatable.dart';
import 'package:dnd_pocket_writer/app/pages/main/page_main.dart';

class StateMain extends Equatable {
  const StateMain({
    this.text = "",
    this.warning = "",
    this.imageURL = "",
    this.isAwaitingResponse = false,
    this.promptParameters = const {},
    this.lastUsedPromptParameters = const {},
  });

  StateMain.fromState(
    StateMain oldState, {
    String? text,
    String? warning,
    String? imageURL,
    bool? isAwaitingResponse,
    Map<PromptParameters, String>? promptParameters,
    Map<PromptParameters, String>? lastUsedPromptParameters,
  })  : text = text ?? oldState.text,
        warning = warning ?? oldState.warning,
        imageURL = imageURL ?? oldState.imageURL,
        isAwaitingResponse = isAwaitingResponse ?? oldState.isAwaitingResponse,
        promptParameters = promptParameters ?? oldState.promptParameters,
        lastUsedPromptParameters =
            lastUsedPromptParameters ?? oldState.lastUsedPromptParameters;

  final String text;
  final String warning;
  final String imageURL;
  final bool isAwaitingResponse;
  final Map<PromptParameters, String> promptParameters;
  final Map<PromptParameters, String> lastUsedPromptParameters;

  @override
  List<Object?> get props => [
        text,
        warning,
        imageURL,
        isAwaitingResponse,
        promptParameters,
        promptParameters.length,
        promptParameters.hashCode,
        lastUsedPromptParameters,
        lastUsedPromptParameters.length,
        lastUsedPromptParameters.hashCode,
      ];
}
