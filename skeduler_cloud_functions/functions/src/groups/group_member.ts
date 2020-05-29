import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { TimetableGridData, Time, Member } from "../models/classes";

export const createGroupMember = functions.firestore
  .document("/groups/{groupDocId}/members/{memberDocId}")
  .onCreate(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const memberSnap:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (memberSnap == null) {
      return null;
    } else {
      return await admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .update({
          members: admin.firestore.FieldValue.arrayUnion(snapshot.id),
        });
    }
  });

export const deleteGroupMember = functions.firestore
  .document("/groups/{groupDocId}/members/{memberDocId}")
  .onDelete(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const memberSnap:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (memberSnap == null) {
      return null;
    } else {
      return await admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .update({
          members: admin.firestore.FieldValue.arrayRemove(snapshot.id),
        });
    }
  });

export const updateGroupMember = functions.firestore
  .document("/groups/{groupDocId}/members/{memberDocId}")
  .onUpdate(async (change, context) => {
    const groupDocId: string = context.params.groupDocId;
    const memberDocId: string = context.params.memberDocId;

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
      const groupDocRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> = admin
        .firestore()
        .collection("groups")
        .doc(groupDocId);

      // check role changed
      if (beforeData.role != afterData.role && afterData.role == 4) {
        promises.push(
          groupDocRef.update({
            owner: { email: memberDocId, name: afterData.name },
          })
        );
      }

      // check nickname changed
      if (beforeData.nickname != afterData.nickname) {
        promises.push(
          groupDocRef
            .collection("timetables")
            .get()
            .then(async (timetablesSnap) => {
              const gridDataPromises: Promise<any>[] = [];

              timetablesSnap.forEach(async (timetableDocSnap) => {
                const gridDataList: any[] = timetableDocSnap.data()
                  .gridDataList;

                // find corresponding gridData
                gridDataList.forEach((gridData) => {
                  if (gridData.member.docId == change.before.id) {
                    const tmpGridData: TimetableGridData = new TimetableGridData(
                      gridData.available,
                      gridData.coord.day,
                      gridData.coord.time.startTime,
                      gridData.coord.time.endTime,
                      gridData.coord.custom,
                      gridData.member.docId,
                      gridData.member.display,
                      gridData.subject.docId,
                      gridData.subject.display
                    );

                    const newGridData: TimetableGridData = new TimetableGridData(
                      gridData.available,
                      gridData.coord.day,
                      gridData.coord.time.startTime,
                      gridData.coord.time.endTime,
                      gridData.coord.custom,
                      gridData.member.docId,
                      afterData.nickname,
                      gridData.subject.docId,
                      gridData.subject.display
                    );

                    // remove previous gridData
                    gridDataPromises.push(
                      groupDocRef
                        .collection("timetables")
                        .doc(timetableDocSnap.id)
                        .update({
                          gridDataList: admin.firestore.FieldValue.arrayRemove(
                            tmpGridData.asFirestoreMap()
                          ),
                        })
                    );

                    // add updated gridData
                    gridDataPromises.push(
                      groupDocRef
                        .collection("timetables")
                        .doc(timetableDocSnap.id)
                        .update({
                          gridDataList: admin.firestore.FieldValue.arrayUnion(
                            newGridData.asFirestoreMap()
                          ),
                        })
                    );
                  }
                });
              });

              return Promise.all(gridDataPromises);
            })
        );
      }

      // times changed
      const member: Member = new Member(
        change.after.id,
        afterData.alwaysAvailable,
        afterData.name,
        afterData.nickname,
        afterData.role,
        afterData.timesAvailable,
        afterData.timesUnavailable
      );

      promises.push(validateTimetablesGridDataList(groupDocId, member));

      return Promise.all(promises);
    }
  });

async function validateTimetablesGridDataList(
  groupDocId: string,
  member: Member
): Promise<any> {
  if (groupDocId == null || member == null) {
    return null;
  } else {
    return await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("timetables")
      .get()
      .then((timetables) => {
        const promises: Promise<any>[] = [];

        // iterate through each timetable document
        for (const timetableDoc of timetables.docs) {
          let tmpGridDataList: TimetableGridData[] = [];

          // populate tmpGridDataList
          for (const gridData of timetableDoc.data().gridDataList) {
            tmpGridDataList.push(
              new TimetableGridData(
                gridData.available,
                gridData.coord.day,
                gridData.coord.time.startTime.toDate(),
                gridData.coord.time.endTime.toDate(),
                gridData.coord.custom,
                gridData.member.docId,
                gridData.member.display,
                gridData.subject.docId,
                gridData.subject.display
              )
            );
          }

          // iterate through tmpGridDataList
          for (const tmpGridData of tmpGridDataList) {
            // if gridData has member
            if (
              tmpGridData.member.docId != null &&
              tmpGridData.member.docId.trim() != "" &&
              tmpGridData.member.docId == member.docId
            ) {
              // new grid data
              let newGridData: TimetableGridData = TimetableGridData.from(
                tmpGridData
              );

              // get memberTimes
              const memberTimes: Time[] = member.alwaysAvailable
                ? member.timesUnavailable
                : member.timesAvailable;

              // generate timetableTimes
              const timetableTimes: Time[] = Time.generateTimes(
                [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
                [tmpGridData.coord.day],
                new Time(
                  admin.firestore.Timestamp.fromDate(
                    tmpGridData.coord.time.startTime
                  ),
                  admin.firestore.Timestamp.fromDate(
                    tmpGridData.coord.time.endTime
                  )
                ),
                timetableDoc.data().startDate.toDate(),
                timetableDoc.data().endDate.toDate()
              );

              // set default availability of member
              let memberIsAvailable: boolean = true;

              // loop through each timetableTime
              timetableTimesLoop: for (const timetableTime of timetableTimes) {
                let availableTimeFound: boolean = false;

                memberTimesLoop: for (const memberTime of memberTimes) {
                  // if member is always available
                  if (member.alwaysAvailable) {
                    // check unavailable times
                    // if timetableTime is within unavailable times, member is not available
                    if (!timetableTime.notWithinDateTimeOf(memberTime)) {
                      memberIsAvailable = false;
                      break timetableTimesLoop;
                    }
                  }
                  // else if member is not always available
                  else if (!member.alwaysAvailable) {
                    // check available times
                    // if timetableTime is within available times, member is available
                    if (timetableTime.withinDateTimeOf(memberTime)) {
                      availableTimeFound = true;
                      break memberTimesLoop;
                    }
                  }
                }

                if (!member.alwaysAvailable && !availableTimeFound) {
                  memberIsAvailable = false;
                  break timetableTimesLoop;
                }
              }

              // update [available] in newGridData
              newGridData.available = memberIsAvailable;

              if (tmpGridData.notEqual(newGridData)) {
                // remove old gridData in gridDataList
                promises.push(
                  admin
                    .firestore()
                    .collection("groups")
                    .doc(groupDocId)
                    .collection("timetables")
                    .doc(timetableDoc.id)
                    .update({
                      gridDataList: admin.firestore.FieldValue.arrayRemove(
                        tmpGridData.asFirestoreMap()
                      ),
                    })
                    .then(async () => {
                      // union new gridData in gridDataList
                      return await admin
                        .firestore()
                        .collection("groups")
                        .doc(groupDocId)
                        .collection("timetables")
                        .doc(timetableDoc.id)
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

        return Promise.all(promises);
      });
  }
}
