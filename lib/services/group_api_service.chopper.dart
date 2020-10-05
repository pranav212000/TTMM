// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$GroupApiService extends GroupApiService {
  _$GroupApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = GroupApiService;

  Future<Response> addGroup(Map<String, dynamic> body) {
    final $url = '/group/addGroup';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getGroup(String groupId) {
    final $url = '/group/';
    final Map<String, dynamic> $params = {'groupId': groupId};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getGroups(Map<String, dynamic> body) {
    final $url = '/group/multiple';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getEvents(String orderId) {
    final $url = '/group/${orderId}/events';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
