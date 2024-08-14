import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:todo/provider/auth_provider.dart';

import '../util/color_const.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;

  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: TextField(
                  keyboardType: TextInputType.phone,
                  controller: otpController,
                  decoration: InputDecoration(
                      hintText: 'Enter OTP', border: InputBorder.none),
                ),
              ),
            ),
            SizedBox(
              height: 14,
            ),
            InkWell(
              onTap: () async {
                CustomAuthProvider provider =
                    Provider.of<CustomAuthProvider>(context, listen: false);
                await provider.signInWithOtp(
                    widget.verificationId, toStringShort());
              },
              child: Container(
                child: Center(
                    child: Text(
                  'Continoue',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )),
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  color: ColorConst.buttonColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
