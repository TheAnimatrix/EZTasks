
import 'package:dio/dio.dart';
import 'package:tasks/auth/AuthService.dart';

class TokenInterceptor extends InterceptorsWrapper{
  final Dio dio;

  TokenInterceptor({this.dio});

  @override
  Future onRequest(RequestOptions options) async{
    print("Interceptor called");
    dio.interceptors.requestLock.lock();
    String token = await AuthService().getValidToken();
    options.headers["token"]=token;
    dio.interceptors.requestLock.unlock();
    return super.onRequest(options);
  }
  
}