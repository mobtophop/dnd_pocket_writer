import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dnd_pocket_writer/app/keys.dart';
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

enum PromptParameters {
  cGender,
  cRace,
  cClass,
  cBackground,
  sMood,
  sLengthValue,
}

class PageMain extends StatelessWidget {
  const PageMain({super.key});

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dropdownWidth = screenWidth - 16.0;

    return PageBase(
      child: BlocProvider<CubitMain>(
        create: (context) => CubitMain(),
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
                  dropdownWidth,
                  parameter,
                  bloc.changeParameter,
                ),
              );
            }

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
                      dropdownWidth,
                      PromptParameters.sMood,
                      bloc.changeParameter,
                    ),
                    Row(
                      children: [
                        Text(parameterTitles[PromptParameters.sLengthValue]),
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
                          child: state.isAwaitingResponse
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.main,
                                  ),
                                )
                              : TextButton(
                                  style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateColor.resolveWith(
                                      (_) => AppColors.backgroundWhite
                                          .withOpacity(0.3),
                                    ),
                                    backgroundColor:
                                        MaterialStateColor.resolveWith(
                                      (_) => AppColors.main,
                                    ),
                                    foregroundColor:
                                        MaterialStateColor.resolveWith(
                                      (_) => AppColors.backgroundWhite,
                                    ),
                                  ),
                                  onPressed: () => _onGenerateButtonPress(
                                    bloc,
                                    state.promptParameters,
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
                      Text(
                        state.warning,
                        style: const TextStyle(
                          color: Colors.red, //todo: move to app colors
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: const BorderRadius.all(
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
                                  state.isAwaitingResponse
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                            ),
                                            child: CircularProgressIndicator(
                                              color: AppColors.backgroundWhite,
                                            ),
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () =>
                                              _onGenerateButtonPress(
                                            bloc,
                                            state.lastUsedPromptParameters,
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateColor.resolveWith(
                                              (_) => AppColors.main,
                                            ),
                                            padding: MaterialStateProperty
                                                .resolveWith(
                                              (_) => const EdgeInsets.all(16.0),
                                            ),
                                          ),
                                          child: const Icon(Icons.refresh),
                                        ),
                                  const Expanded(child: SizedBox()),
                                  state.isAwaitingResponse
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                            ),
                                            child: CircularProgressIndicator(
                                              color: AppColors.backgroundWhite,
                                            ),
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () =>
                                              _onPortraitButtonPress(bloc),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateColor.resolveWith(
                                              (_) => AppColors.main,
                                            ),
                                            padding: MaterialStateProperty
                                                .resolveWith(
                                              (_) => const EdgeInsets.all(16.0),
                                            ),
                                          ),
                                          child: const Icon(Icons.draw),
                                        ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                            ],
                            if (state.imageURL.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Image.network(
                                  state.imageURL,
                                  repeat: ImageRepeat.noRepeat,
                                  fit: BoxFit.fill,
                                  loadingBuilder: (context, child, loading) {
                                    return Container(
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
                                          child: loading == null
                                              ? Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    child,
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        8.0,
                                                      ),
                                                      child:
                                                          ImageDownloadButton(
                                                        url: state.imageURL,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : CircularProgressIndicator(
                                                  color:
                                                      AppColors.backgroundWhite,
                                                  backgroundColor: AppColors
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
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            TextField(
                              controller: TextEditingController()
                                ..text = state.text,
                              readOnly: true,
                              decoration: InputDecoration.collapsed(
                                hintText: "Your story will be here...",
                                hintStyle: TextStyle(
                                  color: AppColors.backgroundWhite
                                      .withOpacity(0.7),
                                ),
                              ),
                              cursorColor: AppColors.backgroundWhite,
                              minLines: 5,
                              maxLines: 100,
                              style: TextStyle(
                                color: AppColors.backgroundWhite,
                              ),
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
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
        child: Text(title, style: TextStyle(color: AppColors.backgroundWhite)),
      ),
    );
  }

  List<Widget> _buildDropdown(
    BuildContext context,
    double width,
    PromptParameters parameter,
    Function(PromptParameters, String?) changeCallback,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0).copyWith(left: 0.0),
        child: Text("${parameterTitles[parameter]}:"),
      ),
      DropdownMenu<String?>(
        width: width,
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
      const SizedBox(height: 8.0),
    ];
  }

  Future<StreamedResponse> _sendPrompt(
    Map<PromptParameters, String?> promptParameters,
    Function(Map<PromptParameters, String>) saveLastParameters,
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

    var client = Client();

    Request request = Request(
      "POST",
      Uri.https(
        "api.openai.com",
        "/v1/chat/completions",
      ),
    );

    request.headers.addAll({
      "Content-Type": "application/json",
      "Authorization": "Bearer $OPENAI_API_KEY"
    });

    request.bodyBytes = jsonEncode({
      "model": "gpt-4",
      "messages": [
        {
          "role": "user",
          "content": completeRequest,
        }
      ],
      "temperature": 0.7,
      "stream": true,
    }).codeUnits;

    StreamedResponse response = await client.send(request);

    return response;
  }

  bool checkIfStartsWithVowel(String text) {
    return text.substring(0, 1).toLowerCase().contains(RegExp(r"[aeiouy]"));
  }

  Future _onGenerateButtonPress(
    CubitMain bloc,
    Map<PromptParameters, String> promptParameters,
  ) async {
    bloc.clearWarning();
    bloc.changeStoryText("");
    bloc.clearImageUrl();
    bloc.changeLoadingStatus(true);
    StreamedResponse response = await _sendPrompt(
      promptParameters,
      bloc.saveLastParameters,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      response.stream.listen(
        (data) {
          String body = utf8.decode(data);
          List<String> bodyList = body.split("data:");

          for (String item in bodyList) {
            String str = item.trim();

            if (str == "[DONE]") {
              bloc.changeLoadingStatus(false);
              break;
            }

            if (str.isNotEmpty) {
              var decodedBody = jsonDecode(str);

              Map delta = decodedBody["choices"][0]["delta"];

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

  Future _onPortraitButtonPress(CubitMain bloc) async {
    bloc.clearWarning();
    bloc.clearImageUrl();
    bloc.changeLoadingStatus(true);

    var client = Client();

    Response res0 = await client.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $OPENAI_API_KEY"
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": [
          {
            "role": "user",
            "content":
                "Based on a story, generated by you: \n\"${bloc.state.text}\";\n write a short list of prompts strictly describing the story protagonist's appearance so another AI could generate their portrait. And make it no longer than 800 characters",
            //"Say \"This is a test\"",
          }
        ],
        "temperature": 0.2,
      }),
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

    String prompt =
        "a realistic oil painted long shot portrait in the style of a DnD book illustration of a character, described by these features: $appearance";

    Response res = await client.post(
      Uri.parse("https://api.openai.com/v1/images/generations"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $OPENAI_API_KEY"
      },
      body: jsonEncode({"prompt": prompt, "n": 1, "size": "1024x1024"}),
    );

    bloc.changeLoadingStatus(false);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      var decodedBody = jsonDecode(res.body);

      bloc.changeImageUrl(decodedBody["data"][0]["url"]);
    } else {
      bloc.changeWarning(
        "Something went wrong! (Response code: ${res.statusCode})",
      );
    }
  }

  Future _saveImage(String imageURL) async {}
}
