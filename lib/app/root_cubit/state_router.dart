import 'package:equatable/equatable.dart';

enum RouterPage {
  main,
}

class StateRouter extends Equatable {
  const StateRouter({RouterPage? selectedPage})
      : _selectedPage = RouterPage.main,
        super();

  StateRouter.fromState(
    StateRouter state, {
    RouterPage? selectedPage,
  }) : _selectedPage = selectedPage ?? state._selectedPage;

  final RouterPage _selectedPage;

  RouterPage get selectedPage => _selectedPage;

  @override
  List<Object?> get props => [
        _selectedPage,
      ];
}
