import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dnd_pocket_writer/app/root_cubit/state_router.dart';

class CubitRouter extends Cubit<StateRouter> {
  CubitRouter() : super(const StateRouter());

  void goToPageMain() {
    emit(StateRouter.fromState(state, selectedPage: RouterPage.main));
  }
}
