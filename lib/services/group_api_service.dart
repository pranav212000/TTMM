import 'package:chopper/chopper.dart';

part 'group_api_service.chopper.dart';

@ChopperApi(baseUrl: '/group')
abstract class GroupApiService extends ChopperService {
  // @Get(path: '/{uid}')
  // Future<Response> getUser(@Path('uid') String uid);

  @Post(path: '/addGroup')
  Future<Response> addGroup(@Body() Map<String, dynamic> body);

  @Get(path: '/')
  Future<Response> getGroup(@Query('groupId') String groupId);


  static GroupApiService create() {
    final client = ChopperClient(
        baseUrl: 'https://ttmm-pp.herokuapp.com/api',
        services: [_$GroupApiService()],
        converter: JsonConverter(),
        interceptors: [HttpLoggingInterceptor()]);
    return _$GroupApiService(client);
  }

  // static UserApiService create() {
  //   final client = ChopperClient(
  //       baseUrl: 'https://jsonplaceholder.typicode.com/',
  //       services: [_$PostApiService()],
  //       converter: JsonConverter());

  //   return _$PostApiService(client);
  // }
}
