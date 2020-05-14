import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

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
