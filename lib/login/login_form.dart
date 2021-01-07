import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:PickApp/login/login_bloc.dart';
import 'package:PickApp/login/login_event.dart';
import 'package:PickApp/login/login_state.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void _onSignInWithFacebookButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        SignInWithFacebookButtonPressed(),
      );
    }

    void _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          var screenSize = MediaQuery.of(context).size;
          return Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.12 * screenSize.height),
                  child: Container(
                    height: 0.07 * screenSize.height,
                    width: 0.07 * 3.99 * screenSize.height,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/pickapp_logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.08 * screenSize.height),
                  child: SizedBox(
                    height: 30.0,
                    width: 0.72 * screenSize.width,
                    child: TextFormField(
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Color(0x883D3A3A),
                            width: 0.6,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Color(0x883D3A3A),
                            width: 0.6,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(right: 20.0, top: 14.0),
                        fillColor: Color(0xFFF0F0F0),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.mail_outline,
                          color: Color(0xFF3D3A3A),
                          size: 20.0,
                        ),
                        hintText: 'E-mail',
                        hintStyle: TextStyle(
                          color: Color(0x883D3A3A),
                          fontSize: 14,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 26.0),
                  child: SizedBox(
                    height: 30.0,
                    width: 0.72 * screenSize.width,
                    child: TextFormField(
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Color(0x883D3A3A),
                            width: 0.6,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Color(0x883D3A3A),
                            width: 0.6,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(right: 20.0, top: 14.0),
                        fillColor: Color(0xFFF0F0F0),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF3D3A3A),
                          size: 20.0,
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Color(0x883D3A3A),
                          fontSize: 14,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      controller: _passwordController,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: ButtonTheme(
                    height: 30,
                    minWidth: 0.35 * screenSize.width,
                    child: FlatButton(
                      onPressed: () {
                        if (state is! LoginLoading) {
                          _onLoginButtonPressed();
                        } else {
                          null;
                        }
                      },
                      color: Color(0xFF5EC374),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: SignInButton(Buttons.Facebook, onPressed: () {
                    if (state is! LoginLoading) {
                      _onSignInWithFacebookButtonPressed();
                    }
                  }),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 3.0),
                    child: Align(
                      alignment: FractionalOffset.bottomLeft,
                      child: Text(
                        'PickApp © 2020',
                        style: TextStyle(
                          color: Color(0x88827676),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
