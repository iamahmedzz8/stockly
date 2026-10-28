import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _service;
  late final StreamSubscription<User?> _authSubscription;

  AuthCubit(this._service) : super(AuthInitial()) {
    _authSubscription = _service.authChanges.listen(
      (user) {
        if (user == null) {
          emit(Unauthenticated());
        } else {
          emit(Authenticated(user));
        }
      },
      onError: (_) {
        emit(const AuthFailure('Unable to verify your account.'));
      },
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      await _service.signUp(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_authMessage(e.code)));
    } catch (_) {
      emit(const AuthFailure('An unexpected error occurred.'));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      await _service.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_authMessage(e.code)));
    } catch (_) {
      emit(const AuthFailure('An unexpected error occurred.'));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());

    try {
      await _service.signOut();
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_authMessage(e.code)));
    } catch (_) {
      emit(const AuthFailure('Unable to sign out. Please try again.'));
    }
  }

  String _authMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'weak-password':
        return 'Use a password with at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email address or password is incorrect.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email and password sign-in is not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    return super.close();
  }
}
