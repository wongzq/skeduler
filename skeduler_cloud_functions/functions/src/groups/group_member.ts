import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const updateGroupMemberNickname = functions.firestore
  .document("/groups/{groupDocId}/members/{memberDocId}")
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
      const oldNickname: string = before.nickname;
      const newNickname: string = after.nickname;

      if (oldNickname != newNickname) {
        const groupDocRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> = admin
          .firestore()
          .collection("groups")
          .doc(groupDocId);

        const promises: Promise<any>[] = [];

        await groupDocRef
          .collection("timetables")
          .get()
          .then(async (timetablesSnap) => {
            timetablesSnap.forEach(async (timetableDocSnap) => {
              const gridDataList: any[] = timetableDocSnap.data().gridDataList;

              gridDataList.forEach((gridData) => {
                if (gridData.member == oldNickname) {
                  const newGridData = Object.assign(Object(), gridData);
                  newGridData.member = newNickname;

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

        return Promise.all(promises);
      } else {
        return null;
      }
    }
  });
