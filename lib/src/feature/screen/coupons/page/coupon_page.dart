import 'package:flutter/material.dart';
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';

class CouponPage extends StatefulWidget {
  final String frameId;
  final String noOfCopiesId;
  final int totalInstance;

  const CouponPage({
    super.key,
    required this.frameId,
    required this.noOfCopiesId,
    required this.totalInstance,
  });

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _latController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'images/background.png',
          fit: BoxFit.cover,
        ),
        SafeArea(
          child: Center(
            child: 
            Container(
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
              child:
               Padding(
                padding: const EdgeInsets.only(
                    top: 45.0, left: 20.0, right: 20.0, bottom: 20.0),
                child:
                
                 Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Texts(
                        texts: 'Coupon Code',
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
                            return "Please enter Coupon Code";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(

                        height: 30,
                      ),
                      const SizedBox(height: 30),
                      AppBtn(
                        onTap: () {},
                        width: 300,
                        child: const Texts(
                          texts: 'Apply',
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
    ));
  }
}
