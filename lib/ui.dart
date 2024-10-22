import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whether/api.dart';
import 'package:whether/model.dart';
import 'package:whether/ui1.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<WeatherResponse> futureWeather;
  String selectedCity = 'London';
  bool isDarkMode = true; 

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeatherResponse(selectedCity);
  }

  void resetWeatherData() {
    setState(() {
      futureWeather = fetchWeatherResponse(selectedCity);
    });
  }

  String formatTimestamp(int timestamp, int timezone) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
            .add(Duration(seconds: timezone));
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App', style: TextStyle(color: Colors.white)),
        backgroundColor: isDarkMode
            ? const Color.fromARGB(255, 20, 16, 27)
            : Colors.blue, 
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: resetWeatherData,
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value; // Toggle theme mode
              });
            },
            activeColor: Colors.yellow,
            inactiveThumbColor: Colors.blue,
            inactiveTrackColor: Colors.blueAccent,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    const Color.fromARGB(255, 37, 31, 61),
                    const Color.fromARGB(255, 7, 10, 18)
                  ]
                : [
                    Colors.lightBlueAccent.shade100,
                    Colors.lightBlueAccent.shade400,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FutureBuilder<WeatherResponse>(
            future: futureWeather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                );
              } else if (snapshot.hasData) {
                WeatherResponse weather = snapshot.data!;
                double tempCelsius = weather.main.temp - 273.15;
                double feelsLikeCelsius = weather.main.feelsLike - 273.15;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 2),
                        child: DropdownButton<String>(
                          value: selectedCity,
                          items: <String>['London', 'UK']
                              .map<DropdownMenuItem<String>>((String city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(
                                city,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCity = newValue!;
                              if (selectedCity == 'UK') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => uk()),
                                );
                              } else {
                                futureWeather = fetchWeatherResponse(selectedCity);
                              }
                            });
                          },
                          dropdownColor: isDarkMode
                              ? const Color.fromARGB(255, 37, 31, 61)
                              : Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        child: Text(
                          '${tempCelsius.toStringAsFixed(1)}°C',
                          style: TextStyle(fontSize: 48, color: isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                      Image(
                        image: AssetImage('assets/cloud.png'),
                        width: 100,
                        height: 100,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        child: Text(
                          weather.weather[0].description,
                          style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white70 : Colors.black54),
                        ),
                      ),
                      SizedBox(height: 2),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        child: Text(
                          'Feels like: ${feelsLikeCelsius.toStringAsFixed(1)}°C',
                          style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black54),
                        ),
                      ),
                      SizedBox(height: 20),

                      
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            buildWeatherDetailItem(
                              Icons.wind_power,
                              '    Wind:     \n ${weather.wind.speed} m/s',
                              isDarkMode ? Colors.white : Colors.black,
                              isDarkMode ? Colors.transparent :Colors.transparent// Background color for light mode
                            ),
                            SizedBox(width: 20),
                            buildWeatherDetailItem(
                              Icons.cloud,
                              'Cloudiness:\n     ${weather.clouds.all}%',
                              isDarkMode ? Colors.white : Colors.black,
                              isDarkMode ? Colors.transparent :Colors.transparent
                            ),
                            SizedBox(width: 20),
                            buildWeatherDetailItem(
                              Icons.water_drop,
                              ' Humidity: \n      ${weather.main.humidity}%',
                              isDarkMode ? Colors.white : Colors.black,
                              isDarkMode ? Colors.transparent :Colors.transparent
                            ),
                            SizedBox(width: 20),
                            buildWeatherDetailItem(
                              Icons.thermostat,
                              '  Pressure:\n  ${weather.main.pressure} hPa',
                              isDarkMode ? Colors.white : Colors.black,
                              isDarkMode ? Colors.transparent :Colors.transparent
                            ),
                            SizedBox(width: 20),
                            buildWeatherDetailItem(
                              Icons.visibility,
                              '  Visibility: \n  ${weather.visibility} m',
                              isDarkMode ? Colors.white : Colors.black,
                              isDarkMode ? Colors.transparent :Colors.transparent
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                      buildSunriseSunsetRow(weather.sys.sunrise, weather.sys.sunset, weather.timezone),
                    ],
                  ),
                );
              } else {
                return Text('No data available', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildWeatherDetailItem(IconData icon, String text, Color textColor, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: textColor),
          SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: textColor),
          ),
        ],
      ),
    );
  }

  Row buildSunriseSunsetRow(int sunrise, int sunset, int timezone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildSunriseSunsetColumn(
            Icons.wb_sunny,
            'Sunrise: ${formatTimestamp(sunrise, timezone)}',
            Colors.orangeAccent),
        buildSunriseSunsetColumn(
            Icons.nights_stay,
            'Sunset: ${formatTimestamp(sunset, timezone)}',
            const Color.fromARGB(255, 225, 98, 59)),
      ],
    );
  }

  Column buildSunriseSunsetColumn(IconData icon, String time, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.0),
          child: Icon(icon, size: 32, color: color),
        ),
        Container(
          padding: EdgeInsets.all(10.0),
          child: Text(time, style: TextStyle(fontSize: 16, color: color)),
        ),
      ],
    );
  }
}
