import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/userdata.dart';
import 'package:ttmm/services/user_api_service.dart';
import 'package:ttmm/shared/constants.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<Profile> {
  Future _future;
  TabController _tabController;

  @override
  void initState() {
    _future = getUserData();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 2);
    _tabController.addListener(_handleTabIndex);
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

// TODO make tab layout center -> profile left -> toGet, right->toGive

  @override
  Widget build(BuildContext context) {
    super.build(context); // need to call super method.

    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Me')),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: 'ToGet',
              ),
              Tab(
                text: 'Got',
              ),
              Tab(
                text: 'Profile',
              ),
              Tab(
                text: 'Given',
              ),
              Tab(
                text: 'ToGive',
              )
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: [
          Center(
            child: Text('ToGet'),
          ),
          Center(
            child: Text('ToGet'),
          ),
          FutureBuilder(
            future: _future,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          child: snapshot.data == null
                              ? CircleAvatar(
                                  radius: 70,
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 60,
                                  ))
                              : CircleAvatar(
                                  radius: 100,
                                  backgroundImage:
                                      Image.network(snapshot.data.profileUrl)
                                          .image),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              snapshot.data.name,
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              snapshot.data.phoneNumber,
                              style: TextStyle(fontSize: 20),
                            ),
                            FlatButton(
                              onPressed: null,
                              child: Text(
                                snapshot.data.upiId != null
                                    ? snapshot.data.upiId
                                    : 'Add Upi Id',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }
            },
          ),
          Center(
            child: Text('ToGet'),
          ),
          Center(
            child: Text('ToGet'),
          ),
        ]));
  }

  Future getUserData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String phoneNumber = preferences.getString(currentPhoneNUmber);

    Response response = await UserApiService.create().getUser(phoneNumber);
    UserData user = UserData.fromJson(response.body);
    return user;
  }

  void _handleTabIndex() {
    setState(() {});
  }
}
