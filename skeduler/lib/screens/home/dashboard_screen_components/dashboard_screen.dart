import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/drawer_enum.dart';
import 'package:skeduler/models/group.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/create_group.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/group_card.dart';
import 'package:skeduler/screens/home/home_drawer.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/ui_settings.dart';

class DashboardScreen extends StatelessWidget {
  /// properties
  static const double _bodyPadding = 5.0;

  /// methods
  @override
  Widget build(BuildContext context) {
    DatabaseService _dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<DrawerEnum> _selected =
        Provider.of<ValueNotifier<DrawerEnum>>(context);
    ValueNotifier<String> _groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Dashboard',
          style: textStyleAppBarTitle,
        ),
      ),
      drawer: HomeDrawer(),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(_bodyPadding),
            child: StreamBuilder<List<Group>>(
              stream: _dbService.groups,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                List<Group> _groups = snapshot.data;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: _groups != null ? _groups.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    if (_groups[index] != null) {
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _selected.value = DrawerEnum.group;
                          _groupDocId.value = _groups[index].groupDocId;
                          Navigator.of(context).pushNamed('/group');
                        },
                        child: GroupCard(
                          groupName: _groups[index].name,
                          groupColor: _groups[index].colorShade.color,
                          numOfMembers: _groups[index].numOfMembers,
                          ownerName: _groups[index].ownerName,
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                );
              },
            ),
          ),

          /// SpeedDial: Create or Join group
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

                /// Join button
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

                  /// Create button
                  SpeedDialChild(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    foregroundColor: Colors.white,
                    child: Icon(
                      FontAwesomeIcons.users,
                      size: 25.0,
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
                        'CREATE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
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
      ),
    );
  }
}
