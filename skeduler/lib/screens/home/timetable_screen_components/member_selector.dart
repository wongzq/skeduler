import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';

class MemberSelector extends StatefulWidget {
  /// properties
  // final bool initialExpanded;
  // final ColorShade initialValue;
  // final ValueSetter<bool> valSetExpanded;
  // final ValueSetter<ColorShade> valSetColorShade;

  /// constructors
  const MemberSelector();

  @override
  _MemberSelectorState createState() => _MemberSelectorState();
}

class _MemberSelectorState extends State<MemberSelector> {
  double _bodyHoriPadding = 5.0;
  double _chipPadding = 5;
  double _chipPaddingExtra = 2;
  double _chipLabelHoriPadding = 5;
  double _chipLabelVertPadding = 5;
  double _chipWidth;

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    _chipWidth =
        (MediaQuery.of(context).size.width - 2 * _bodyHoriPadding) / 5 -
            (2 * _chipLabelHoriPadding) -
            (2 * _chipPadding) -
            8;

    ScrollController controller = ScrollController();

    return StreamBuilder(
        stream: dbService.getGroupMembers(groupDocId.value),
        builder: (context, snapshot) {
          List<Member> members =
              snapshot != null && snapshot.data != null ? snapshot.data : [];

          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Container(
              height: 70.0,
              child: ListView.builder(
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                scrollDirection: Axis.horizontal,
                controller: controller,
                itemCount: members.length,
                itemBuilder: (BuildContext context, int index) {
                  return Visibility(
                    child: Padding(
                      padding: EdgeInsets.all(_chipPadding + _chipPaddingExtra),
                      child: Wrap(
                        children: [
                          LongPressDraggable<Member>(
                            data: members[index],
                            feedback: Material(
                              color: Colors.transparent,
                              child: ActionChip(
                                backgroundColor:
                                    members[index].colorShade != null
                                        ? getColorFromColorShade(
                                            members[index].colorShade)
                                        : null,
                                elevation: 3.0,
                                labelPadding: EdgeInsets.symmetric(
                                  horizontal: _chipLabelHoriPadding,
                                  vertical: _chipLabelVertPadding,
                                ),
                                label: Container(
                                  width: _chipWidth,
                                  child: Text(members[index].display),
                                ),
                                onPressed: () {},
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: ActionChip(
                                backgroundColor:
                                    members[index].colorShade != null
                                        ? getColorFromColorShade(
                                            members[index].colorShade)
                                        : null,
                                elevation: 3.0,
                                labelPadding: EdgeInsets.symmetric(
                                  horizontal: _chipLabelHoriPadding,
                                  vertical: _chipLabelVertPadding,
                                ),
                                label: Container(
                                  width: _chipWidth,
                                  child: Text(members[index].display),
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
