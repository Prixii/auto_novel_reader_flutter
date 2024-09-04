part of 'service.dart';

@ChopperApi(baseUrl: '/auth')
abstract class AuthService extends ChopperService {
  @Post(path: '/sign-in')
  Future<Response> postSignIn(@Body() JsonBody body);

  @Post(path: '/sign-up')
  Future<Response> postSignUp(@Body() JsonBody body);

  @Get(path: '/renew')
  Future<Response> _getRenew();
  Future<Response?> getRenew() => tokenRequest(() => _getRenew());

  @Post(path: '/verify-email')
  Future<Response> postVerifyEmail();

  @Post(path: '/reset-password-email')
  Future<Response> postResetPasswordEmail();

  @Post(path: '/reset-password')
  Future<Response> postResetPassword();

  static AuthService create([ChopperClient? client]) => _$AuthService(client);
}
