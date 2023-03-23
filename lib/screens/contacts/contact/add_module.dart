

import 'package:bloc_pattern/bloc_pattern.dart';

import './add_bloc.dart';
import 'package:flutter/material.dart';

class ContactsModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => AddBloc()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => Container();

  static Inject get to => Inject<ContactsModule>.of();
}
