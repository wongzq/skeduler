import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { TimetableGridData } from "../models/custom_classes";

export const createGroupSubject = functions.firestore
  .document("/groups/{groupDocId}/subjects/{subjectDocId}")
  .onCreate(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const subjectSnap:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (subjectSnap === undefined || subjectSnap === null) {
      return null;
    } else {
      return await admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .update({
          subjects: admin.firestore.FieldValue.arrayUnion(snapshot.id),
        });
    }
  });

export const deleteGroupSubject = functions.firestore
  .document("/groups/{groupDocId}/subjects/{subjectDocId}")
  .onDelete(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const subjectSnap:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (subjectSnap === undefined || subjectSnap === null) {
      return null;
    } else {
      return await admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .update({
          subjects: admin.firestore.FieldValue.arrayRemove(snapshot.id),
        });
    }
  });

export const updateGroupSubject = functions.firestore
  .document("/groups/{groupDocId}/subjects/{subjectDocId}")
  .onUpdate(async (change, context) => {
    const groupDocId: string = context.params.groupDocId;

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
      const groupDocRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> = admin
        .firestore()
        .collection("groups")
        .doc(groupDocId);

      // check nickname changed
      if (beforeData.nickname !== afterData.nickname) {
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
                  if (gridData.subject.docId === change.before.id) {
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
                      gridData.member.display,
                      gridData.subject.docId,
                      afterData.nickname
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

      return Promise.all(promises);
    }
  });
