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
    console.log("started");

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

      // alwaysAvailable changed

      // times changed
      {
        const beforeMember: Member = new Member(
          change.before.id,
          beforeData.alwaysAvailable,
          beforeData.name,
          beforeData.nickname,
          beforeData.role,
          beforeData.timesAvailable,
          beforeData.timesUnavailable
        );

        const afterMember: Member = new Member(
          change.after.id,
          afterData.alwaysAvailable,
          afterData.name,
          afterData.nickname,
          afterData.role,
          afterData.timesAvailable,
          afterData.timesUnavailable
        );

        if (afterMember.alwaysAvailable) {
          console.log("member always available");

          // check for changes in unavailableTimes
          // array remove operation
          if (
            beforeMember.timesUnavailable.length >
            afterMember.timesUnavailable.length
          ) {
            console.log("unavailable remove");

            for (let beforeTime of beforeMember.timesUnavailable) {
              const afterTime:
                | Time
                | undefined = afterMember.timesUnavailable.find((time) => {
                return time.isEqual(beforeTime);
              });

              if (afterTime == null) {
                promises.push(
                  validateTimetablesGridDataList(
                    groupDocId,
                    afterMember,
                    beforeTime,
                    FirestoreArrayOperation.remove
                  )
                );
              }
            }
          }
          // array union operation
          else if (
            beforeMember.timesUnavailable.length <
            afterMember.timesUnavailable.length
          ) {
            console.log("unavailable union");

            for (let afterTime of afterMember.timesUnavailable) {
              const beforeTime:
                | Time
                | undefined = beforeMember.timesUnavailable.find((time) => {
                return time.isEqual(afterTime);
              });

              if (beforeTime == null) {
                promises.push(
                  validateTimetablesGridDataList(
                    groupDocId,
                    afterMember,
                    afterTime,
                    FirestoreArrayOperation.union
                  )
                );
              }
            }
          }
        } else {
          console.log("member not always available");

          // check for changes in availableTimes
          // array remove operation
          if (
            beforeMember.timesAvailable.length >
            afterMember.timesAvailable.length
          ) {
            console.log("available remove");

            for (let beforeTime of beforeMember.timesAvailable) {
              const afterTime:
                | Time
                | undefined = afterMember.timesAvailable.find((time) => {
                return time.isEqual(beforeTime);
              });

              if (afterTime == null) {
                promises.push(
                  validateTimetablesGridDataList(
                    groupDocId,
                    afterMember,
                    beforeTime,
                    FirestoreArrayOperation.remove
                  )
                );
              }
            }
          }
          // array union operation
          else if (
            beforeMember.timesAvailable.length <
            afterMember.timesAvailable.length
          ) {
            console.log("available union");

            for (let afterTime of afterMember.timesAvailable) {
              const beforeTime:
                | Time
                | undefined = beforeMember.timesAvailable.find((time) => {
                return time.isEqual(afterTime);
              });

              if (beforeTime == null) {
                promises.push(
                  validateTimetablesGridDataList(
                    groupDocId,
                    afterMember,
                    afterTime,
                    FirestoreArrayOperation.union
                  )
                );
              }
            }
          }
        }
      }

      return Promise.all(promises);
    }
  });

enum FirestoreArrayOperation {
  union,
  remove,
}

async function validateTimetablesGridDataList(
  groupDocId: string,
  member: Member,
  time: Time,
  operation: FirestoreArrayOperation
): Promise<any> {
  console.log("validate grid data list");

  if (groupDocId == null || member == null || time == null) {
    return null;
  } else {
    const groupDocRef: FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData> = admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("timetables");

    return await groupDocRef.get().then((timetables) => {
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
          let newGridData: TimetableGridData = TimetableGridData.from(
            tmpGridData
          );

          let timetableTimes: Time[];
          let memberIsAvailable: boolean;

          // generate timetableTimes
          timetableTimes = Time.generateTimes(
            [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
            [tmpGridData.coord.day],
            new Time(
              admin.firestore.Timestamp.fromDate(
                tmpGridData.coord.time.startTime
              ),
              admin.firestore.Timestamp.fromDate(tmpGridData.coord.time.endTime)
            ),
            timetableDoc.data().startDate.toDate(),
            timetableDoc.data().endDate.toDate()
          );

          // if gridData has member
          if (
            tmpGridData.member.docId != null &&
            tmpGridData.member.docId.trim() != ""
          ) {
            // set default availability of member
            memberIsAvailable = true;

            let availableTimeOnSameDay: boolean = false;

            // loop through each timetableTime
            timetableTimesLoop: for (const timetableTime of timetableTimes) {
              // loop through each memberTime
              // loop through each memberTime to find time on same date
              if (timetableTime.sameDateAs(time)) {
                availableTimeOnSameDay = true;

                if (operation == FirestoreArrayOperation.union) {
                  // if member is always available, see unavailable times
                  // if timetableTime is within unavailable times, result is false
                  if (
                    member.alwaysAvailable &&
                    !timetableTime.notWithinTimeOf(time)
                  ) {
                    memberIsAvailable = false;
                    break timetableTimesLoop;
                  }

                  // if member is not always available, see available times
                  // if timetableTime is not within available times, result is false
                  if (
                    !member.alwaysAvailable &&
                    !timetableTime.withinTimeOf(time)
                  ) {
                    memberIsAvailable = false;
                    break timetableTimesLoop;
                  }
                } else if (operation == FirestoreArrayOperation.remove) {
                  memberIsAvailable = false;
                }
              }
            }

            if (availableTimeOnSameDay) {
              // update [available] in newGridData
              if (memberIsAvailable) {
                newGridData.available = true;
              } else {
                newGridData.available = false;
              }

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
                  .then(() => {
                    // union new gridData in gridDataList
                    return admin
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
