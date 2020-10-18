// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$UserApiService extends UserApiService {
  _$UserApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = UserApiService;

  Future<Response> checkUserExists(String phoneNumber) {
    final $url = '/user/checkUser/${phoneNumber}';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> addUser(Map<String, dynamic> body) {
    final $url = '/user/addUser';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getUser(String phoneNumber) {
    final $url = '/user/';
    final Map<String, dynamic> $params = {'phoneNumber': phoneNumber};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getUserOrders(String phoneNumber) {
    final $url = '/user/orders';
    final Map<String, dynamic> $params = {'phoneNumber': phoneNumber};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> syncContacts(Map<String, dynamic> body) {
    final $url = '/user/syncContacts';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getUsers(Map<String, dynamic> body) {
    final $url = '/user/multiple';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getUserToGives(String phoneNumber) {
    final $url = '/user/toGive';
    final Map<String, dynamic> $params = {'phoneNumber': phoneNumber};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getUserToGets(String phoneNumber) {
    final $url = '/user/toGet';
    final Map<String, dynamic> $params = {'phoneNumber': phoneNumber};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }
}
