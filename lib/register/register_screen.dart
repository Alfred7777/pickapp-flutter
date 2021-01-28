import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmPasswordController;

  RegisterBloc _registerBloc;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _registerBloc = RegisterBloc();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _registerBloc.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (_isFormVaild()) {
      _registerBloc.add(
        CreateAccountButtonPressed(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  String _validateEmail(String name) {
    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%±]+@[A-Za-z0-9.-]+.[A-Za-z]{2,4}$',
    );
    if (name.isEmpty) {
      return 'Email is required!';
    }
    if (!emailRegex.hasMatch(name)) {
      return 'Email isn\'t vaild.';
    }
    return null;
  }

  String _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be longer than 8 characters!';
    }
    if (password.length > 24) {
      return 'Password can\'t have more than 24 characters!';
    }
    return null;
  }

  String _validateConfirmPassword(String password) {
    if (_passwordController.text != password) {
      return 'Passwords don\'t match!';
    }
    return null;
  }

  bool _isFormVaild() {
    if (_formKey.currentState == null) {
      return true;
    } else {
      if (_formKey.currentState.validate()) {
        return true;
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideScreenTopBar(
        title: 'Create Account',
      ),
      body: BlocListener<RegisterBloc, RegisterState>(
          bloc: _registerBloc,
          listener: (context, state) {
            if (state is RegisterFailure) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is RegisterSuccess) {
              Navigator.pop(context, [state.message]);
            }
          },
          child: BlocBuilder<RegisterBloc, RegisterState>(
            bloc: _registerBloc,
            builder: (context, state) {
              if (state is RegisterLoading) {
                return LoadingScreen();
              }
              return SafeArea(
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 32,
                        bottom: 12,
                      ),
                      child: Text(
                        'Create account',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 32.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 32,
                            ),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                errorStyle: TextStyle(color: Colors.red),
                                labelText: 'Email',
                              ),
                              validator: _validateEmail,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 32,
                            ),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _passwordController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                errorStyle: TextStyle(color: Colors.red),
                                labelText: 'Password',
                              ),
                              validator: _validatePassword,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 32,
                            ),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _confirmPasswordController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                errorStyle: TextStyle(color: Colors.red),
                                labelText: 'Confirm Password',
                              ),
                              validator: _validateConfirmPassword,
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: ButtonTheme(
                                minWidth: 140,
                                height: 36,
                                child: RaisedButton(
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  onPressed: _createAccount,
                                  color: Colors.green,
                                  elevation: 2.0,
                                  autofocus: false,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }
}
