import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider {
  Position position;
  int distance;
  LocationAccuracy locationAccuracy;

  LocationProvider({this.locationAccuracy=LocationAccuracy.high,this.distance=10});

  Future<Position> provideLastKnownLocation() async {
    return await Geolocator.getLastKnownPosition();
  }

  Future<Position> provideCurrentLocation() async {
    Position _position = await Geolocator.getCurrentPosition();
    if (_position == null) {
      _position = await provideLastKnownLocation();
    }
    position = _position;
    return _position;
  }

  Future<bool> checkForLocationPermission() async {
    bool permission;
    await Geolocator.requestPermission().then((value) => {
      if(value == LocationPermission.denied){
        permission = false
      }else if(value == LocationPermission.deniedForever){
        permission = false
      }else{
        permission = true
      }
    });
    return permission;
  }

  Future<Address> getLocationName() async {
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    return first;
  }

  Future<Address> getInputCoordinate(String address) async{
    var coordinates = await Geocoder.local.findAddressesFromQuery(address);
    return coordinates[0];
  }

  Future<Address> getLocationFromLatLng(LatLng latLng) async{
    var coordinates = 
      await Geocoder.local.findAddressesFromCoordinates(Coordinates(latLng.latitude, latLng.longitude));
    return coordinates[0];
  }
}