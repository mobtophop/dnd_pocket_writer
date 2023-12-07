import 'package:dnd_pocket_writer/data/api/failure.dart';
import 'package:dnd_pocket_writer/data/api/open_ai_api.dart';
import 'package:dnd_pocket_writer/domain/providers/i_repositories/i_open_ai_repository.dart';
import 'package:either_dart/either.dart';
import 'package:http/http.dart';

class ImplOpenAiRepository extends IOpenAiRepository {
  ImplOpenAiRepository(OpenAiApi api) : _api = api;
  final OpenAiApi _api;

  @override
  Future<Either<Failure, Response>> generateImage({
    required String apiKey,
    required String prompt,
  }) async {
    return await _api.generateImage(
      apiKey: apiKey,
      prompt: prompt,
    );
  }

  @override
  Future<Either<Failure, Response>> generatePrompts({
    required String apiKey,
    required String story,
  }) async {
    return await _api.generatePrompts(
      apiKey: apiKey,
      story: story,
    );
  }

  @override
  Future<Either<Failure, StreamedResponse>> generateStory({
    required String apiKey,
    required String prompt,
  }) async {
    return await _api.generateStory(
      apiKey: apiKey,
      prompt: prompt,
    );
  }
}
