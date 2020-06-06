import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Timetable, Member, Time, Conflict } from "../models/custom_classes";

export const createGroup = functions.firestore
  .document("/groups/{groupDocId}")
  .onCreate(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const groupData:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (snapshot == null || groupData == null) {
      return null;
    } else {
      const ownerEmail: string = groupData.owner.email;
      const ownerName: string = groupData.owner.name;

      // {role: 4} is group owner
      return await admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .collection("members")
        .doc(ownerEmail)
        .set({ name: ownerName, nickname: ownerName, role: 4 });
    }
  });

export const deleteGroup = functions.firestore
  .document("/groups/{groupDocId}")
  .onDelete(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;

    if (snapshot == null) {
      return null;
    } else {
      const promises: Promise<any>[] = [];

      // delete members subcollection
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .doc(groupDocId)
          .collection("members")
          .listDocuments()
          .then(async (memberDocRefs) => {
            const memberDeletePromises: Promise<
              FirebaseFirestore.WriteResult
            >[] = [];
            memberDocRefs.forEach(async (memberDocRef) => {
              memberDeletePromises.push(memberDocRef.delete());
            });
            return Promise.all(memberDeletePromises);
          })
      );

      // delete subjects subcollection
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .doc(groupDocId)
          .collection("subjects")
          .listDocuments()
          .then(async (subjectDocRefs) => {
            const subjectDeletePromises: Promise<
              FirebaseFirestore.WriteResult
            >[] = [];
            subjectDocRefs.forEach(async (subjectDocRef) => {
              subjectDeletePromises.push(subjectDocRef.delete());
            });
            return Promise.all(subjectDeletePromises);
          })
      );

      // delete timetables subcollection
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .doc(groupDocId)
          .collection("timetables")
          .listDocuments()
          .then(async (timetableDocRefs) => {
            const timetableDeletePromises: Promise<
              FirebaseFirestore.WriteResult
            >[] = [];
            timetableDocRefs.forEach(async (timetableDocRef) => {
              timetableDeletePromises.push(timetableDocRef.delete());
            });
            return Promise.all(timetableDeletePromises);
          })
      );

      return Promise.all(promises);
    }
  });

export async function calculateScheduleConflicts(
  groupDocId: string,
  memberDocId: string
): Promise<any> {
  if (groupDocId == null || memberDocId == null) {
    return null;
  } else {
    const newConflicts: Conflict[] = [];

    const oldConflicts: Conflict[] = await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .get()
      .then((groupSnap) => {
        const groupData:
          | FirebaseFirestore.DocumentData
          | undefined = groupSnap.data();

        if (groupData == null || groupData.conflicts == null) {
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

    const member: Member | null = await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("members")
      .doc(memberDocId)
      .get()
      .then((snapshot) => {
        return Member.fromFirestoreSnapshot(snapshot);
      });

    const memberTimes: Time[] =
      member == null
        ? []
        : member.alwaysAvailable ?? false
        ? member.timesUnavailable ?? []
        : member.timesAvailable ?? [];

    const timetables: Timetable[] = await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("timetables")
      .get()
      .then((timetablesQuerySnap) => {
        const tmpTimetables: Timetable[] = [];
        for (const timetableQueryDoc of timetablesQuerySnap.docs) {
          const timetable: Timetable | null = Timetable.fromFirestoreSnapshot(
            timetableQueryDoc
          );

          if (timetable != null) tmpTimetables.push(timetable);
        }
        return tmpTimetables;
      });

    for (const timetable of timetables) {
      for (const gridData of timetable.gridDataList) {
        const timetableTimes: Time[] = Time.generateTimes(
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
          [gridData.coord.day],
          new Time(
            admin.firestore.Timestamp.fromDate(gridData.coord.time.startTime),
            admin.firestore.Timestamp.fromDate(gridData.coord.time.endTime)
          ),
          timetable.startDate,
          timetable.endDate
        );

        const conflictDates: Date[] = [];

        if (member == null) {
          for (const timetableTime of timetableTimes) {
            conflictDates.push(timetableTime.startDate);
          }

          newConflicts.push(
            Conflict.create(
              timetable.docId,
              gridData,
              memberDocId,
              "",
              "",
              conflictDates
            )
          );
        } else {
          for (const timetableTime of timetableTimes) {
            let availableTimeFound: boolean = false;

            for (const memberTime of memberTimes) {
              // if member is always available, check unavailable times
              // if timetableTime is within unavailable times, member is not available
              if (
                member.alwaysAvailable &&
                !timetableTime.notWithinDateTimeOf(memberTime)
              ) {
                conflictDates.push(timetable.startDate);
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
            }

            if (!member.alwaysAvailable && !availableTimeFound) {
              conflictDates.push(timetableTime.startDate);
            }
          }

          // after checking for conflict dates
          if (conflictDates.length > 0) {
            newConflicts.push(
              Conflict.create(
                timetable.docId,
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

    const removePromises: Promise<any>[] = [];
    for (const oldConflict of oldConflicts) {
      if (oldConflict.member.docId == memberDocId) {
        removePromises.push(
          admin
            .firestore()
            .collection("groups")
            .doc(groupDocId)
            .update({
              conflicts: admin.firestore.FieldValue.arrayRemove(
                oldConflict.asFirestoreMap()
              ),
            })
        );
      }
    }

    return Promise.all(removePromises).then(() => {
      const addPromises: Promise<any>[] = [];
      for (const newConflict of newConflicts) {
        addPromises.push(
          admin
            .firestore()
            .collection("groups")
            .doc(groupDocId)
            .update({
              conflicts: admin.firestore.FieldValue.arrayUnion(
                newConflict.asFirestoreMap()
              ),
            })
        );
      }

      return Promise.all(addPromises);
    });
  }
}
