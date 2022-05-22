import 'package:checkpoint/model/UserData.dart';
import 'package:checkpoint/provider/GetProvider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contactsTile.dart';
import 'conversation_model.dart';
import 'message_model.dart';

//
//
class SearchPage extends StatefulWidget {
  final List<ConversationModel>? conversationModel;

  const SearchPage({Key? key, this.conversationModel}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState(this.conversationModel!);
}

class _SearchPageState extends State<SearchPage> {
  _SearchPageState(this.conversationModel);
  List<ConversationModel> conversationModel;
  // data
  TextEditingController searchEditingController = new TextEditingController();
  bool isLoading = true;
  bool hasUserSearched = false;
  //bool _isJoined = false;
  MessageModal message = new MessageModal();
  List<UserData> users = [], temp = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List ids = [];

  // initState()
  @override
  void initState() {
    super.initState();
    searchEditingController.addListener(() {
      users = temp
          .where((element) => element.name!
              .toUpperCase()
              .contains(searchEditingController.text.toUpperCase()))
          .toList();
    });
    init();

    // _getCurrentUserNameAndUid();
  }

  @override
  void dispose() {
    super.dispose();
    searchEditingController.dispose();
    GetProvider().dispose();
  }

  init() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    ids.add(pref.getInt('id'));
    conversationModel.forEach((element) {
      ids.add(element.user!.id);
    });

    Provider.of<GetProvider>(context, listen: false)
        .getUsers(' ')
        .then((value) {
      //print('ddd ${value.length}');
      if (value != null)
        setState(() {
          isLoading = false;
          hasUserSearched = true;
          users = temp = value;
        });
    });
  }

  // functions

  search() async {
    /* if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      Provider.of<GetProvider>(context, listen: false)
          .getUsers(searchEditingController.text)
          .then((value) {
        //print('ddd ${value.length}');
        if (value != null)
          setState(() {
            isLoading = false;
            hasUserSearched = true;
            users = value;
          });
      });
    }*/
  }

  // widgets
  Widget groupList() {
    users = users
        .where((element) => !ids.contains(element.id) && element.name != null)
        .toList();
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ContactTile(
                userId: users[index].id!,
                userName: users[index].name,
                message: message,
                scaffoldKey: _scaffoldKey,
              );
            })
        : Container();
  }

  // building the search page widget
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.white),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          elevation: 0.0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('search'.tr(),
              style: TextStyle(
                  fontSize: 27.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        body: // isLoading ? Container(
            //   child: Center(
            //     child: CircularProgressIndicator(),
            //   ),
            // )
            // :
            Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                color: Colors.grey[200],
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchEditingController,
                        style: TextStyle(
                            // color: Colors.white,
                            ),
                        decoration: InputDecoration(
                            hintText: "Search.users".tr(),
                            hintStyle: TextStyle(
                              //  color: Colors.white,
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          search();
                        },
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(40)),
                            child: Icon(Icons.search, color: Colors.white)))
                  ],
                ),
              ),
              isLoading
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: CircularProgressIndicator()))
                  : Expanded(child: groupList())
            ],
          ),
        ),
      ),
    );
  }
}
