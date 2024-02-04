import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/secretkeys.dart';
import 'hourly_forecast_item.dart';
import 'additional_info_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // double temp = 0;
  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Dar es salaam';
      String countryabbrev = 'tz';
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,$countryabbrev&APPID=$openweatherAPIKeys'));
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'unexpected error occured!';
      }
      // setState(() {
      //   temp = data['list'][0]['main']['temp'];
      // });
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather app',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final data = snapshot.data!;
            final currentTemp =
                (data['list'][0]['main']['temp'] - 273.15).toStringAsFixed(2);
            final currentSky = data['list'][0]['weather'][0]['main'];
            final currentPressure = data['list'][0]['main']['pressure'];
            final currentWindSpeed = data['list'][0]['wind']['speed'];
            final currentHumidity = data['list'][0]['main']['humidity'];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 3,
                              sigmaY: 3,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Center(
                                    child: Text(
                                      '$currentTemp °C',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Icon(
                                      currentSky == 'Clouds' ||
                                              currentSky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 64,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Center(
                                    child: Text(
                                      currentSky,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Hourly Forecast',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: [
                    //       for (int i = 0; i < 5; i++)
                    //         HourlyForecastItem(
                    //           time: data['list'][i + 1]['dt'].toString(),
                    //           temperature: data['list'][i + 1]['main']['temp']
                    //               .toString(),
                    //           icon: data['list'][i + 1]['weather'][0]['main'] ==
                    //                       'Clouds' ||
                    //                   data['list'][i + 1]['weather'][0]
                    //                           ['main'] ==
                    //                       'Rain'
                    //               ? Icons.cloud
                    //               : Icons.sunny,
                    //         ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final time = DateTime.parse(
                                data['list'][index + 1]['dt_txt']);
                            return HourlyForecastItem(
                              time: DateFormat.j().format(time),
                              temperature: (data['list'][index + 1]['main']
                                              ['temp'] -
                                          273.15)
                                      .toStringAsFixed(2) +
                                  '°C',
                              icon: data['list'][index + 1]['weather'][0]
                                              ['main'] ==
                                          'Clouds' ||
                                      data['list'][index + 1]['weather'][0]
                                              ['main'] ==
                                          'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                            );
                          }),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalinfoItem(
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: currentHumidity.toString(),
                        ),
                        AdditionalinfoItem(
                          icon: Icons.air,
                          label: 'Wind Speed',
                          value: currentWindSpeed.toString(),
                        ),
                        AdditionalinfoItem(
                          icon: Icons.beach_access,
                          label: 'Pressure',
                          value: currentPressure.toString(),
                        ),
                      ],
                    ),
                  ]),
            );
          }),
    );
  }
}
