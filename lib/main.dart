import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  String mapStyle = '';
  Set<Marker> _markers = {}; // لتخزين العلامات
  Set<Polyline> _polylines = {}; // لتخزين الخطوط

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _requestLocationPermission();
    _addStaticPolyline(); // إضافة Polyline ثابتة عند بدء التطبيق
  }

  // طلب إذن الموقع
  Future<void> _requestLocationPermission() async {
    await Geolocator.requestPermission();
  }

  // تحريك الكاميرا إلى القاهرة
  void _moveToCairo() async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      const CameraPosition(
        target: LatLng(30.05817693107637, 31.25882302787056),
        zoom: 12,
      ),
    ));
  }

  // تحريك الكاميرا إلى موقع ثابت للمستخدم
  Future<void> _goToMyLocation() async {
    double latitude = 28.97038753005306;
    double longitude = 30.915930613034053;

    print("my fixed position is: $latitude, $longitude");

    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
      ),
    );
  }

  // تحميل تنسيق الخريطة من ملف JSON
  void _loadMapStyle() async {
    final String style = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    setState(() {
      mapStyle = style;
    });
  }

  // إضافة Marker عند الضغط على الخريطة
  void _addMarker(LatLng position, String title) {
    final String markerId = 'marker_${_markers.length}';
    final Marker marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  // إضافة Polyline ثابتة
  void _addStaticPolyline() {
    final Polyline polyline = Polyline(
      polylineId: PolylineId('static_route'),
      color: Colors.blue,
      width: 5,
      points: [
        LatLng(28.97471576253152, 30.913354513410084), // نقطة البداية
        LatLng(30.05817693107637, 31.25882302787056), // نقطة النهاية
      ],
    );

    setState(() {
      _polylines.add(polyline);
    });
  }

  // إضافة Polyline ديناميكية (حسب الموقع الذي يضغط عليه المستخدم)
  void _addDynamicPolyline(LatLng start, LatLng end) {
    final Polyline polyline = Polyline(
      polylineId: PolylineId('dynamic_route'),
      color: Colors.red,
      width: 5,
      points: [start, end],
    );

    setState(() {
      _polylines.add(polyline);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        style: mapStyle,
        initialCameraPosition: const CameraPosition(
          target: LatLng(28.97471576253152, 30.913354513410084),
          zoom: 14,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        markers: _markers, // تمرير العلامات للخريطة
        polylines: _polylines, // تمرير الـ Polylines للخريطة
        onTap: (LatLng position) {
          _addMarker(position, 'علامة جديدة'); // إضافة علامة عند الضغط
          // إضافة Polyline ديناميكي بين نقطتين
          if (_markers.length > 1) {
            var start = _markers.first.position;
            var end = position;
            _addDynamicPolyline(start, end);
          }
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "toCairo",
            onPressed: _moveToCairo,
            child: const Icon(Icons.location_city),
            tooltip: "Move to Cairo",
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "toMyLocation",
            onPressed: _goToMyLocation,
            child: const Icon(Icons.my_location),
            tooltip: "Go to My Location",
          ),
        ],
      ),
    );
  }
}
