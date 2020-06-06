import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { TimetableGridData } from "../models/custom_classes";
import { validateTimetablesGridDataList } from "./group_timetable";
import { calculateScheduleConflicts } from "..";

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
  .onDelete(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const memberDocId: string = context.params.memberDocId;
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
        })
        .then(() => {
          return validateTimetablesGridDataList(groupDocId, memberDocId);
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

      promises.push(
        validateTimetablesGridDataList(groupDocId, memberDocId)
          .then(async () => {
            // check nickname changed
            if (beforeData.nickname == afterData.nickname) {
              return null;
            } else {
              return await groupDocRef
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
                          gridData.ignore,
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
                          gridData.ignore,
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
                });
            }
          })
          .then(() => {
            return calculateScheduleConflicts(groupDocId, memberDocId);
          })
      );

      return Promise.all(promises);
    }
  });
