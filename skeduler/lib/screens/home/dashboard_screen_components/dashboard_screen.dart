import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/create_group.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/group_card.dart';

class DashboardScreen extends StatelessWidget {
  // properties
  static const double _bodyPadding = 5.0;

  // methods
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(_bodyPadding),
          child: GridView.count(
            crossAxisCount: 2,
            scrollDirection: Axis.vertical,
            children: <Widget>[
              GroupCard(),
              GroupCard(),
              GroupCard(),
              GroupCard(),
              GroupCard(),
              GroupCard(),
              GroupCard(),
              GroupCard(),
              GroupCard(),
            ],
          ),
        ),

        // SpeedDial: Create or Join group
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: SpeedDial(
              backgroundColor: Theme.of(context).primaryColor,
              overlayColor: Colors.grey,
              overlayOpacity: 0.8,
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.add,
                size: 30.0,
                color: Colors.white,
              ),
              children: <SpeedDialChild>[
                SpeedDialChild(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  foregroundColor: Colors.white,
                  child: Icon(
                    Icons.group_add,
                    size: 30.0,
                  ),
                  labelWidget: Container(
                    height: 40.0,
                    width: 100.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0.0, 5.0),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: Text(
                      'JOIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
                SpeedDialChild(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  foregroundColor: Colors.white,
                  child: Icon(
                    FontAwesomeIcons.users,
                    size: 25.0,
                  ),
                  labelWidget: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateGroup(),
                        ),
                      );
                    },
                    child: Container(
                      height: 40.0,
                      width: 100.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0.0, 5.0),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: Text(
                        'CREATE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateGroup(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
