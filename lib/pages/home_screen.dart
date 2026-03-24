import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String deviceId = "Fetching...";
  String latitude = "-";
  String longitude = "-";
  String locationStatus = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await getDeviceId();
    await handleLocation();

    setState(() {
      isLoading = false;
    });
  }

  //Device ID
  Future<void> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id ?? "Unknown Android ID";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "Unknown iOS ID";
      }
    } catch (e) {
      deviceId = "Error fetching ID";
    }
  }

  // Permission Handling
  Future<void> handleLocation() async {
    try {
      PermissionStatus status = await Permission.location.request();

      if (status.isGranted) {
        await getLocation();
      } else if (status.isDenied) {
        locationStatus = "Location permission denied";
      } else if (status.isPermanentlyDenied) {
        locationStatus = "Permission permanently denied";
        await openAppSettings();
      }
    } catch (e) {
      locationStatus = "Error getting location";
    }
  }

  //Get Location
  Future<void> getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
      locationStatus = "Location fetched successfully";
    } catch (e) {
      locationStatus = "Failed to fetch location";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: true,
      ),

      body: isLoading

      // LOTTIE LOADING SCREEN (NEW)
          ? Center(
        child: Lottie.network(
          "https://assets10.lottiefiles.com/packages/lf20_usmfx6bp.json",
          height: 200,
        ),
      )

      //MAIN CONTENT
          : Stack(
        children: [

          // CENTER CONTENT
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Device Information",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Device ID:\n$deviceId",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  Text("Latitude: $latitude"),
                  Text("Longitude: $longitude"),

                  const SizedBox(height: 20),

                  Text(
                    locationStatus,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          //DIFFERENT BOTTOM ANIMATION
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Lottie.network(
                "https://assets2.lottiefiles.com/packages/lf20_tfb3estd.json",
                height: 140,
                repeat: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}