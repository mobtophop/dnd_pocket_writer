import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ImageDownloadButton extends StatefulWidget {
  const ImageDownloadButton({super.key, required this.url});

  final String url;

  @override
  State<ImageDownloadButton> createState() => _ImageDownloadButtonState();
}

class _ImageDownloadButtonState extends State<ImageDownloadButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black26,
        shape: BoxShape.circle,
      ),
      child: GestureDetector(
        onTap: () async {
          if (isLoading) return;

          setState(() {
            isLoading = true;
          });

          String downloadsPath = "/storage/emulated/0/Download";
          String filePath =
              "$downloadsPath/dnd_character-${DateTime.now().millisecondsSinceEpoch % 100000000}.png";

          var client = Client();

          Request request = Request(
            "GET",
            Uri.parse(widget.url),
          );

          request.headers.addAll({
            "Content-Type": "application/json",
          });

          StreamedResponse response = await client.send(request);

          File file = File(filePath);

          file.createSync();

          response.stream.listen(
            (data) {
              file.writeAsBytesSync(
                data,
                mode: FileMode.append,
              );
            },
            onDone: () => setState(() {
              isLoading = false;
            }),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 48.0,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.download,
                  size: 48.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
