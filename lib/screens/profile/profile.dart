import 'package:cached_network_image/cached_network_image.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/given_or_got.dart';
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
  Future _futureToGive;
  Future _futureGot;
  Future _futureGiven;
  // Future _futureToGive;
  Future _futureToGet;
  TabController _tabController;

  @override
  void initState() {
    _futureUserData = getUserData();
    // _futureToGive = getUserToGiveOrGets();
    _futureToGet = getUserToGets();
    _futureToGive = getUserToGives();
    _futureGot = getUserGots();
    _futureGiven = getUserGivens();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 2);
    _tabController.addListener(_handleTabIndex);
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

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
          FutureBuilder(
            future: _futureToGet,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return snapshot.data == null
                    ? Center(
                        child: Text('No To Gives'),
                      )
                    : snapshot.data.length == 0
                        ? Center(
                            child: Text('NO To Gives'),
                          )
                        : ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              ToGiveOrGet toGet = snapshot.data[index];
                              return ListTile(
                                title: Text(toGet.name),
                                subtitle: Text(toGet.eventName),
                                trailing: Text(toGet.amount.toString()),
                              );
                            },
                          );
              }
            },
          ),
          FutureBuilder(
            future: _futureGot,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return snapshot.data == null
                    ? Center(
                        child: Text('Could not get got'),
                      )
                    : snapshot.data.length == 0
                        ? Center(
                            child: Text('NO gots'),
                          )
                        : ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              GivenOrGot got = snapshot.data[index];
                              return ListTile(
                                title: Text(got.name),
                                // TODO add got from and payment mode in UI
                                subtitle: Text(got.eventName),
                                trailing: Text(got.amount.toString()),
                              );
                            },
                          );
              }
            },
          ),
          // Center(
          //   child: Text('ToGet'),
          // ),
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
                          // child: snapshot.data == null
                          //     ? CircleAvatar(
                          //         radius: 70,
                          //         child: Icon(
                          //           Icons.add_a_photo,
                          //           size: 60,
                          //         ))
                          //     : CircleAvatar(
                          //         radius: 100,
                          //         backgroundImage:
                          //             Image.network(snapshot.data.profileUrl)
                          //                 .image),

                          child: CachedNetworkImage(
                            imageUrl: snapshot.data.profileUrl,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 80.0,
                              height: 80.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
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
          FutureBuilder(
            future: _futureGiven,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return snapshot.data == null
                    ? Center(
                        child: Text('Could not get given'),
                      )
                    : snapshot.data.length == 0
                        ? Center(
                            child: Text('NO givens'),
                          )
                        : ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              GivenOrGot given = snapshot.data[index];
                              return ListTile(
                                title: Text(given.name),
                                // TODO add given to and payment mode in UI
                                subtitle: Text(given.eventName),
                                trailing: Text(given.amount.toString()),
                              );
                            },
                          );
              }
            },
          ),

          FutureBuilder(
            future: _futureToGive,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return snapshot.data == null
                    ? Center(
                        child: Text('No To Gives'),
                      )
                    : snapshot.data.length == 0
                        ? Center(
                            child: Text('NO To Gives'),
                          )
                        : ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              ToGiveOrGet toGive = snapshot.data[index];
                              return ListTile(
                                title: Text(toGive.name),
                                subtitle: Text(toGive.eventName),
                                trailing: Text(toGive.amount.toString()),
                              );
                            },
                          );
              }
            },
          ),
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

  Future getUserToGives() async {
    if (_phoneNumber == null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _phoneNumber = preferences.getString(currentPhoneNUmber);
    }

    Response response =
        await UserApiService.create().getUserToGives(_phoneNumber);

    List<ToGiveOrGet> toGives = new List<ToGiveOrGet>();
    for (Map<String, dynamic> event in response.body) {
      var eventToGives = event['toGive'];
      var eventName = event['eventName'];
      var eventId = event['eventId'];
      for (Map<String, dynamic> eventToGive in eventToGives) {
        ToGiveOrGet toGive = ToGiveOrGet.fromJson(eventToGive);
        Response response =
            await UserApiService.create().getUser(toGive.phoneNumber);
        UserData user = UserData.fromJson(response.body);
        toGive.name = user.name;
        toGive.eventName = eventName;
        toGive.eventId = eventId;
        toGives.add(toGive);
      }
    }

    return toGives;
  }

  Future getUserToGets() async {
    if (_phoneNumber == null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _phoneNumber = preferences.getString(currentPhoneNUmber);
    }

    Response response =
        await UserApiService.create().getUserToGets(_phoneNumber);

    List<ToGiveOrGet> toGets = new List<ToGiveOrGet>();
    for (Map<String, dynamic> event in response.body) {
      var eventToGets = event['toGet'];
      var eventName = event['eventName'];
      var eventId = event['eventId'];
      for (Map<String, dynamic> eventToGet in eventToGets) {
        ToGiveOrGet toGet = ToGiveOrGet.fromJson(eventToGet);
        Response response =
            await UserApiService.create().getUser(toGet.phoneNumber);
        UserData user = UserData.fromJson(response.body);
        toGet.name = user.name;
        toGet.eventName = eventName;
        toGet.eventId = eventId;
        toGets.add(toGet);
      }
    }

    return toGets;
  }

  Future getUserGots() async {
    if (_phoneNumber == null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _phoneNumber = preferences.getString(currentPhoneNUmber);
    }

    Response response = await UserApiService.create().getUserGots(_phoneNumber);

    List<GivenOrGot> gots = new List<GivenOrGot>();
    for (Map<String, dynamic> event in response.body) {
      var eventGots = event['got'];
      var eventName = event['eventName'];
      var eventId = event['eventId'];
      for (Map<String, dynamic> eventGot in eventGots) {
        GivenOrGot got = GivenOrGot.fromJson(eventGot);
        Response response =
            await UserApiService.create().getUser(got.phoneNumber);
        UserData user = UserData.fromJson(response.body);
        got.name = user.name;
        got.eventName = eventName;
        got.eventId = eventId;
        gots.add(got);
      }
    }

    return gots;
  }

  Future getUserGivens() async {
    if (_phoneNumber == null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _phoneNumber = preferences.getString(currentPhoneNUmber);
    }

    Response response =
        await UserApiService.create().getUserGivens(_phoneNumber);

    List<GivenOrGot> givens = new List<GivenOrGot>();
    for (Map<String, dynamic> event in response.body) {
      var eventGivens = event['given'];
      var eventName = event['eventName'];
      var eventId = event['eventId'];
      for (Map<String, dynamic> eventGiven in eventGivens) {
        GivenOrGot given = GivenOrGot.fromJson(eventGiven);
        Response response =
            await UserApiService.create().getUser(given.phoneNumber);
        UserData user = UserData.fromJson(response.body);
        given.name = user.name;
        given.eventName = eventName;
        given.eventId = eventId;
        givens.add(given);
      }
    }

    return givens;
  }

  void _handleTabIndex() {
    setState(() {});
  }
}
