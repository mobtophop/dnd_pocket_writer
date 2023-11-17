import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dnd_pocket_writer/app/root_cubit/cubit_router.dart';
import 'package:dnd_pocket_writer/app/root_cubit/state_router.dart';
import 'package:dnd_pocket_writer/app/root_router_delegate.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> rootKey = GlobalKey();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => CubitRouter(),
        child: BlocBuilder<CubitRouter, StateRouter>(
          builder: (context, state) {
            var bloc = BlocProvider.of<CubitRouter>(context);

            return SafeArea(
              child: Router(
                routerDelegate: RootRouterDelegate(
                  rootKey,
                  bloc,
                ),
                backButtonDispatcher: RootBackButtonDispatcher(),
              ),
            );
          },
        ),
      ),
    );
  }
}
