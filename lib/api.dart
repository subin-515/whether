

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whether/model.dart'; 

Future<WeatherResponse> fetchWeatherResponse(String s) async {
  final response = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=London,uk&APPID=20995cb9af1d812b7342d6785ea5ddeb'));

  if (response.statusCode == 200) {
    return WeatherResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load weather data');
  }
}
