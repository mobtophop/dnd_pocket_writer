import 'package:dnd_pocket_writer/misc/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  TapGestureRecognizer recognizer = TapGestureRecognizer();
  bool isLinkTapped = false;

  @override
  void initState() {
    super.initState();
    recognizer.onTapDown = (_) {
      setState(() {
        isLinkTapped = true;
      });
    };
    recognizer.onTapUp = (_) {
      setState(() {
        isLinkTapped = false;
      });
      launchUrl(Uri.parse("https://openai.com/"));
    };
    recognizer.onTapCancel = () {
      setState(() {
        isLinkTapped = false;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/images/logo_tall.png"),
            const Text("Your OpenAI API key:"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black38,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      hintText: "Put your key here...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  color: Colors.black38,
                  height: 1.5,
                ),
                children: [
                  const WidgetSpan(
                    child: Icon(
                      Icons.info_outline,
                      size: 16.0,
                      color: Colors.black38,
                    ),
                  ),
                  const TextSpan(
                    text: " You need an OpenAI account with access to"
                        " ChatGPT-4 to use this app."
                        " Please, visit the official ",
                  ),
                  TextSpan(
                    text: "OpenAI website",
                    recognizer: recognizer,
                    style: TextStyle(
                      color: isLinkTapped
                          ? AppColors.accentDark40
                          : AppColors.main,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(
                    text: " to create an account and get the key.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
