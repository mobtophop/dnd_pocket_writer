import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dnd_pocket_writer/app/pages/main/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:dnd_pocket_writer/app/pages/main/cubit/cubit_main.dart';
import 'package:dnd_pocket_writer/app/pages/main/cubit/state_main.dart';
import 'package:dnd_pocket_writer/app/pages/main/widgets/image_download_button.dart';
import 'package:dnd_pocket_writer/app/pages/main/widgets/main_page_slider.dart';
import 'package:dnd_pocket_writer/app/pages/page_base_widget.dart';
import 'package:dnd_pocket_writer/misc/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PromptParameters {
  cGender,
  cRace,
  cClass,
  cBackground,
  sMood,
  sLengthValue,
}

class PageMain extends StatelessWidget {
  PageMain({super.key});

  static const Map parameterTitles = {
    PromptParameters.cGender: "Gender",
    PromptParameters.cRace: "Race",
    PromptParameters.cClass: "Class",
    PromptParameters.cBackground: "Background",
    PromptParameters.sMood: "Mood",
    PromptParameters.sLengthValue: "Length",
  };

  static const Map<PromptParameters, List> parameterOptions = {
    PromptParameters.cGender: ["Male", "Female", "Non-binary"],
    PromptParameters.cRace: [
      "Dwarf",
      "Elf",
      "Halfling",
      "Human",
      "Dragonborn",
      "Gnome",
      "Half-Elf",
      "Half-Orc",
      "Tiefling",
    ],
    PromptParameters.cClass: [
      "Barbarian",
      "Bard",
      "Cleric",
      "Druid",
      "Fighter",
      "Monk",
      "Paladin",
      "Ranger",
      "Rogue",
      "Sorcerer",
      "Warlock",
      "Wizard",
    ],
    PromptParameters.cBackground: [
      "Acolyte",
      "Charlatan",
      "Criminal",
      "Entertainer",
      "Guild Artisan",
      "Hermit",
      "Noble",
      "Outlander",
      "Sage",
      "Sailor",
      "Soldier",
      "Urchin",
    ],
    PromptParameters.sMood: [
      "Happy",
      "Tragic",
      "Inspirational",
      "Mysterious",
    ],
    PromptParameters.sLengthValue: [100],
  };

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CubitMain>(
      create: (context) => CubitMain(controller),
      child: BlocBuilder<CubitMain, StateMain>(
        builder: (context, state) {
          CubitMain bloc = BlocProvider.of<CubitMain>(context);

          List<PromptParameters> characterParameters = PromptParameters.values
              .where((v) => v.name.startsWith("c"))
              .toList();

          List<Widget> characterPromptWidgets = [];
          for (PromptParameters parameter in characterParameters) {
            characterPromptWidgets.addAll(
              _buildDropdown(
                context,
                parameter,
                bloc.changeParameter,
              ),
            );
          }

          return PageBase(
            onDrawerChanged: (value) async {
              if (!value) {
                bloc.changeApiKey(controller.text);

                var prefs = await SharedPreferences.getInstance();
                prefs.setString("api_key", controller.text);
              }
            },
            title: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                "assets/images/logo_long_white.png",
                height: AppBar().preferredSize.height,
              ),
            ),
            drawer: _buildMainDrawer(controller),
            child: Builder(
              builder: (context) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle("Character parameters:"),
                        ...characterPromptWidgets,
                        _buildSectionTitle("Story parameters:"),
                        ..._buildDropdown(
                          context,
                          PromptParameters.sMood,
                          bloc.changeParameter,
                        ),
                        Row(
                          children: [
                            Text(
                              parameterTitles[PromptParameters.sLengthValue],
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: MainPageSlider(
                                onChanged: (value) {
                                  bloc.changeParameter(
                                    PromptParameters.sLengthValue,
                                    value.toString(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: SizedBox(
                            height: 96.0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                    (_) => AppColors.backgroundWhite
                                        .withOpacity(0.3),
                                  ),
                                  backgroundColor:
                                      MaterialStateColor.resolveWith(
                                    (_) => state.isAwaitingResponse
                                        ? AppColors.mainLight40
                                        : AppColors.main,
                                  ),
                                  foregroundColor:
                                      MaterialStateColor.resolveWith(
                                    (_) => state.isAwaitingResponse
                                        ? AppColors.mainLight80
                                        : AppColors.backgroundWhite,
                                  ),
                                ),
                                onPressed: state.isAwaitingResponse
                                    ? null
                                    : () => _onGenerateButtonPress(
                                          context,
                                          bloc,
                                          state.promptParameters,
                                          state.apiKey,
                                        ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Generate story!",
                                    style: TextStyle(fontSize: 24.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (state.warning.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              state.warning,
                              style: const TextStyle(
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.main,
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                if (state.text.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          Clipboard.setData(
                                            ClipboardData(text: state.text),
                                          ).then(
                                            (_) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Story copied to clipboard!',
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateColor.resolveWith(
                                            (_) => AppColors.main,
                                          ),
                                          padding:
                                              MaterialStateProperty.resolveWith(
                                            (_) => const EdgeInsets.all(16.0),
                                          ),
                                        ),
                                        child: const Icon(Icons.copy),
                                      ),
                                      ElevatedButton(
                                        onPressed: state.isAwaitingResponse
                                            ? null
                                            : () => _onGenerateButtonPress(
                                                  context,
                                                  bloc,
                                                  state
                                                      .lastUsedPromptParameters,
                                                  state.apiKey,
                                                ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateColor.resolveWith(
                                            (_) => state.isAwaitingResponse
                                                ? AppColors.mainLight20
                                                : AppColors.main,
                                          ),
                                          padding:
                                              MaterialStateProperty.resolveWith(
                                            (_) => const EdgeInsets.all(16.0),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.refresh,
                                          color: state.isAwaitingResponse
                                              ? AppColors.mainLight80
                                              : AppColors.backgroundWhite,
                                        ),
                                      ),
                                      const Expanded(child: SizedBox()),
                                      ElevatedButton(
                                        onPressed: state.isAwaitingResponse
                                            ? null
                                            : () => _onPortraitButtonPress(
                                                  bloc,
                                                  state.apiKey,
                                                ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateColor.resolveWith(
                                            (_) => state.isAwaitingResponse
                                                ? AppColors.mainLight20
                                                : AppColors.main,
                                          ),
                                          padding:
                                              MaterialStateProperty.resolveWith(
                                            (_) => const EdgeInsets.all(16.0),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.draw,
                                          color: state.isAwaitingResponse
                                              ? AppColors.mainLight80
                                              : AppColors.backgroundWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                ],
                                if (state.imageURL.isNotEmpty ||
                                    state.isLoadingImage)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.backgroundWhite,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Center(
                                          child: state.imageURL.isEmpty
                                              ? const CircularProgressIndicator(
                                                  color:
                                                      AppColors.backgroundWhite,
                                                )
                                              : Image.network(
                                                  state.imageURL,
                                                  repeat: ImageRepeat.noRepeat,
                                                  fit: BoxFit.fill,
                                                  loadingBuilder: (context,
                                                      child, loading) {
                                                    return loading == null
                                                        ? Stack(
                                                            alignment: Alignment
                                                                .topRight,
                                                            children: [
                                                              Center(
                                                                  child: child),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                  8.0,
                                                                ),
                                                                child:
                                                                    ImageDownloadButton(
                                                                  url: state
                                                                      .imageURL,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : CircularProgressIndicator(
                                                            color: AppColors
                                                                .backgroundWhite,
                                                            backgroundColor:
                                                                AppColors
                                                                    .backgroundWhite
                                                                    .withOpacity(
                                                              0.2,
                                                            ),
                                                            value: loading
                                                                        .expectedTotalBytes !=
                                                                    null
                                                                ? loading
                                                                        .cumulativeBytesLoaded /
                                                                    loading
                                                                        .expectedTotalBytes!
                                                                : null,
                                                          );
                                                  },
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                TextField(
                                  controller: TextEditingController()
                                    ..text = state.text,
                                  readOnly: true,
                                  decoration: InputDecoration.collapsed(
                                    hintText: "\n\nYour story will be here...",
                                    hintStyle: TextStyle(
                                      color: AppColors.backgroundWhite
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  cursorColor: AppColors.backgroundWhite,
                                  minLines: 5,
                                  maxLines: 100,
                                  style: const TextStyle(
                                    color: AppColors.backgroundWhite,
                                  ),
                                  textAlign: state.text.isEmpty
                                      ? TextAlign.center
                                      : TextAlign.start,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        gradient: LinearGradient(
          colors: [
            AppColors.main,
            AppColors.backgroundWhite,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: const TextStyle(color: AppColors.backgroundWhite),
        ),
      ),
    );
  }

  List<Widget> _buildDropdown(
    BuildContext context,
    PromptParameters parameter,
    Function(PromptParameters, String?) changeCallback,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0).copyWith(left: 0.0),
        child: Text("${parameterTitles[parameter]}:"),
      ),
      LayoutBuilder(
        builder: (context, constraints) => DropdownMenu<String?>(
          width: constraints.widthConstraints().maxWidth,
          hintText: "Not selected",
          onSelected: (value) => changeCallback(
            parameter,
            value,
          ),
          dropdownMenuEntries: ([
                const DropdownMenuEntry(
                  // ignore: unnecessary_cast
                  value: null as String?,
                  label: "",
                ),
              ]) +
              (parameterOptions[parameter] != null
                  ? List.generate(
                      parameterOptions[parameter]!.length,
                      (i) => DropdownMenuEntry(
                        value: parameterOptions[parameter]![i],
                        label: parameterOptions[parameter]![i],
                      ),
                    )
                  : []),
        ),
      ),
      const SizedBox(height: 8.0),
    ];
  }

  Future<StreamedResponse> _sendPrompt(
    Map<PromptParameters, String?> promptParameters,
    Function(Map<PromptParameters, String>) saveLastParameters,
    CubitMain bloc,
    String apiKey,
  ) async {
    var rand = Random();

    getParameterValue(PromptParameters parameter) {
      String? value = promptParameters[parameter];

      String result = value ??
          parameterOptions[parameter]![
              rand.nextInt(parameterOptions[parameter]!.length)];

      return result;
    }

    String cGender = getParameterValue(PromptParameters.cGender);
    String cRace = getParameterValue(PromptParameters.cRace);
    String cClass = getParameterValue(PromptParameters.cClass);
    String cBackground = getParameterValue(PromptParameters.cBackground);
    String sMood = getParameterValue(PromptParameters.sMood);
    String sLengthValue =
        promptParameters[PromptParameters.sLengthValue] ?? "100";

    saveLastParameters(
      {
        PromptParameters.cGender: cGender,
        PromptParameters.cRace: cRace,
        PromptParameters.cClass: cClass,
        PromptParameters.cBackground: cBackground,
        PromptParameters.sMood: sMood,
        PromptParameters.sLengthValue: sLengthValue,
      },
    );

    String characterDetails = "I want my character to be "
        "a${checkIfStartsWithVowel(cGender) ? "n" : ""} $cGender $cRace $cClass"
        ", who was "
        "a${checkIfStartsWithVowel(cBackground) ? "n" : ""} $cBackground"
        " in the past.";

    String storyDetails = "And I want my story to be $sMood, and "
        "$sLengthValue words long. Also, the story has to have a"
        " reason for my character to start adventuring";

    String completeRequest =
        "Write a short story for my 5th edition DnD character."
        " $characterDetails $storyDetails";

    return await bloc.generateStory(apiKey, completeRequest);
  }

  bool checkIfStartsWithVowel(String text) {
    return text.substring(0, 1).toLowerCase().contains(RegExp(r"[aeiouy]"));
  }

  Future _onGenerateButtonPress(
    BuildContext context,
    CubitMain bloc,
    Map<PromptParameters, String> promptParameters,
    String apiKey,
  ) async {
    if (apiKey.isEmpty) {
      Scaffold.of(context).openDrawer();
      return;
    }

    bloc.clearWarning();
    bloc.changeStoryText("");
    bloc.clearImageUrl();
    bloc.changeLoadingStatus(true);
    StreamedResponse response = await _sendPrompt(
      promptParameters,
      bloc.saveLastParameters,
      bloc,
      apiKey,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      response.stream.listen(
        (data) {
          String body = utf8.decode(data);
          List<String> bodyList = body.split("data:");

          for (int i = 0; i < bodyList.length; i++) {
            String str = bodyList[i].trim();

            if (str == "[DONE]") {
              bloc.changeLoadingStatus(false);
              break;
            }

            dynamic decodedBody;
            if (str.isNotEmpty) {
              try {
                decodedBody = jsonDecode(str);
              } catch (ex) {
                if (i > 0) {
                  try {
                    decodedBody = jsonDecode("${bodyList[i - 1].trim()}$str");
                  } catch (ex) {
                    continue;
                  }
                } else {
                  continue;
                }
              }

              Map delta = decodedBody!["choices"][0]["delta"];

              if (delta.isEmpty) continue;

              bloc.changeStoryText(
                bloc.state.text + delta["content"],
              );
            }
          }
        },
      );
    } else {
      bloc.changeWarning(
        "Something went wrong! (Response code: ${response.statusCode})",
      );
      bloc.changeLoadingStatus(false);
    }
  }

  Future _onPortraitButtonPress(CubitMain bloc, String apiKey) async {
    bloc.clearWarning();
    bloc.clearImageUrl();
    bloc.changeLoadingStatus(true, true);

    Response res0 = await bloc.generatePrompts(
      apiKey,
      bloc.state.text,
    );

    var decodedBody0 = jsonDecode(res0.body);

    String appearance = "";
    List<String> appearanceList =
        decodedBody0["choices"][0]["message"]["content"].split("\n");

    for (String item in appearanceList) {
      String newAppearance = "$appearance\n$item";
      if (newAppearance.length > 800) break;
      appearance = newAppearance;
    }

    Response res = await bloc.generateImage(apiKey, appearance);

    bloc.changeLoadingStatus(false, false);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      var decodedBody = jsonDecode(res.body);

      bloc.changeImageUrl(decodedBody["data"][0]["url"]);
    } else {
      bloc.changeWarning(
        "Something went wrong! (Response code: ${res.statusCode})",
      );
    }
  }

  Drawer _buildMainDrawer(TextEditingController controller) {
    return Drawer(
      child: MainDrawer(controller: controller),
    );
  }
}
