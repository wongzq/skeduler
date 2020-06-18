import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {
  TimetableGridData,
  Time,
  Member,
  Timetable,
} from "../models/custom_classes";
import { validateConflicts } from "./group";

export const createGroupTimetable = functions.firestore
  .document("/groups/{groupDocId}/timetables/{timetableDocId}")
  .onCreate(async (snapshot, context) => {
    // const groupDocId: string = context.params.groupDocId;
    // const timetableDocId: string = context.params.timetableDocId;
    const timetableData:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (snapshot == null || timetableData == null) {
      return null;
    } else {
      return null;
    }
  });

  export const deleteGroupTimetable = functions.firestore
  .document("/groups/{groupDocId}/timetables/{timetableDocId}")
  .onDelete(async (snapshot, context) => {
    // const groupDocId: string = context.params.groupDocId;
    // const timetableDocId: string = context.params.timetableDocId;
    const timetableData:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (snapshot == null || timetableData == null) {
      return null;
    } else {
      return null;
    }
  });

export const updateGroupTimetable = functions.firestore
  .document("/groups/{groupDocId}/timetables/{timetableDocId}")
  .onUpdate(async (change, context) => {
    const groupDocId: string = context.params.groupDocId;
    const timetableDocId: string = context.params.timetableDocId;

    const beforeData:
      | FirebaseFirestore.DocumentData
      | undefined = change.before.data();
    const afterData:
      | FirebaseFirestore.DocumentData
      | undefined = change.after.data();

    if (beforeData == null || afterData == null) {
      return null;
    } else {
      const promises: Promise<any>[] = [];

      promises.push(
        validateConflicts({
          groupDocId: groupDocId,
          timetableDocId: timetableDocId,
        })
      );

      return Promise.all(promises);
    }
  });

export async function validateTimetablesGridDataList(
  groupDocId: string,
  memberDocId: string
): Promise<any> {
  if (groupDocId == null || memberDocId == null) {
    return null;
  } else {
    return await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("members")
      .doc(memberDocId)
      .get()
      .then(async (memberDoc) => {
        const memberDocData:
          | FirebaseFirestore.DocumentData
          | undefined = memberDoc.data();

        // if member not found, set all TimetableGridData with this member to unavailable
        if (!memberDoc.exists || memberDocData == null) {
          return admin
            .firestore()
            .collection("groups")
            .doc(groupDocId)
            .collection("timetables")
            .get()
            .then(async (timetablesQuerySnap) => {
              const promises: Promise<any>[] = [];
              const timetables: Timetable[] = [];

              // populate timetables
              for (const timetableDoc of timetablesQuerySnap.docs) {
                timetables.push(
                  new Timetable(
                    timetableDoc.id,
                    timetableDoc.data().startDate,
                    timetableDoc.data().endDate,
                    timetableDoc.data().groups
                  )
                );
              }

              // iterate through timetables
              for (const timetable of timetables) {
                // iterate through groups
                for (const group of timetable.groups) {
                  // iterate through gridDataList
                  for (const gridData of group.gridDataList) {
                    if (
                      gridData.member.docId != null &&
                      gridData.member.docId.trim() != "" &&
                      gridData.member.docId == memberDocId
                    ) {
                      // new grid data
                      let newGridData: TimetableGridData = TimetableGridData.from(
                        gridData
                      );

                      // update [available] in newGridData
                      newGridData.available = false;

                      if (gridData.notEqual(newGridData)) {
                        newGridData.ignore = false;

                        // remove old gridData in gridDataList
                        promises.push(
                          admin
                            .firestore()
                            .collection("groups")
                            .doc(groupDocId)
                            .collection("timetables")
                            .doc(timetable.docId)
                            .update({
                              groups: admin.firestore.FieldValue.arrayRemove(
                                gridData.asFirestoreMap()
                              ),
                            })
                            .then(async () => {
                              // union new gridData in gridDataList
                              return await admin
                                .firestore()
                                .collection("groups")
                                .doc(groupDocId)
                                .collection("timetables")
                                .doc(timetable.docId)
                                .update({
                                  groups: admin.firestore.FieldValue.arrayUnion(
                                    newGridData.asFirestoreMap()
                                  ),
                                });
                            })
                        );
                      }
                    }
                  }
                }
              }
            });
        }
        // if member is found
        else {
          const member: Member = new Member(
            memberDoc.id,
            memberDocData.alwaysAvailable,
            memberDocData.name,
            memberDocData.nickname,
            memberDocData.role,
            memberDocData.timesAvailable ?? [],
            memberDocData.timesUnavailable ?? []
          );

          return await admin
            .firestore()
            .collection("groups")
            .doc(groupDocId)
            .collection("timetables")
            .get()
            .then(async (timetablesQuerySnap) => {
              const promises: Promise<any>[] = [];
              const timetables: Timetable[] = [];

              // populate timetables
              for (const timetableDoc of timetablesQuerySnap.docs) {
                timetables.push(
                  new Timetable(
                    timetableDoc.id,
                    timetableDoc.data().startDate,
                    timetableDoc.data().endDate,
                    timetableDoc.data().groups
                  )
                );
              }

              // iterate through timetables
              for (const timetable of timetables) {
                // iterate through groups
                for (const group of timetable.groups) {
                  // iterate through gridDataList
                  for (const gridData of group.gridDataList) {
                    // if gridData has member
                    if (
                      gridData.member.docId != null &&
                      gridData.member.docId.trim() != "" &&
                      gridData.member.docId == member.docId
                    ) {
                      // new grid data
                      let newGridData: TimetableGridData = TimetableGridData.from(
                        gridData
                      );

                      // get memberTimes
                      const memberTimes: Time[] = member.alwaysAvailable
                        ? member.timesUnavailable
                        : member.timesAvailable;

                      // generate timetableTimes
                      const timetableTimes: Time[] = Time.generateTimes(
                        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
                        [gridData.coord.day],
                        new Time(
                          admin.firestore.Timestamp.fromDate(
                            gridData.coord.time.startTime
                          ),
                          admin.firestore.Timestamp.fromDate(
                            gridData.coord.time.endTime
                          )
                        ),
                        timetable.startDate,
                        timetable.endDate
                      );

                      // set default availability of member
                      let memberIsAvailable: boolean = true;

                      // loop through each timetableTime
                      timetableTimesLoop: for (const timetableTime of timetableTimes) {
                        let availableTimeFound: boolean = false;

                        memberTimesLoop: for (const memberTime of memberTimes) {
                          // if member is always available
                          // check unavailable times
                          // if timetableTime is within unavailable times, member is not available
                          if (
                            member.alwaysAvailable &&
                            !timetableTime.notWithinDateTimeOf(memberTime)
                          ) {
                            memberIsAvailable = false;
                            break timetableTimesLoop;
                          }
                          // else if member is not always available
                          // check available times
                          // if timetableTime is not within available times, member is available
                          else if (
                            !member.alwaysAvailable &&
                            timetableTime.withinDateTimeOf(memberTime)
                          ) {
                            availableTimeFound = true;
                            break memberTimesLoop;
                          }
                        }

                        if (!member.alwaysAvailable && !availableTimeFound) {
                          memberIsAvailable = false;
                          break timetableTimesLoop;
                        }
                      }

                      // update [available] in newGridData
                      newGridData.available = memberIsAvailable;

                      if (gridData.notEqual(newGridData)) {
                        newGridData.ignore = false;

                        // remove old gridData in gridDataList
                        promises.push(
                          admin
                            .firestore()
                            .collection("groups")
                            .doc(groupDocId)
                            .collection("timetables")
                            .doc(timetable.docId)
                            .update({
                              gridDataList: admin.firestore.FieldValue.arrayRemove(
                                gridData.asFirestoreMap()
                              ),
                            })
                            .then(async () => {
                              // union new gridData in gridDataList
                              return await admin
                                .firestore()
                                .collection("groups")
                                .doc(groupDocId)
                                .collection("timetables")
                                .doc(timetable.docId)
                                .update({
                                  gridDataList: admin.firestore.FieldValue.arrayUnion(
                                    newGridData.asFirestoreMap()
                                  ),
                                });
                            })
                        );
                      }
                    }
                  }
                }
              }

              return Promise.all(promises);
            });
        }
      });
  }
}
