import * as admin from "firebase-admin";
import { TimetableGridData, Time, Member } from "../models/custom_classes";

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

        if (memberDoc.exists == false || memberDocData == null) {
          return admin
            .firestore()
            .collection("groups")
            .doc(groupDocId)
            .collection("timetables")
            .get()
            .then(async (timetables) => {
              const promises: Promise<any>[] = [];

              for (const timetableDoc of timetables.docs) {
                let tmpGridDataList: TimetableGridData[] = [];

                // populate tmpGridDataList
                for (const gridData of timetableDoc.data().gridDataList) {
                  tmpGridDataList.push(
                    new TimetableGridData(
                      gridData.ignore,
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
                  if (
                    tmpGridData.member.docId != null &&
                    tmpGridData.member.docId.trim() != "" &&
                    tmpGridData.member.docId == memberDocId
                  ) {
                    // new grid data
                    let newGridData: TimetableGridData = TimetableGridData.from(
                      tmpGridData
                    );

                    // update [available] in newGridData
                    newGridData.available = false;

                    if (tmpGridData.notEqual(newGridData)) {
                      newGridData.ignore = false;
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
            });
        } else {
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
            .then(async (timetables) => {
              const promises: Promise<any>[] = [];

              // iterate through each timetable document
              for (const timetableDoc of timetables.docs) {
                let tmpGridDataList: TimetableGridData[] = [];

                // populate tmpGridDataList
                for (const gridData of timetableDoc.data().gridDataList) {
                  tmpGridDataList.push(
                    new TimetableGridData(
                      gridData.ignore,
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

                    if (tmpGridData.notEqual(newGridData)) {
                      newGridData.ignore = false;

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
      });
  }
}
