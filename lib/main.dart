import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'movieModel.dart';
import 'apiKey.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(Nav());
}

class Nav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  String _name;
  var _controller = TextEditingController();
  final passwordFocus = FocusNode();

  @override
  void dispose() {
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        home: Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: Colors.purple[200],
          appBar: AppBar(
            title: Text(
              'Home',
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
          ),
          body: Container(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent[100],
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: TextField(
                        controller: _controller,
                        autocorrect: false,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintStyle:
                              TextStyle(fontSize: 17, color: Colors.white),
                          hintText: 'Enter a movie/serie name',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.clear),
                            onPressed: () => _controller.clear(),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20),
                        ),
                        onSubmitted: (_item) {
                          passwordFocus.requestFocus();
                          setState(() {
                            _name = _item;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Search(_name)),
                          );
                        },
                      ),
                    ),
                    Container(
                      child: Trend(),
                    )
                  ],
                ),
              ),
            ),
          ),
          drawer: Drawer(
            child: Container(
              color: Colors.purple[200],
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    height: 70,
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.only(top: 35),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent[100],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Text(
                        'Menu',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Search extends StatefulWidget {
  final String name;
  Search(this.name);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  searchMovies() async {
    var url =
        "https://api.themoviedb.org/3/search/multi?api_key=$API_KEY&query=${widget.name}&page=1&include_adult=false";
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
          singleMovie['release_date'],
          singleMovie['overview'],
          singleMovie['poster_path'],
          singleMovie['vote_average'],
          singleMovie['media_type'],
        );
        print(movie.title);
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
        );
        MovieList.add(movie);
        print(movie.title);
        continue;
      }
    }
    print(MovieList);
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
          padding: const EdgeInsets.all(30),
          child: Center(
            child: FutureBuilder(
              future: searchMovies(),
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData) {
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
                      height: 35,
                    );
                  },
                  padding: const EdgeInsets.only(bottom: 50),
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
                              height: 450,
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
                                fontWeight: FontWeight.bold,
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

class Trend extends StatefulWidget {
  @override
  _TrendState createState() => _TrendState();
}

class _TrendState extends State<Trend> {
  getTrending() async {
    var url = 'https://api.themoviedb.org/3/trending/all/week?api_key=$API_KEY';
    var respond = await http.get(url);
    var result = jsonDecode(respond.body);
    List<Movie> TrendList = List<Movie>();
    for (var singleMovie in result['results']) {
      if (singleMovie['vote_average'].runtimeType != double) {
        singleMovie['vote_average'] = singleMovie['vote_average'].toDouble();
      }
      if (singleMovie['media_type'] == 'tv') {
        Movie movie = Movie(
          singleMovie['original_name'],
          singleMovie['release_date'],
          singleMovie['overview'],
          singleMovie['poster_path'],
          singleMovie['vote_average'],
          singleMovie['media_type'],
        );
        TrendList.add(movie);
        continue;
      } else {
        Movie movie = Movie(
          singleMovie['original_title'],
          singleMovie['release_date'],
          singleMovie['overview'],
          singleMovie['poster_path'],
          singleMovie['vote_average'],
          singleMovie['media_type'],
        );
        TrendList.add(movie);
        continue;
      }
    }
    return (TrendList);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text(
            'Trends',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                color: Colors.blueAccent[500],
                fontSize: 40,
              ),
            ),
          ),
          FutureBuilder(
            future: getTrending(),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData) {
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
                    height: 35,
                  );
                },
                padding: const EdgeInsets.only(bottom: 50),
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
                            height: 450,
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
                              fontSize: 20,
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
        ],
      ),
    );
  }
}

class MoviePage extends StatelessWidget {
  Movie movie;
  MoviePage(this.movie);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image(
            image:
                NetworkImage('https://image.tmdb.org/t/p/w500/${movie.poster}'),
          ),
          FlatButton(
            child: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
