import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presence/src/features/api/api.dart';

import '../src/features/api/common/loginapi.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _storage = const FlutterSecureStorage();

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading()); 

      try {
        final response = await ApiService.login(event.email, event.password);

        if (response != null && response.containsKey('access')) {
          
          await _storage.write(key: 'access', value: response['access']);
          await _storage.write(key: 'refresh', value: response['refresh']);
          await _storage.write(key: 'role', value: response['role']);

          emit(Authenticated());
        } else {
          emit(AuthFailure(response?['error'] ?? "Invalid email or password."));
        }
      } catch (e) {
        emit(AuthFailure("Something went wrong. Please try again later."));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _storage.deleteAll();
      emit(Unauthenticated()); 
    });
  }
}
