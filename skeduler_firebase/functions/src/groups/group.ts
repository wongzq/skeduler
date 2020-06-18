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

    if (snapshot === null || groupData === null || groupData === undefined) {
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

interface ValidateConflictsArgs {
  groupDocId: string;
  memberDocId?: string | undefined;
  timetableDocId?: string | undefined;
}

export async function validateConflicts({
  groupDocId,
  memberDocId,
  timetableDocId,
}: ValidateConflictsArgs): Promise<any> {
  if (groupDocId == null) {
    return null;
  } else {
    // array of promises
    const promises: Promise<any>[] = [];

    // array for new conflicts
    const newConflicts: Conflict[] = [];

    // array for old conflicts
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

    // array for timetables
    // if timetableDocId not null, then only that particular timetable is in the array
    const timetables: Timetable[] = await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("timetables")
      .get()
      .then((timetablesQuerySnap) => {
        const tmpTimetables: Timetable[] = [];

        for (const timetableQueryDoc of timetablesQuerySnap.docs) {
          const tmpTimetable: Timetable | null = Timetable.fromFirestoreSnapshot(
            timetableQueryDoc
          );

          if (tmpTimetable != null) {
            if (
              timetableDocId == null ||
              (timetableDocId != null && tmpTimetable.docId == timetableDocId)
            ) {
              tmpTimetables.push(tmpTimetable);
            }
          }
        }
        return tmpTimetables;
      });

    // array of members
    // if memberDocId not null, then only that particular member is in the array
    const members: Member[] = await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("members")
      .get()
      .then((querySnapshot) => {
        const tmpMembers: Member[] = [];
        for (const memberQueryDoc of querySnapshot.docs) {
          const tmpMember: Member | null = Member.fromFirestoreSnapshot(
            memberQueryDoc
          );

          if (tmpMember != null) {
            if (
              memberDocId == null ||
              (memberDocId != null && tmpMember.docId == memberDocId)
            ) {
              tmpMembers.push(tmpMember);
            }
          }
        }
        return tmpMembers;
      });

    // iterate through members
    for (const member of members) {
      // array of member timesAvailable or timesUnavailable
      const memberTimes: Time[] =
        member == null
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

            if (member == null) {
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
            } else if (gridData.member.docId == member.docId) {
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

        const removePromises: Promise<any>[] = [];
        for (const oldConflict of oldConflicts) {
          if (
            oldConflict.member.docId == member.docId &&
            oldConflict.timetable == timetable.docId
          ) {
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

        promises.push(
          Promise.all(removePromises).then(() => {
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
          })
        );
      } // timetable loop end
    } // member loop end

    return Promise.all(promises);
  }
}
