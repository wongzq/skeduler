import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { TimetableGridData, Time, Member } from "../models/classes";

async function validateGridDataList(
  groupDocId: string,
  memberDocId: string,
  time: Time,
  members: Member[]
): Promise<void> {
  if (groupDocId == null || memberDocId == null || time == null) {
    return;
  } else {
    const groupDocRef: FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData> = admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("timetables");

    const timetables: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData> = await groupDocRef.get();

    for (const timetableDoc of timetables.docs) {
      let gridDataList: TimetableGridData[] = [];
      let tmpGridDataList: TimetableGridData[] = [];

      // populate gridDataList and tmpGridDataList
      for (let gridData of timetableDoc.data().gridDataList) {
        let tmpGridData: TimetableGridData;
        tmpGridData = new TimetableGridData(
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

        gridDataList.push(tmpGridData);
        tmpGridDataList.push(tmpGridData);
      }

      // iterate through gridDataList
      for (let gridData of gridDataList) {
        let newGridData: TimetableGridData = TimetableGridData.from(gridData);
        let timetableTimes: Time[];
        let memberTimes: Time[];
        let member: Member | undefined;
        let memberIsAvailable: boolean;

        timetableTimes = Time.generateTimes(
          [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
          [gridData.coord.day],
          new Time(gridData.coord.time.startTime, gridData.coord.time.endTime),
          timetableDoc.data().startDate.toDate(),
          timetableDoc.data().endDate.toDate()
        );

        if (
          gridData.member.docId != null &&
          gridData.member.docId.trim() != ""
        ) {
          member = members.find((groupMember) => {
            return groupMember.docId == memberDocId;
          });

          if (member != undefined || member != null) {
            // set default availability of member
            memberIsAvailable = true;

            // get corresponding times based on 'alwaysAvailable' property
            memberTimes = member.alwaysAvailable
              ? member.timesAvailable
              : member.timesUnavailable;

            // loop through each timetableTime
            for (let timetableTime in timetableTimes) {
              let availableTimeOnSameDate: boolean = false;

              // loop through each memberTime to find time on same date
              if(timetableTime.)
            }
          } else {
            newGridData.member.docId = "";
            newGridData.member.display = "";

            tmpGridDataList.splice(gridDataList.indexOf(gridData), 1);
            tmpGridDataList.push(newGridData);
          }
        }
      }
    }

    return;
  }
}

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

      // check availableTimes array
      let beforeTimesAvailable: Time[] = [];
      let afterTimesAvailable: Time[] = [];
      let checkTime: Time;

      for (let i: number = 0; i < beforeData.timesAvailable.length; i++) {
        beforeTimesAvailable.push(
          new Time(
            beforeData.timesAvailable[i].startTime,
            beforeData.timesAvailable[i].endTime
          )
        );
      }

      for (let i: number = 0; i < afterData.timesAvailable.length; i++) {
        afterTimesAvailable.push(
          new Time(
            afterData.timesAvailable[i].startTime,
            afterData.timesAvailable[i].endTime
          )
        );
      }

      // array remove operation
      if (beforeTimesAvailable.length > afterTimesAvailable.length) {
        for (let beforeTime of afterTimesAvailable) {
          const afterTime: Time | undefined = afterTimesAvailable.find(
            (time) => {
              time.isEqual(beforeTime);
            }
          );

          if (afterTime == undefined || afterTime == null) {
            checkTime = beforeTime;
            break;
          }
        }
      }
      // array union operation
      else if (beforeTimesAvailable.length < afterTimesAvailable.length) {
        for (let afterTime of afterTimesAvailable) {
          const beforeTime: Time | undefined = beforeTimesAvailable.find(
            (time) => {
              time.isEqual(afterTime);
            }
          );

          if (beforeTime == undefined || beforeTime == null) {
            checkTime = afterTime;
            break;
          }
        }
      }

      // check unavailableTimes array
      let beforeTimesUnavailable: Time[] = [];
      let afterTimesUnavailable: Time[] = [];

      for (let i: number = 0; i < beforeData.timesUnavailable.length; i++) {
        beforeTimesUnavailable.push(
          new Time(
            beforeData.timesUnavailable[i].startTime,
            beforeData.timesUnavailable[i].endTime
          )
        );
      }

      for (let i: number = 0; i < afterData.timesUnavailable.length; i++) {
        afterTimesUnavailable.push(
          new Time(
            afterData.timesUnavailable[i].startTime,
            afterData.timesUnavailable[i].endTime
          )
        );
      }

      return Promise.all(promises);
    }
  });
