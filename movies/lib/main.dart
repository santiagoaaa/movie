import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:movies/pages/favorites.dart';
import 'package:movies/pages/popular.dart';
import 'package:movies/pages/search.dart';

void main() => runApp(MaterialApp(home: BottomNavBar()));

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  final Popular popular = new Popular();
  final Favorites favorites = new Favorites();
  final Search search =  new Search();

  //Pagina principal
  Widget _showPage = new Popular();

  Widget _pageChooser (int page){
    switch (page) {
      case 0:
        return search;
        break;
      case 1:
        return popular;
        break;
      case 2:
        return favorites;
        break;
      default:
        return new Container(
          child: new Center(
            child: new Text(
              'Page NOT found',
              style: new TextStyle(fontSize: 30)
            )
          )
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 1,
          height: 50.0,
          items: <Widget>[
            Icon(Icons.search, size: 30,color: Colors.white,),
            Icon(Icons.star, size: 30, color: Colors.white,),
            Icon(Icons.favorite, size: 30, color: Colors.white,),
          ],
          color: Color(0xff091059),
          buttonBackgroundColor:  Color(0xff091059),
          backgroundColor: Colors.white,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 500),
          onTap: (index) {
            setState(() {
              _page=index;
              _showPage = _pageChooser(index);
            });
          },
        ),
        body: Container(
          color: Colors.white,
          child: Center(
            child: _showPage,
          ),
        ));
  }
}