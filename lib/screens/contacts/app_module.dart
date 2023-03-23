import 'package:bloc_pattern/bloc_pattern.dart';

import './shared/repository/contact_repository.dart';
import 'package:flutter/material.dart';
import './app_widget.dart';
import './app_bloc.dart';
import 'home/home_module.dart';

class ContactsModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => AppBloc()),
      ];

  @override
  List<Dependency> get dependencies => [
        Dependency((i) => ContactRepository()),
      ];

  @override
  Widget get view => HomeModule();

  static Inject get to => Inject<ContactsModule>.of();
}
