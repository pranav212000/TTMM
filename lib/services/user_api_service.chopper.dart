// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$UserApiService extends UserApiService {
  _$UserApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = UserApiService;

  @override
  Future<Response<dynamic>> checkUserExists(String phoneNumber) {
    final $url = '/user/checkUser/$phoneNumber';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addUser(Map<String, dynamic> body) {
    final $url = '/user/addUser';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUser(String phoneNumber) {
    final $url = '/user/';
    final $params = <String, dynamic>{'phoneNumber': phoneNumber};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUserOrders(String phoneNumber) {
    final $url = '/user/orders';
    final $params = <String, dynamic>{'phoneNumber': phoneNumber};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> syncContacts(Map<String, dynamic> body) {
    final $url = '/user/syncContacts';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUsers(Map<String, dynamic> body) {
    final $url = '/user/multiple';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUserToGives(String phoneNumber) {
    final $url = '/user/toGive';
    final $params = <String, dynamic>{'phoneNumber': phoneNumber};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUserToGets(String phoneNumber) {
    final $url = '/user/toGet';
    final $params = <String, dynamic>{'phoneNumber': phoneNumber};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getUserGots(String phoneNumber) {
    final $url = '/user/got';
    final $params = <String, dynamic>{'phoneNumber': phoneNumber};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }
}
