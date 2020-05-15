import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// export const groupMemberDeleted = functions.firestore
//   .document("/groups/{groupDocId}/members/{memberDocId}")
//   .onDelete(async (snapshot, context) => {
//     const groupDocId = context.params.groupDocId;
//     const memberDocId = context.params.memberDocId;

//     if (snapshot === null) {
//       return null;
//     } else {
//       return await admin.firestore().collection('groups');
//     }
//   });

export const updateGroupMemberNickname = functions.firestore
  .document("/groups/{groupDocId}/members/{memberDocId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const groupDocId: string = context.params.groupDocId;

    if (before == null || after == null) {
      return null;
    } else {
      const oldNickname: string = before.nickname;
      const newNickname: string = after.nickname;

      if (oldNickname !== newNickname) {
        const groupDocRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> = admin
          .firestore()
          .collection("groups")
          .doc(groupDocId);

        const promises: Promise<any>[] = [];

        await groupDocRef
          .collection("timetables")
          .get()
          .then(async (snapshot) => {
            snapshot.forEach(async (timetable) => {
              const gridDataList: any[] = timetable.data().gridDataList;

              gridDataList.forEach((gridData) => {
                if (gridData.member == oldNickname) {
                  const newGridData = Object.assign(Object(), gridData);
                  newGridData.member = newNickname;

                  // remove previous gridData
                  promises.push(
                    groupDocRef
                      .collection("timetables")
                      .doc(timetable.id)
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
                      .doc(timetable.id)
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
        return Promise.all(promises);
      } else {
        return null;
      }
    }
  });
