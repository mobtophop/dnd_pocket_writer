import 'package:flutter/material.dart';
import 'package:dnd_pocket_writer/app/pages/main/page_main.dart';
import 'package:dnd_pocket_writer/app/root_cubit/cubit_router.dart';
import 'package:dnd_pocket_writer/app/root_cubit/state_router.dart';

class RootRouterDelegate extends RouterDelegate<StateRouter> {
  RootRouterDelegate(
    GlobalKey<NavigatorState> navigatorKey,
    CubitRouter routerCubit,
  )   : _navigatorKey = navigatorKey,
        _routerCubit = routerCubit;

  final GlobalKey<NavigatorState> _navigatorKey;
  final CubitRouter _routerCubit;

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: [_homePage, ..._extraPages],
        onPopPage: _onPopPageParser,
      );

  bool _onPopPageParser(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) return false;
    popRoute();
    return true;
  }

  Page get _homePage {
    return MaterialPage(child: PageMain());
  }

  List<Page> get _extraPages {
    switch (_routerCubit.state.selectedPage) {
      default:
    }

    return [];
  }

  @override
  Future<bool> popRoute() async {
    switch (_routerCubit.state.selectedPage) {
      default:
        _routerCubit.goToPageMain();
    }
    return true;
  }

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  Future<void> setNewRoutePath(StateRouter configuration) async {}
}
