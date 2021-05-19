import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:map_app/LocationProvider.dart';
import 'main.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  final locationService = getIt.get<LocationProvider>();
  bool mapLoading = true;
  String _mapStyle;
  LatLng center;
  String pickUpLocationTag = "Selecione uma Localização";
  LatLng pickupLocation;
  BitmapDescriptor pinLocationIcon;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  String address = "Digite um endereço";
  LatLng latLng;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    _getUserLocation();
  }

  void _onMapCreated(GoogleMapController myController) {
    _controller.complete(myController);
    mapLoading = false;
    myController.setMapStyle(_mapStyle);
  }

  void _getUserLocation() async {
    Position position = await locationService.provideCurrentLocation();
    Address _address = await locationService.getLocationName();
    setState(() {
      address = _address.addressLine.replaceAll(" Brazil", "");
      center = LatLng(position.latitude, position.longitude);
    });
  }

  void getInputValue() async {
    Address position = await locationService.getInputCoordinate(textController.text);
    setState(() {
      address = position.addressLine.replaceAll(" Brazil", "");
      textController.clear();
    });
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(position.coordinates.latitude, position.coordinates.longitude),
        zoom: 15.0,
      ),
    ));
    FocusScope.of(context).unfocus();
  }

  void moveMarker(CameraPosition position){
    setState(() {
      latLng = LatLng(position.target.latitude, position.target.longitude);
    });
  }

  void moveStopMarker() async {
    Address position = await locationService.getLocationFromLatLng(latLng);
    setState(() {
      address = position.addressLine.replaceAll(", Brazil", "");
    });
  }

  void requestWash() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wash App"),
        centerTitle: true,
        backgroundColor: HexColor("#89B6C7"),
      ),
      body: (center != null) ?
      Stack(
        children: <Widget>[
          AnimatedOpacity(
            opacity: mapLoading ? 1 : 1,
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 1000),
            child: Container(
              color: Colors.white24,
              child: GoogleMap(
                onCameraMove: moveMarker,
                myLocationEnabled: true,
                onMapCreated: _onMapCreated,
                onCameraIdle: moveStopMarker,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: center,
                  zoom: 15.0,
                ),
                mapType: MapType.normal,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(20),
            color: Colors.white,
            child: Form(
              key: _formKey,
              child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      onFieldSubmitted: (term) {
                        getInputValue();
                      },
                      cursorColor: HexColor("#89B6C7"),
                      controller: textController, 
                      decoration: InputDecoration(
                        hintText: 'Insira seu endereço',
                        filled: true,
                        contentPadding: EdgeInsets.only(top: 16, left: 8),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        suffixIcon: Container(
                          width: 60,
                          height: 40,
                          margin: EdgeInsets.all(4),
                          child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(HexColor("#89B6C7"))),
                          child: Icon(
                              Icons.search,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: getInputValue
                          ),
                        ),
                      )
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Text(address, style: TextStyle(color: Colors.grey.withOpacity(0.9)))
                    )
                  ]
                )
              )
            )
          ),          
          Align(
            alignment: Alignment.center,
            child: Transform.translate(offset: Offset(0,-20),
              child: Icon(Icons.location_on,size: 50, color:  HexColor("#89B6C7"))
            )
          )
        ],
      ) :
      Container(
        color: Color(0x588ca4),
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width,
        height: 55,
        margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: ElevatedButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(HexColor("#89B6C7"))),
          child: Text("Solicitar Lavagem", style: TextStyle(color: Colors.white, fontSize: 18)),
          onPressed: requestWash
        )
      )
    );
  }
}