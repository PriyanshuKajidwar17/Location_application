import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shimmer/shimmer.dart';
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

  Future<void> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id ?? "Unknown Android ID";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId =
            iosInfo.identifierForVendor ?? "Unknown iOS ID";
      }
    } catch (e) {
      deviceId = "Error fetching ID";
    }
  }

  Future<void> handleLocation() async {
    try {
      PermissionStatus status =
      await Permission.location.request();

      if (status.isGranted) {
        await getLocation();
      } else if (status.isDenied) {
        locationStatus = "Permission denied";
      } else if (status.isPermanentlyDenied) {
        locationStatus = "Permission permanently denied";
        await openAppSettings();
      }
    } catch (e) {
      locationStatus = "Error getting location";
    }
  }

  Future<void> getLocation() async {
    try {
      Position position =
      await Geolocator.getCurrentPosition(
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
      body: isLoading
          ? buildShimmer()
          : RefreshIndicator(
        onRefresh: initData,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                Text(
                  "Device Details",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                buildCard(
                  icon: Icons.phone_android,
                  title: "Device ID",
                  value: deviceId,
                  color: Colors.blue,
                ),

                buildCard(
                  icon: Icons.location_on,
                  title: "Latitude",
                  value: latitude,
                  color: Colors.green,
                ),

                buildCard(
                  icon: Icons.explore,
                  title: "Longitude",
                  value: longitude,
                  color: Colors.orange,
                ),

                buildCard(
                  icon: locationStatus ==
                      "Location fetched successfully"
                      ? Icons.check_circle
                      : Icons.error,
                  title: "Status",
                  value: locationStatus,
                  color: locationStatus ==
                      "Location fetched successfully"
                      ? Colors.green
                      : Colors.red,
                ),

                const SizedBox(height: 120),

                Lottie.network(
                  "https://assets2.lottiefiles.com/packages/lf20_tfb3estd.json",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 SHIMMER (Dark mode supported)
  Widget buildShimmer() {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: Shimmer.fromColors(
              baseColor:
              isDark ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor:
              isDark ? Colors.grey[700]! : Colors.grey[100]!,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 🔥 CARD (Dark mode fixed)
  Widget buildCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}