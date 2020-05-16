import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

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
    const groupDocId: string = context.params.groupDocId;
    const memberDocId: string = context.params.memberDocId;

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

      // check role changed
      if (before.role != after.role && after.role == 4) {
        promises.push(
          groupDocRef.update({
            owner: { email: memberDocId, name: after.name },
          })
        );
      }

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
                if (gridData.member == before.nickname) {
                  const newGridData = Object.assign(Object(), gridData);
                  newGridData.member = after.nickname;

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
