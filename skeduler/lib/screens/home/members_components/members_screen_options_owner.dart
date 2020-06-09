import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/navigation/route_arguments.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/shared/functions.dart';

class MembersScreenOptionsOwner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Container()
        : SpeedDial(
            foregroundColor: getFABIconForegroundColor(context),
            backgroundColor: getFABIconBackgroundColor(context),
            overlayColor: Colors.grey,
            overlayOpacity: 0.8,
            curve: Curves.easeOutCubic,
            animatedIcon: AnimatedIcons.menu_close,

            // Delete group
            children: <SpeedDialChild>[
              // Add dummy
              SpeedDialChild(
                foregroundColor: getFABIconForegroundColor(context),
                backgroundColor: getFABIconBackgroundColor(context),
                child: Icon(
                  Icons.person_outline,
                  size: 25.0,
                ),
                labelWidget: Container(
                  height: 40.0,
                  width: 150.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: getFABIconBackgroundColor(context),
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
                    'ADD DUMMY',
                    style: TextStyle(
                      color: getFABTextColor(context),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/group/addDummy',
                    arguments: RouteArgs(),
                  );
                },
              ),

              // Add member
              SpeedDialChild(
                foregroundColor: getFABIconForegroundColor(context),
                backgroundColor: getFABIconBackgroundColor(context),
                child: Icon(
                  Icons.person_add,
                  size: 25.0,
                ),
                labelWidget: Container(
                  height: 40.0,
                  width: 150.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: getFABIconBackgroundColor(context),
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
                    'ADD MEMBER',
                    style: TextStyle(
                      color: getFABTextColor(context),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/group/addMember',
                    arguments: RouteArgs(),
                  );
                },
              ),
            ],
          );
  }
}
