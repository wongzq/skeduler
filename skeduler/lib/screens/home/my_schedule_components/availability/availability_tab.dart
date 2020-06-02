import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/availability_view.dart';
import 'package:skeduler/shared/functions.dart';

class AvailabilityTab extends StatefulWidget {
  @override
  _AvailabilityTabState createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends State<AvailabilityTab> {
  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Container()
        : Stack(
            children: <Widget>[
              AvailabilityView(),
              Padding(
                padding: EdgeInsets.only(right: 20.0, bottom: 20.0),
                child: SpeedDial(
                  animatedIcon: AnimatedIcons.menu_close,
                  foregroundColor: getFABIconForegroundColor(context),
                  backgroundColor: getFABIconBackgroundColor(context),
                  overlayColor: Colors.grey,
                  overlayOpacity: 0.8,
                  curve: Curves.easeOutCubic,
                  children: [
                    SpeedDialChild(
                      foregroundColor: getFABIconForegroundColor(context),
                      backgroundColor: getFABIconBackgroundColor(context),
                      onTap: () {
                        setState(() {
                          Navigator.of(context).pushNamed(
                            '/schedules/availabilityEditor',
                            arguments: RouteArgs(),
                          );
                        });
                      },
                      child: Icon(
                        Icons.edit,
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
                          'EDIT MULTIPLE',
                          style: TextStyle(
                            color: getFABTextColor(context),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    SpeedDialChild(
                      foregroundColor: getFABIconForegroundColor(context),
                      backgroundColor: getFABIconBackgroundColor(context),
                      onTap: () async {
                        Navigator.of(context).pushNamed(
                          '/schedules/addAvailability',
                          arguments: RouteArgs(),
                        );
                      },
                      child: Icon(
                        Icons.add,
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
                          'ADD SINGLE',
                          style: TextStyle(
                            color: getFABTextColor(context),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
