import 'package:dnd_pocket_writer/data/api/open_ai_api.dart';
import 'package:dnd_pocket_writer/data/impl_repositories/impl_open_ai_repository.dart';
import 'package:dnd_pocket_writer/domain/providers/open_ai_provider.dart';
import 'package:get_it/get_it.dart';

abstract class GetItSetup {
  static void setup() {
    GetIt.I.registerSingleton(
      OpenAiProvider(
        ImplOpenAiRepository(
          OpenAiApi(),
        ),
      ),
    );
  }
}
