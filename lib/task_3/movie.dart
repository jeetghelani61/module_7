import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MovieSearchScreen(),
    );
  }
}

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  // 🔑 Sirf API KEY
  final String apiKey = "39bf5b52";
  final TextEditingController controller = TextEditingController();

  List movies = [];
  bool isLoading = false;
  String error = "";

  Future<void> searchMovie() async {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      error = "";
    });

    // Space safe query
    final query = Uri.encodeComponent(controller.text.trim());
    final url = "https://www.omdbapi.com/?apikey=$apiKey&s=$query";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data["Response"] == "True") {
        setState(() {
          movies = data["Search"];
        });
      } else {
        setState(() {
          error = data["Error"] ?? "No result found";
          movies = [];
        });
      }
    } catch (e) {
      setState(() {
        error = "Internet connection problem";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movie Search App"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              onSubmitted: (_) => searchMovie(),
              decoration: InputDecoration(
                hintText: "Enter movie name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchMovie,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),

          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                error,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),

          // Movie list
          Expanded(
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final m = movies[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: m["Poster"] != "N/A"
                        ? Image.network(
                      m["Poster"],
                      width: 60,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.movie, size: 40),
                    title: Text(
                      m["Title"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle:
                    Text("${m["Year"]} • ${m["Type"].toString().toUpperCase()}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
