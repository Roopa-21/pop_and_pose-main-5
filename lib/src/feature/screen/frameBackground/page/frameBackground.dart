import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/feature/screen/num_of_copies/widget/btn.dart';
import 'package:pop_and_pose/src/feature/screen/select_photo/page/select_photos.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:pop_and_pose/src/utils/getDeviceInfo.dart';
import 'package:printing/printing.dart';
//import 'package:printing/printing.dart';

class Framebackground extends StatefulWidget {
  final String userId1;
  const Framebackground({super.key, required this.userId1});

  @override
  State<Framebackground> createState() => _FramebackgroundState();
}

class _FramebackgroundState extends State<Framebackground> {
  List<String> imageUrls = [];
  int rows = 3;
  int columns = 2;
  double padding = 10.0;
  double horizontalGap = 10.0;
  double verticalGap = 10.0;
  String frameImage = '';
  String userId1 = '';
  String? backgroundImageUrl;
  String? deviceModel;
  String imageShape = 'circle';
  String? framebackdropId;
  List<dynamic> backdropImages = [];
  String? selectedBackdrop;
  List<double>? selectedFilter;
  Map<int, double> _rotationAngles = {};
  Map<int, double> _scales = {};

  final Map<String, List<double>> filters = {
    "Normal": [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
    "Sepia": [
      0.39,
      0.769,
      0.189,
      0.0,
      0.0,
      0.349,
      0.686,
      0.168,
      0.0,
      0.0,
      0.272,
      0.534,
      0.131,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0
    ],
    "Greyscale": [
      0.2126,
      0.7152,
      0.0722,
      0.0,
      0.0,
      0.2126,
      0.7152,
      0.0722,
      0.0,
      0.0,
      0.2126,
      0.7152,
      0.0722,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0
    ],
    "Vintage": [
      0.9,
      0.5,
      0.1,
      0.0,
      0.0,
      0.3,
      0.8,
      0.1,
      0.0,
      0.0,
      0.2,
      0.3,
      0.5,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0
    ],
  };
  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    fetchUserData();

    
  }

  Future<void> _getDeviceInfo() async {
    List<String> deviceInfo = await Getdeviceinformation().getDevice();

    setState(() {
      deviceModel = deviceInfo[0];
    });

    if (deviceModel != null) {
      String? imageUrl =
          await Getdeviceinformation().fetchBackgroundImage(deviceModel!);
      setState(() {
        backgroundImageUrl = imageUrl;
      });
    }
  }

  void toggleSelection(String imageUrl) {
    setState(() {
      if (selectedBackdrop == imageUrl) {
        selectedBackdrop = null; // Deselect image
      } else {
        selectedBackdrop = imageUrl; // Select new image
      }
    });
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse(
        'https://pop-pose-backend.vercel.app/api/user/getDetailsByUserId/${widget.userId1}');

    try {
      final response = await http.get(url);
      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        // Safely parsing the data with null checks
        setState(() {
          imageUrls = List<String>.from(user['image_captured'] ?? []);
          final frameSelection = user['frame_Selection'];

          rows = frameSelection['rows'] ?? 3;
          columns = frameSelection['columns'] ?? 2;
          padding = (frameSelection['padding'] ?? 10).toDouble();
          horizontalGap = (frameSelection['horizontal_gap'] ?? 10).toDouble();
          verticalGap = (frameSelection['vertical_gap'] ?? 10).toDouble();
          frameImage = frameSelection['image'] ?? '';
          imageShape = frameSelection['shapes'] ?? 'circle';
          framebackdropId = frameSelection['_id'] ?? '';
          backdropImages = frameSelection['background'] ?? [];
        });

        // print('Rows: $rows');
        // print('Columns: $columns');
        // print('Padding: $padding');
        // print('Horizontal Gap: $horizontalGap');
        // print('Vertical Gap: $verticalGap');
        // print('Frame Image: $frameImage');
        // print('Image Shape: $imageShape');
        // print('Image URLs: $imageUrls');
      } else {
        print('Failed to load user data. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }


  final GlobalKey repaintBoundaryKey = GlobalKey();
  Future<void> printGridView() async {
    final gridImage = await _captureGridView(); // Capture the grid as an image

    final document = pw.Document(); // Create a PDF document

    final image =
        pw.MemoryImage(gridImage); // Convert image bytes to MemoryImage

    document.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(image), // Add the image to the PDF document
        );
      },
    ));

    // Print the document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => document.save(),
    );
  }

  // Function to capture the GridView as an image
  Future<Uint8List> _captureGridView() async {
    try {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      print("Error capturing the GridView: $e");
      return Uint8List(0);
    }
  }

  Future<void> deleteImages(String userId) async {
    final url = Uri.parse(
        "https://pop-pose-backend.vercel.app/api/user/deleteImagesByUserId/${widget.userId1}");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Images deleted successfully.');
      } else {
        print('Failed to delete images. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting images: $e');
    }
  }

  Widget buildImageShape(String shape, String imageUrl, int index) {
    Widget transformedImage = Transform.rotate(
      angle: _rotationAngles[index] ?? 0.0,
      child: Transform.scale(
        scale: _scales[index] ?? 1.0,
        child: Image.network(
          imageUrl,
          fit: BoxFit.fill,
        ),
      ),
    );

    switch (shape.toLowerCase()) {
      case 'circle':
        return ClipOval(child: transformedImage);

      case 'rectangle':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: transformedImage,
        );

      default:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: transformedImage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final imageSize = screenWidth * (screenWidth > 600 ? 0.3 : 0.5);

        return Stack(
          children: [
            backgroundImageUrl != null
                ? Image.network(
                    backgroundImageUrl!,
                    // fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : const Center(child: CircularProgressIndicator()),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    width: 700,
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
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: backdropImages.length,
                                itemBuilder: (context, index) {
                                  final imageUrl = backdropImages[index];
                                  print('bddd${backdropImages.length}');
                                  return GestureDetector(
                                    onTap: () => toggleSelection(imageUrl),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            backdropImages[index],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if (selectedBackdrop == imageUrl)
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Icon(Icons.check_circle,
                                                color: Colors.green, size: 24),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: filters.keys.length,
                                itemBuilder: (context, index) {
                                  String filterName =
                                      filters.keys.elementAt(index);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedFilter = selectedFilter ==
                                                filters[filterName]
                                            ? null
                                            : filters[filterName];
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                        border: selectedFilter ==
                                                filters[filterName]
                                            ? Border.all(
                                                color: Colors.blue, width: 2)
                                            : null,
                                      ),
                                      child: Text(
                                        filterName,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )),
                        Expanded(
                          child: RepaintBoundary(
                            key: repaintBoundaryKey,
                            child: Padding(
                              padding: EdgeInsets.all(padding),
                              child: ColorFiltered(
                                colorFilter: selectedFilter != null
                                    ? ColorFilter.matrix(selectedFilter!)
                                    : const ColorFilter.mode(
                                        Colors.transparent, BlendMode.multiply),
                                child: Container(
                                  height: 480,
                                  decoration: BoxDecoration(
                                    image: selectedBackdrop != null
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(selectedBackdrop!),
                                            fit: BoxFit.cover,
                                          )
                                        : DecorationImage(
                                            image: AssetImage(
                                                'images/background.png'),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  child: GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                        vertical: verticalGap,
                                        horizontal: horizontalGap),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: horizontalGap,
                                      mainAxisSpacing: verticalGap,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: imageUrls.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onScaleUpdate: (details) {
                                          setState(() {
                                            _scales[index] =
                                                details.scale.clamp(0.5, 3.0);
                                            _rotationAngles[index] =
                                                details.rotation;
                                          });
                                        },
                                        child: buildImageShape(imageShape,
                                            imageUrls[index], index),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Btn(
                          onTap: () {
                            deleteImages(widget.userId1);
                            Get.offAll(() => PhotoSelector(
                                  userId: widget.userId1,
                                ));
                          },
                          width: 150,
                          child: const Texts(
                            texts: 'Back',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kAppColor,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 150,
                            minWidth: 120,
                          ),
                          child: AppBtn(
                            onTap: () {
                              printGridView();
                            },
                            child: const Texts(
                              texts: 'Print',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
