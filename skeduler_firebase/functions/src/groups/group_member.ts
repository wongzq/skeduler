import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {
  Time,
  Member,
  Timetable,
  TimetableGroup,
  TimetableGridData,
} from "../models/custom_classes";

export const createGroupMember = functions.firestore
  .document("/groups/{groupDocId}/members/{memberDocId}")
  .onCreate((snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const memberSnap:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (memberSnap === undefined || memberSnap === null) {
      return null;
    } else {
      return admin
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
  .onDelete((snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const memberDocId: string = context.params.memberDocId;
    const memberSnap:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (memberSnap === undefined || memberSnap === null) {
      return null;
    } else {
      return admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .update({
          members: admin.firestore.FieldValue.arrayRemove(snapshot.id),
        })
        .then(() => {
          return validateGridDataLists({
            groupDocId: groupDocId,
            memberDocId: memberDocId,
          });
        });
    }
  });

export const updateGroupMember = functions.firestore
  .document("/groups/{groupDocId}/members/{memberDocId}")
  .onUpdate((change, context) => {
    const groupDocId: string = context.params.groupDocId;
    const memberDocId: string = context.params.memberDocId;

    const beforeData:
      | FirebaseFirestore.DocumentData
      | undefined = change.before.data();
    const afterData:
      | FirebaseFirestore.DocumentData
      | undefined = change.after.data();

    if (
      beforeData === undefined ||
      beforeData === null ||
      afterData === undefined ||
      afterData === null
    ) {
      return null;
    } else {
      const promises: Promise<any>[] = [];

      // check role changed
      if (beforeData.role !== afterData.role && afterData.role === 4) {
        promises.push(
          admin
            .firestore()
            .collection("groups")
            .doc(groupDocId)
            .update({
              owner: { email: memberDocId, name: afterData.name },
            })
        );
      }

      // check times changed
      let timesIsDifferent: boolean = false;

      if (beforeData.alwaysAvailable !== afterData.alwaysAvailable) {
        timesIsDifferent = true;
      } else {
        const beforeTimes: Time[] = afterData.alwaysAvailable
          ? ((beforeData.timesUnavailable ?? []) as any[]).map(
              (value) => new Time(value.startTime, value.endTime)
            )
          : ((beforeData.timesAvailable ?? []) as any[]).map(
              (value) => new Time(value.startTime, value.endTime)
            );

        const afterTimes: Time[] = afterData.alwaysAvailable
          ? ((afterData.timesUnavailable ?? []) as any[]).map(
              (value) => new Time(value.startTime, value.endTime)
            )
          : ((afterData.timesAvailable ?? []) as any[]).map(
              (value) => new Time(value.startTime, value.endTime)
            );

        if (beforeTimes.length === afterTimes.length) {
          for (let i: number = 0; i < beforeTimes.length; i++) {
            if (beforeTimes[i] !== afterTimes[i]) {
              timesIsDifferent = true;
              break;
            }
          }
        } else {
          timesIsDifferent = true;
        }
      }

      // organize promises
      const changeNicknamePromise: Promise<any> | null =
        beforeData.nickname !== afterData.nickname
          ? validateNickname({
              groupDocId: groupDocId,
              memberDocId: memberDocId,
              nickname: afterData.nickname,
            })
          : null;

      const changeTimesPromise: Promise<any> | null = timesIsDifferent
        ? validateGridDataLists({
            groupDocId: groupDocId,
            memberDocId: memberDocId,
          })
        : null;

      const finalPromise: Promise<any> = (
        changeNicknamePromise ?? Promise.resolve()
      ).then(() => changeTimesPromise ?? Promise.resolve());

      promises.push(finalPromise);

      return Promise.all(promises);
    }
  });

interface ValidateNicknameArgs {
  groupDocId: string;
  memberDocId: string;
  nickname: string;
}

export async function validateNickname({
  groupDocId,
  memberDocId,
  nickname,
}: ValidateNicknameArgs): Promise<any> {
  if (groupDocId === undefined || groupDocId === null) {
    return null;
  } else {
    return admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("timetables")
      .get()
      .then((timetablesQuery) => {
        const promises: Promise<any>[] = [];

        const timetables: Timetable[] = timetablesQuery.docs.map(
          (timetableQueryDoc) =>
            Timetable.fromFirestoreDocument(timetableQueryDoc)
        );

        // iterate through timetables
        for (const timetable of timetables) {
          const newGroups: TimetableGroup[] = timetable.groups.map((value) =>
            TimetableGroup.from(value)
          );

          // iterate through groups
          for (const group of timetable.groups) {
            const newGroup: TimetableGroup = TimetableGroup.from(group);

            // iterate through gridDataList
            for (const gridData of group.gridDataList) {
              if (gridData.member.docId === memberDocId) {
                // new grid data
                const newGridData: TimetableGridData = TimetableGridData.from(
                  gridData
                );
                newGridData.member.display = nickname;

                // remove old gridData in gridDataList
                newGroup.gridDataList = newGroup.gridDataList.filter((value) =>
                  value.notEqual(gridData)
                );
                // add new gridData to gridDataList
                newGroup.gridDataList.push(newGridData);
              }
            }

            // update group
            const groupIndex: number = timetable.groups.indexOf(group);
            newGroups.splice(groupIndex, 1, newGroup);
          }

          // update in firestore
          promises.push(
            admin
              .firestore()
              .collection("groups")
              .doc(groupDocId)
              .collection("timetables")
              .doc(timetable.docId)
              .update({ groups: newGroups })
          );
        }
        return Promise.all(promises);
      });
  }
}

interface ValidateGridDataListArgs {
  groupDocId: string;
  memberDocId: string;
}

export async function validateGridDataLists({
  groupDocId,
  memberDocId,
}: ValidateGridDataListArgs): Promise<any> {
  if (
    groupDocId === undefined ||
    groupDocId === null ||
    memberDocId === undefined ||
    memberDocId === null
  ) {
    return null;
  } else {
    const promises: Promise<any>[] = [];

    // get member
    const member: Member | null = await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("members")
      .doc(memberDocId)
      .get()
      .then((memberDoc) =>
        memberDoc.exists ? Member.fromFirestoreDocument(memberDoc) : null
      );

    // array of timetables
    const timetables: Timetable[] = await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("timetables")
      .get()
      .then((timetablesQuery) =>
        timetablesQuery.docs.map((timetableQueryDoc) =>
          Timetable.fromFirestoreDocument(timetableQueryDoc)
        )
      );

    // iterate through timetables
    for (const timetable of timetables) {
      const newGroups: TimetableGroup[] = timetable.groups.map((value) =>
        TimetableGroup.from(value)
      );

      // iterate through groups
      for (const group of timetable.groups) {
        const newGroup: TimetableGroup = TimetableGroup.from(group);

        // iterate through gridDataList
        for (const gridData of group.gridDataList) {
          // new grid data
          const newGridData: TimetableGridData = TimetableGridData.from(
            gridData
          );

          // if gridData has member
          if (
            gridData.member.docId !== null &&
            gridData.member.docId.trim() !== "" &&
            gridData.member.docId === memberDocId
          ) {
            if (member === null) {
              // do something
              // update [available] in newGridData
              newGridData.available = false;

              if (gridData.notEqual(newGridData)) {
                // new conflict ignore is false
                newGridData.ignore = false;

                // remove old gridData in gridDataList
                newGroup.gridDataList = newGroup.gridDataList.filter((value) =>
                  value.notEqual(gridData)
                );
                // add new gridData to gridDataList
                newGroup.gridDataList.push(newGridData);
              }
            } else {
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
                newGroup.gridDataList = newGroup.gridDataList.filter((value) =>
                  value.notEqual(gridData)
                );
                // add new gridData to gridDataList
                newGroup.gridDataList.push(newGridData);
              }
            }
          }
        }

        const groupIndex: number = timetable.groups.indexOf(group);
        newGroups.splice(groupIndex, 1, newGroup);
      }

      // update in firestore
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .doc(groupDocId)
          .collection("timetables")
          .doc(timetable.docId)
          .update({ groups: newGroups.map((group) => group.asFirestoreMap()) })
      );
    }
    return Promise.all(promises);
  }
}
