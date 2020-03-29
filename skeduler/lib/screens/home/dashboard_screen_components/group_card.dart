import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class GroupCard extends StatelessWidget {
  final String groupName;
  final String ownerName;
  final Color groupColour;
  final int numOfMembers;
  final bool hasNotification;

  static const _radius = 10.0;
  static const _padding = 10.0;

  const GroupCard({
    this.groupName,
    this.ownerName,
    this.groupColour,
    this.numOfMembers,
    this.hasNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    final double _dimension =
        (MediaQuery.of(context).size.width - 10) / 2 - 2 * _padding;

    RandomColor _randomColor = RandomColor();

    return GestureDetector(
      onTap: () {},
      child: Container(
        child: Stack(
          children: <Widget>[
            // Header Section
            Padding(
              padding: const EdgeInsets.all(_padding),
              child: AnimatedContainer(
                duration: Duration(seconds: 1),
                curve: Curves.easeOutCubic,
                height: _dimension,
                width: _dimension,
                decoration: BoxDecoration(
                  // color: Colors.white,
                  color: groupColour ?? _randomColor.randomColor(),
                  borderRadius: BorderRadius.circular(_radius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0.0, 2.0),
                      blurRadius: 5.0,
                    ),
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    // Image: Group image
                    // Image.asset(''),

                    // Title: Group name
                    Container(
                      height: _dimension * 0.65,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(_padding),
                          child: Text(
                            groupName != null && groupName != ''
                                ? groupName
                                : 'Group name',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  blurRadius: 3.0,
                                  color: Colors.black,
                                  offset: Offset(1.0, 1.0),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Container: Notifications
                    Visibility(
                      visible: hasNotification,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(_padding),
                          child: Container(
                            alignment: Alignment.topRight,
                            height: 30.0,
                            width: 30.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0.0, 2.0),
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Footer section
            Positioned(
              top: _dimension * 0.65 + _padding,
              right: _padding,
              child: Container(
                height: _dimension * 0.35,
                width: _dimension,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(_radius),
                    bottomRight: Radius.circular(_radius),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_padding),
                  child: Stack(
                    children: <Widget>[
                      // Group admin
                      Container(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        width: (_dimension - 2 * _padding) * 0.7,
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          ownerName ?? 'Owner\'s name',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      // Group member count
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: (_dimension - 2 * _padding) * 0.3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                35.toString(),
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: Colors.black45,
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Icon(
                                Icons.people,
                                size: 20.0,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
