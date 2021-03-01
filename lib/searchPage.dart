import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'movieModel.dart';
import 'apiKey.dart';
import 'package:google_fonts/google_fonts.dart';
import 'moviePage.dart';

class Search extends StatefulWidget {
  final String name;
  Search(this.name);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  searchMovies() async {
    var url =
        "https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=${widget.name}&page=1&include_adult=false";
    var response = await http.get(url);
    var result = jsonDecode(response.body);
    List<Movie> MovieList = List<Movie>();
    for (var singleMovie in result['results']) {
      if (singleMovie["media_type"] == 'person') {
        continue;
      }
      if (singleMovie['vote_average'].runtimeType != double) {
        singleMovie['vote_average'] = singleMovie['vote_average'].toDouble();
      }
      if (singleMovie['media_type'] == 'tv') {
        Movie movie = Movie(
          singleMovie['original_name'],
          singleMovie['first_air_date'],
          singleMovie['overview'],
          singleMovie['poster_path'],
          singleMovie['vote_average'],
          singleMovie['media_type'],
          singleMovie['id'],
        );
        MovieList.add(movie);
        continue;
      } else {
        Movie movie = Movie(
          singleMovie['original_title'],
          singleMovie['release_date'],
          singleMovie['overview'],
          singleMovie['poster_path'],
          singleMovie['vote_average'],
          singleMovie['media_type'],
          singleMovie['id'],
        );
        MovieList.add(movie);
        continue;
      }
    }
    return (MovieList);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.purple[200],
        appBar: AppBar(
          title: Text(
            'Results for "${widget.name}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          backgroundColor: Colors.blueAccent[100],
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 5.0),
          child: Center(
            child: FutureBuilder(
              future: searchMovies(),
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData || snapshot.data.length == 0) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blueAccent[100],
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.purple[200]),
                    ),
                  );
                }
                return ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 50,
                    );
                  },
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MoviePage(snapshot.data[index])),
                        );
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image(
                              height: 350,
                              image: NetworkImage(
                                  'https://image.tmdb.org/t/p/w500/${snapshot.data[index].poster}'),
                            ),
                          ),
                          Text(
                            '${snapshot.data[index].title}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: Colors.blueAccent[500],
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
