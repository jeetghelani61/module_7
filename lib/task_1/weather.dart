import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController cityController = TextEditingController();

  final String apiKey = "2d05bd3df986d71e190a4458ea0c3e10";

  String result = "";
  bool isLoading = false;

  Future<void> getWeather(String city) async {
    if (city.isEmpty) return;

    setState(() {
      isLoading = true;
      result = "";
    });

    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          result = """
City: ${data['name']}
Temperature: ${data['main']['temp']} °C
Feels Like: ${data['main']['feels_like']} °C
Weather: ${data['weather'][0]['description']}
Humidity: ${data['main']['humidity']}%
Wind: ${data['wind']['speed']} m/s
""";
        });
      } else {
        setState(() {
          result = "City not found!";
        });
      }
    } catch (e) {
      setState(() {
        result = "Network error!";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather App")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: "Enter City",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => getWeather(cityController.text),
                child: const Text("Get Weather"),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    result.isEmpty ? "Search a city" : result,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
