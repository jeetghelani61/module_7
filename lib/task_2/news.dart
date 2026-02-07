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
  final String apiKey = "YOUR_REAL_OMDB_KEY";
  final TextEditingController controller = TextEditingController();

  List movies = [];
  bool isLoading = false;
  String error = "";

  Future<void> searchMovie() async {
    if (controller.text.isEmpty) return;

    setState(() {
      isLoading = true;
      error = "";
    });

    final url =
        "https://www.omdbapi.com/?apikey=$apiKey&s=${controller.text}";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data["Response"] == "True") {
        setState(() {
          movies = data["Search"];
        });
      } else {
        setState(() {
          error = data["Error"];
          movies = [];
        });
      }
    } catch (e) {
      setState(() {
        error = "Internet problem";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movie Search")),
      body: Column(
        children: [
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

          if (isLoading) const CircularProgressIndicator(),

          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final m = movies[index];
                return Card(
                  child: ListTile(
                    leading: m["Poster"] != "N/A"
                        ? Image.network(m["Poster"], width: 50)
                        : const Icon(Icons.movie),
                    title: Text(m["Title"]),
                    subtitle: Text(m["Year"]),
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
