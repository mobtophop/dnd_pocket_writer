import 'package:equatable/equatable.dart';
import 'package:dnd_pocket_writer/app/pages/main/page_main.dart';

class StateMain extends Equatable {
  const StateMain({
    this.apiKey = "",
    this.text = "",
    this.warning = "",
    this.imageURL = "",
    this.isAwaitingResponse = false,
    this.isLoadingImage = false,
    this.promptParameters = const {},
    this.lastUsedPromptParameters = const {},
  });

  StateMain.fromState(
    StateMain oldState, {
    String? apiKey,
    String? text,
    String? warning,
    String? imageURL,
    bool? isAwaitingResponse,
    bool? isLoadingImage,
    Map<PromptParameters, String>? promptParameters,
    Map<PromptParameters, String>? lastUsedPromptParameters,
  })  : apiKey = apiKey ?? oldState.apiKey,
        text = text ?? oldState.text,
        warning = warning ?? oldState.warning,
        imageURL = imageURL ?? oldState.imageURL,
        isAwaitingResponse = isAwaitingResponse ?? oldState.isAwaitingResponse,
        isLoadingImage = isLoadingImage ?? oldState.isLoadingImage,
        promptParameters = promptParameters ?? oldState.promptParameters,
        lastUsedPromptParameters =
            lastUsedPromptParameters ?? oldState.lastUsedPromptParameters;

  final String apiKey;
  final String text;
  final String warning;
  final String imageURL;
  final bool isAwaitingResponse;
  final bool isLoadingImage;
  final Map<PromptParameters, String> promptParameters;
  final Map<PromptParameters, String> lastUsedPromptParameters;

  @override
  List<Object?> get props => [
        apiKey,
        text,
        warning,
        imageURL,
        isAwaitingResponse,
        isLoadingImage,
        promptParameters,
        promptParameters.length,
        promptParameters.hashCode,
        lastUsedPromptParameters,
        lastUsedPromptParameters.length,
        lastUsedPromptParameters.hashCode,
      ];
}
