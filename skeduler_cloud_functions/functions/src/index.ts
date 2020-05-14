import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

export const userNameUpdated = functions.firestore
  .document("/users/{userDocId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before === null || after === null) {
      return null;
    } else if (before!.name !== after!.name) {
      const userDocId = context.params.userDocId;
      const groupsColRef = admin.firestore().collection("groups");

      const querySnapshot = await groupsColRef
        .where("members", "array-contains", userDocId)
        .get();

      const promises: Array<Promise<any>> = [];

      querySnapshot.forEach(async (groupDoc) => {
        promises.push(
          groupDoc.ref
            .collection("members")
            .doc(userDocId)
            .update({ name: after!.name })
        );
      });

      return Promise.all(promises);
    } else {
      return null;
    }
  });

export const groupMemberNicknameUpdated = functions.firestore
  .document("/groups/{groupDocId}/members/{memberDocId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const groupDocId = context.params.groupDocId;

    if (before === null || after === null) {
      return null;
    } else {
      const oldNickname: String = before!.nickname;
      const newNickname: String = after!.nickname;

      if (oldNickname !== newNickname) {
        const groupTimetablesColRef = admin
          .firestore()
          .collection("groups")
          .doc(groupDocId)
          .collection("timetables");

        const querySnapshot = await groupTimetablesColRef.get();

        const promises: Array<Promise<any>> = [];

        querySnapshot.docs.forEach(async (timetable) => {
          const gridDataList: Array<any> = timetable.data().gridDataList;

          gridDataList.forEach((gridData) => {
            if (gridData.member === oldNickname) {
              const newGridData = Object.assign(Object(), gridData);
              newGridData.member = newNickname;

              // remove previous gridData
              promises.push(
                groupTimetablesColRef.doc(timetable.id).update({
                  gridDataList: admin.firestore.FieldValue.arrayRemove(
                    gridData
                  ),
                })
              );

              // add updated gridData
              promises.push(
                groupTimetablesColRef.doc(timetable.id).update({
                  gridDataList: admin.firestore.FieldValue.arrayUnion(
                    newGridData
                  ),
                })
              );
            }
          });
        });

        return Promise.all(promises);
      } else {
        return null;
      }
    }
  });
