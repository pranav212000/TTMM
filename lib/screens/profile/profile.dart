import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/toGiveOrGet.dart';
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
  String _phoneNumber;
  Future _futureUserData;
  // Future _futureToGive;
  // Future _futureToGet;
  TabController _tabController;

  @override
  void initState() {
    _futureUserData = getUserData();
    // _futureToGive = getUserToGiveOrGets();
    // _futureToGet = getUserToGets();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 2);
    _tabController.addListener(_handleTabIndex);
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

// TODO make tab layout center -> profile left -> toGet, right->toGiveOrGetToGiveOrGet

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
                text: 'ToGiveOrGet',
              )
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: [
          // FutureBuilder(
          //   future: _futureToGet,
          //   builder: (BuildContext context, AsyncSnapshot snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     } else {
          //       return ListView.builder(
          //         itemCount: snapshot.data.length,
          //         itemBuilder: (BuildContext context, int index) {
          //           ToGiveOrGet toGive = snapshot.data[index];
          //           return ListTile(
          //             title: Text(toGive.eventName),
          //             trailing: Text(toGive.amount.toString()),
          //           );
          //         },
          //       );
          //     }
          //   },
          // ),
           Center(
            child: Text('ToGet'),
          ),
          Center(
            child: Text('ToGet'),
          ),
          FutureBuilder(
            future: _futureUserData,
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
          // FutureBuilder(
          //   future: _futureToGive,
          //   builder: (BuildContext context, AsyncSnapshot snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     } else {
          //       if(snapshot.data == null)
          //       return Center(child: Text('No ToGets yet!'),);
          //       else
          //       return ListView.builder(
          //         itemCount: snapshot.data.length,
          //         itemBuilder: (BuildContext context, int index) {
          //           ToGiveOrGet toGive = snapshot.data[index];
          //           return ListTile(
          //             title: Text(toGive.eventName),
          //             trailing: Text(toGive.amount.toString()),
          //           );
          //         },
          //       );
          //     }
          //   },
          // ),
          Center(child: Text('ToGive/get'))
        ]));
  }

  Future getUserData() async {
    if (_phoneNumber == null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _phoneNumber = preferences.getString(currentPhoneNUmber);
    }
    Response response = await UserApiService.create().getUser(_phoneNumber);
    UserData user = UserData.fromJson(response.body);
    return user;
  }

// FIXME 
  Future getUserToGiveOrGets() async {
    if (_phoneNumber == null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _phoneNumber = preferences.getString(currentPhoneNUmber);
    }

    // Response response =
    //     await UserApiService.create().getUserToGives(_phoneNumber);

    // List<ToGiveOrGet> toGives = new List<ToGiveOrGet>();
    // for (Map<String, dynamic> event in response.body) {
    //   var eventToGives = event['toGive'];
    //   var eventName = event['eventName'];
    //   var eventId = event['eventId'];
    //   for (Map<String, dynamic> eventToGive in eventToGives) {
    //     ToGiveOrGet toGive = ToGiveOrGet.fromJson(eventToGive);
    //     toGive.eventName = eventName;
    //     toGive.eventId = eventId;
    //     toGives.add(toGive);
    //   }
    // }

    return null;
  }

// FIXME toGets
  // Future getUserToGets() async {
  //   if (_phoneNumber == null) {
  //     SharedPreferences preferences = await SharedPreferences.getInstance();
  //     _phoneNumber = preferences.getString(currentPhoneNUmber);
  //   }

  //   Response response =
  //       await UserApiService.create().getUserToGets(_phoneNumber);

  //   List<ToGiveOrGet> toGets = new List<ToGiveOrGet>();
  //   for (Map<String, dynamic> event in response.body) {
  //     var eventToGets = event['toGet'];
  //     var eventName = event['eventName'];
  //     var eventId = event['eventId'];
  //     for (Map<String, dynamic> eventToGet in eventToGets) {
  //       ToGiveOrGet toGet = ToGiveOrGet.fromJson(eventToGet);
  //       toGet.eventName = eventName;
  //       toGet.eventId = eventId;
  //       toGets.add(toGet);
  //     }
  //   }

  //   return toGets;
  // }

  void _handleTabIndex() {
    setState(() {});
  }
}
