import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:pop_and_pose/src/constant/api_constants.dart';
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_bloc.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_event.dart';
import 'package:pop_and_pose/src/feature/screen/splash_screen/page/splash_screen.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';

import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterDevice extends StatefulWidget {
  const RegisterDevice({super.key});

  @override
  State<RegisterDevice> createState() => _RegisterDeviceState();
}

class _RegisterDeviceState extends State<RegisterDevice> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _latController = TextEditingController();
   final TextEditingController _baseUrl = TextEditingController();
      final TextEditingController _printerName = TextEditingController();
  String? _deviceInfo;
  String? deviceKey;


  var deviceData = <String, dynamic>{};
  @override
  void initState() {
    super.initState();
    //print('hhh${BaseurlForBackend.redisterDeviceApi}');
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    setState(() {
      _deviceInfo = androidInfo.model;
      deviceKey = androidInfo.device;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String address = _latController.text;
        String baseUrl = _baseUrl.text;
         String printerName = _printerName.text;
      String device = _deviceInfo ?? "Unknown Device";

      try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('base_url', baseUrl);
      await prefs.setString('printer_name', printerName);

        print('device $device device key $deviceKey');
        var response = await http.post(
          Uri.parse(
              'https://pop-pose-backend.vercel.app/api/background/register'),
          body: jsonEncode({
            "device_key": device,
            "device_name": deviceKey,
            "address": address,

            "base_url":baseUrl,
            "printer_name":printerName
          }),
          headers: {
            "Content-Type": "application/json",
          },
        );

        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location submitted successfully!")),
          );
         // context.read<CameraBloc>().add(DiscoverCameraEvent());
           Get.to(
                () => SplashScreenPage(),
              );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to submit location!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        
         Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'images/background.png',
          fit: BoxFit.cover,
        ),
        SafeArea(
          child: Center(
            child: Container(
              width: 700,
              height: MediaQuery.of(context).size.height * 0.6,
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 45.0, left: 20.0, right: 20.0, bottom: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Texts(
                        texts: 'Register Device',
                        fontSize: 28,
                        color: Color.fromRGBO(21, 20, 38, 1),
                        fontWeight: FontWeight.w800,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        cursorColor: AppColor.kAppColor,
                        controller: _latController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Address",
                          labelStyle:
                              const TextStyle(color: AppColor.textColorBlack),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColor.kAppColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColor.kAppColor,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColor.kAppColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        cursorColor: AppColor.kAppColor,
                        controller: _baseUrl,
                      
                        decoration: InputDecoration(
                          labelText: "Base Url",
                          labelStyle:
                              const TextStyle(color: AppColor.textColorBlack),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColor.kAppColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColor.kAppColor,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColor.kAppColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter base url";
                          }
                          return null;
                        },
                      ),


 const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        cursorColor: AppColor.kAppColor,
                        controller: _printerName,
                      
                        decoration: InputDecoration(
                          labelText: "Print Name",
                          labelStyle:
                              const TextStyle(color: AppColor.textColorBlack),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColor.kAppColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColor.kAppColor,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: AppColor.kAppColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter printer name";
                          }
                          return null;
                        },
                      ),                      const SizedBox(height: 30),
                      AppBtn(
                        onTap: _submitForm,
                        width: 300,
                        child: const Texts(
                          texts: 'Register',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textColorWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    
    )
    );
  }
}
