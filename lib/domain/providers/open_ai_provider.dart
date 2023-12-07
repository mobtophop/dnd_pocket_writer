import 'package:dnd_pocket_writer/data/api/failure.dart';
import 'package:dnd_pocket_writer/domain/providers/i_repositories/i_open_ai_repository.dart';
import 'package:either_dart/either.dart';
import 'package:http/http.dart';

class OpenAiProvider {
  const OpenAiProvider(IOpenAiRepository repository) : _repository = repository;

  final IOpenAiRepository _repository;

  Future<Either<Failure, StreamedResponse>> generateStory({
    required String apiKey,
    required String prompt,
  }) =>
      _repository.generateStory(
        apiKey: apiKey,
        prompt: prompt,
      );

  Future<Either<Failure, Response>> generatePrompts({
    required String apiKey,
    required String story,
  }) =>
      _repository.generatePrompts(
        apiKey: apiKey,
        story: story,
      );

  Future<Either<Failure, Response>> generateImage({
    required String apiKey,
    required String prompt,
  }) =>
      _repository.generateImage(
        apiKey: apiKey,
        prompt: prompt,
      );
}
