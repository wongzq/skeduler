import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const createGroupSubject = functions.firestore
  .document("/groups/{groupDocId}/subjects/{subjectDocId}")
  .onCreate(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const subjectSnap:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (subjectSnap == null) {
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

    if (subjectSnap == null) {
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

    const before:
      | FirebaseFirestore.DocumentData
      | undefined = change.before.data();
    const after:
      | FirebaseFirestore.DocumentData
      | undefined = change.after.data();

    if (before == null || after == null) {
      return null;
    } else {
      const promises: Promise<any>[] = [];
      const groupDocRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> = admin
        .firestore()
        .collection("groups")
        .doc(groupDocId);

      // check nickname changed
      if (before.nickname != after.nickname) {
        await groupDocRef
          .collection("timetables")
          .get()
          .then(async (timetablesSnap) => {
            timetablesSnap.forEach(async (timetableDocSnap) => {
              const gridDataList: any[] = timetableDocSnap.data().gridDataList;

              // find corresponding gridData
              gridDataList.forEach((gridData) => {
                if (gridData.subject == before.nickname) {
                  const newGridData = Object.assign(Object(), gridData);
                  newGridData.subject = after.nickname;

                  // remove previous gridData
                  promises.push(
                    groupDocRef
                      .collection("timetables")
                      .doc(timetableDocSnap.id)
                      .update({
                        gridDataList: admin.firestore.FieldValue.arrayRemove(
                          gridData
                        ),
                      })
                  );

                  // add updated gridData
                  promises.push(
                    groupDocRef
                      .collection("timetables")
                      .doc(timetableDocSnap.id)
                      .update({
                        gridDataList: admin.firestore.FieldValue.arrayUnion(
                          newGridData
                        ),
                      })
                  );
                }
              });
            });
          });
      }

      return Promise.all(promises);
    }
  });
