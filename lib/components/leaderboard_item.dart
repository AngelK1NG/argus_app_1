import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

class LeaderboardItem extends StatelessWidget {
  final int place;
  final int score;
  final String name;
  final bool self;
  final String photoURL;

  LeaderboardItem({
    @required this.place,
    @required this.score,
    @required this.name,
    @required this.self,
    this.photoURL,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 25,
                child: Text(
                  place.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: self ? FontWeight.w600 : FontWeight.w400,
                    color: self
                        ? Theme.of(context).accentColor
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 19),
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.transparent,
                  child: photoURL == null
                      ? Icon(
                          FeatherIcons.user,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            photoURL,
                            width: 40,
                            height: 40,
                          ),
                        ),
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: self ? FontWeight.w600 : FontWeight.w400,
                  color: self
                      ? Theme.of(context).accentColor
                      : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: self ? FontWeight.w600 : FontWeight.w400,
              color: self
                  ? Theme.of(context).accentColor
                  : Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
