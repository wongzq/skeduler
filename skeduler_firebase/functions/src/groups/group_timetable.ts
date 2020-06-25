import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { Conflict, Member, Timetable, Time } from "../models/custom_classes";

export const createGroupTimetable = functions.firestore
  .document("/groups/{groupDocId}/timetables/{timetableDocId}")
  .onCreate((snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const timetableDocId: string = context.params.timetableDocId;

    const timetableData:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (
      !snapshot.exists ||
      timetableData === undefined ||
      timetableData === null
    ) {
      return null;
    } else {
      return admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .update({
          timetables: admin.firestore.FieldValue.arrayUnion({
            docId: timetableDocId,
            startDate: timetableData.startDate,
            endDate: timetableData.endDate,
          }),
        });
    }
  });

export const deleteGroupTimetable = functions.firestore
  .document("/groups/{groupDocId}/timetables/{timetableDocId}")
  .onDelete((snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const timetableDocId: string = context.params.timetableDocId;

    const timetableData:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (
      !snapshot.exists ||
      timetableData === undefined ||
      timetableData === null
    ) {
      return null;
    } else {
      return admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .update({
          timetables: admin.firestore.FieldValue.arrayRemove({
            docId: timetableDocId,
            startDate: timetableData.startDate,
            endDate: timetableData.endDate,
          }),
        });
    }
  });

export const updateGroupTimetable = functions.firestore
  .document("/groups/{groupDocId}/timetables/{timetableDocId}")
  .onUpdate((change, _context) => {
    // const groupDocId: string = context.params.groupDocId;
    // const timetableDocId: string = context.params.timetableDocId;

    const beforeData:
      | FirebaseFirestore.DocumentData
      | undefined = change.before.data();
    const afterData:
      | FirebaseFirestore.DocumentData
      | undefined = change.after.data();

    if (beforeData === null || afterData === null) {
      return null;
    } else {
      const promises: Promise<any>[] = [];

      // promises.push(
      //   validateConflicts({
      //     groupDocId: groupDocId,
      //     timetableDocId: timetableDocId,
      //   })
      // );

      return Promise.all(promises);
    }
  });

interface ValidateConflictsArgs {
  groupDocId: string;
  timetableDocId: string;
}

export async function validateConflicts({
  groupDocId,
  timetableDocId,
}: ValidateConflictsArgs): Promise<any> {
  if (
    groupDocId === undefined ||
    groupDocId === null ||
    timetableDocId === undefined ||
    timetableDocId === null
  ) {
    return null;
  } else {
    // array for new and old conflicts
    const newConflicts: Conflict[] = [];
    let conflicts: Conflict[] = await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .get()
      .then((groupDocSnap) => {
        const groupData:
          | FirebaseFirestore.DocumentData
          | undefined = groupDocSnap.data();

        if (
          groupData === undefined ||
          groupData === null ||
          groupData.conflicts === null
        ) {
          return [];
        } else {
          const returnConflicts: Conflict[] = [];
          const conflicts: any[] = groupData.conflicts ?? [];
          for (const conflict of conflicts) {
            returnConflicts.push(Conflict.fromFirestoreField(conflict));
          }
          return returnConflicts;
        }
      });

    // array of members
    // if memberDocId not null, then only that particular member is in the array
    const members: Member[] = await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("members")
      .get()
      .then((membersQuery) =>
        membersQuery.docs.map((memberQueryDoc) =>
          Member.fromFirestoreDocument(memberQueryDoc)
        )
      );

    // array of timetables
    // if timetableDocId not null, then only that particular timetable is in the array
    const timetables: Timetable[] = [];
    if (timetableDocId !== undefined && timetableDocId !== null) {
      await admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .collection("timetables")
        .doc(timetableDocId)
        .get()
        .then((timetableDoc) => {
          if (
            timetableDoc.data() !== null &&
            timetableDoc.data() !== undefined
          ) {
            timetables.push(Timetable.fromFirestoreDocument(timetableDoc));
          }
        });
    } else {
      await admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .collection("timetables")
        .get()
        .then((timetablesQuery) => {
          timetablesQuery.docs.forEach((timetableQueryDoc) => {
            timetables.push(Timetable.fromFirestoreDocument(timetableQueryDoc));
          });
        });
    }

    // iterate through members
    for (const member of members) {
      // array of member timesAvailable or timesUnavailable
      const memberTimes: Time[] =
        member === null
          ? []
          : member.alwaysAvailable ?? false
          ? member.timesUnavailable ?? []
          : member.timesAvailable ?? [];

      // iterate through timetables
      for (const timetable of timetables) {
        for (const group of timetable.groups) {
          const groupIndex: number = timetable.groups.indexOf(group);

          for (const gridData of group.gridDataList) {
            const timetableTimes: Time[] = Time.generateTimes(
              [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
              [gridData.coord.day],
              new Time(
                admin.firestore.Timestamp.fromDate(
                  gridData.coord.time.startTime
                ),
                admin.firestore.Timestamp.fromDate(gridData.coord.time.endTime)
              ),
              timetable.startDate,
              timetable.endDate
            );

            const conflictDates: Date[] = [];

            if (member === null) {
              for (const timetableTime of timetableTimes) {
                conflictDates.push(timetableTime.startDate);
              }

              newConflicts.push(
                Conflict.create(
                  timetable.docId,
                  groupIndex,
                  gridData,
                  "",
                  "deleted member",
                  " - ",
                  conflictDates
                )
              );
            } else if (gridData.member.docId === member.docId) {
              for (const timetableTime of timetableTimes) {
                let availableTimeFound: boolean = false;

                for (const memberTime of memberTimes) {
                  // if member is always available, check unavailable times
                  // if timetableTime is within unavailable times, member is not available
                  if (
                    member.alwaysAvailable &&
                    !timetableTime.notWithinDateTimeOf(memberTime)
                  ) {
                    conflictDates.push(timetableTime.startDate);
                    break;
                  }
                  // if member is not always available, check available times
                  // if timetableTime is not within available times, member is ot available
                  else if (
                    !member.alwaysAvailable &&
                    timetableTime.withinDateTimeOf(memberTime)
                  ) {
                    availableTimeFound = true;
                    break;
                  }
                } // memberTimes loop end

                if (!member.alwaysAvailable && !availableTimeFound) {
                  conflictDates.push(timetableTime.startDate);
                }
              } // timetableTimes loop end

              // after checking for conflict dates
              if (conflictDates.length > 0) {
                newConflicts.push(
                  Conflict.create(
                    timetable.docId,
                    groupIndex,
                    gridData,
                    member.docId,
                    member.name,
                    member.nickname,
                    conflictDates
                  )
                );
              }
            }
          }
        }

        conflicts = conflicts.filter((oldConflict) => {
          return (
            oldConflict.member.docId !== member.docId ||
            oldConflict.timetable !== timetable.docId
          );
        });
      } // timetable loop end
    } // member loop end

    conflicts = conflicts.concat(newConflicts);

    return admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .update({
        conflicts: conflicts.map((newConflict) => {
          return newConflict.asFirestoreMap();
        }),
      });
  }
}
