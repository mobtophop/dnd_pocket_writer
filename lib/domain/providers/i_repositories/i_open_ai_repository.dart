import 'package:dnd_pocket_writer/data/api/failure.dart';
import 'package:either_dart/either.dart';
import 'package:http/http.dart';

abstract class IOpenAiRepository {
  Future<Either<Failure, StreamedResponse>> generateStory({
    required String apiKey,
    required String prompt,
  });

  Future<Either<Failure, Response>> generatePrompts({
    required String apiKey,
    required String story,
  });

  Future<Either<Failure, Response>> generateImage({
    required String apiKey,
    required String prompt,
  });
}
