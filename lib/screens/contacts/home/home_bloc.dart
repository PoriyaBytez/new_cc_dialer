import 'package:bloc_pattern/bloc_pattern.dart';
import '../shared/repository/contact_repository.dart';
import 'package:rxdart/rxdart.dart';

import '../app_module.dart';

class HomeBloc extends BlocBase {

  final contactRepository =
  ContactsModule.to.getDependency<ContactRepository>(); //pega a injeção do BLoC

  List<Map> contacts=[];
  Map contact ={};
  bool searchButton = false;
  bool showSearch = false;
  bool favorite = false;

  BehaviorSubject<bool>? _favoriteController;
  BehaviorSubject<List<Map>>? _listContactController;
  BehaviorSubject<Map>? _contactController;
  BehaviorSubject<bool>? _searchButtonController;
  BehaviorSubject<bool>? _searchController;

  HomeBloc() {
    _listContactController = BehaviorSubject.seeded(contacts);
    _contactController = BehaviorSubject.seeded(contact);
    _searchButtonController = BehaviorSubject.seeded(searchButton);
    _searchController = BehaviorSubject.seeded(showSearch);
    _favoriteController = BehaviorSubject.seeded(favorite);
    getListContact();
  }

  ValueStream<bool>? get searchOut => _searchController?.stream;
  ValueStream<bool>? get buttonSearchOut => _searchButtonController?.stream;
  ValueStream<Map>? get contactOut => _contactController?.stream;
  ValueStream<List<Map>>? get listContactOut => _listContactController?.stream;
  ValueStream<bool>? get favoriteOut => _favoriteController?.stream;

  setFavorite(bool favorite) async {
    _favoriteController?.add(favorite);
  }

  updateFavorite(int id, bool favorite) async {
    await contactRepository.update({"favorite": favorite ? 1 : 0}, id);
    _favoriteController?.add(favorite);
  }

  getListContact() async {
    _listContactController?.add(await contactRepository.list());
  }

  getListBySearch(String keywords) async {
    _listContactController?.add(await contactRepository.search(keywords));
  }

  setVisibleButtonSearch(bool visible) {
    _searchButtonController?.add(visible);
  }

  setContact(Map contact) {
    _contactController?.add(contact);
  }

  deleteContact(id) async {
    await contactRepository.delete(id);
    getListContact();
  }

  // dispose will be called automatically by closing its streams
  @override
  void dispose() {

    _searchController?.close();

    super.dispose();
  }

}
