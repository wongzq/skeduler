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

      // check nickname changed
      if (beforeData.nickname != afterData.nickname) {
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
                  if (gridData.member.docId == change.before.id) {
                    const tmpGridData = {
                      available: gridData.available,
                      coord: {
                        day: gridData.coord.day,
                        time: {
                          startTime: gridData.coord.time.startTime,
                          endTime: gridData.coord.time.endTime,
                        },
                        custom: gridData.coord.custom,
                      },
                      member: {
                        docId: gridData.member.docId,
                        display: gridData.member.display,
                      },
                      subject: {
                        docId: gridData.subject.docId,
                        display: gridData.subject.display,
                      },
                    };

                    const newGridData = {
                      available: gridData.available,
                      coord: {
                        day: gridData.coord.day,
                        time: {
                          startTime: gridData.coord.time.startTime,
                          endTime: gridData.coord.time.endTime,
                        },
                        custom: gridData.coord.custom,
                      },
                      member: {
                        docId: gridData.member.docId,
                        display: afterData.nickname,
                      },
                      subject: {
                        docId: gridData.subject.docId,
                        display: gridData.subject.display,
                      },
                    };

                    // remove previous gridData
                    gridDataPromises.push(
                      groupDocRef
                        .collection("timetables")
                        .doc(timetableDocSnap.id)
                        .update({
                          gridDataList: admin.firestore.FieldValue.arrayRemove(
                            tmpGridData
                          ),
                        })
                        .then(() => {
                          console.log("remove index");
                        })
                    );

                    // add updated gridData
                    gridDataPromises.push(
                      groupDocRef
                        .collection("timetables")
                        .doc(timetableDocSnap.id)
                        .update({
                          gridDataList: admin.firestore.FieldValue.arrayUnion(
                            newGridData
                          ),
                        })
                        .then(() => {
                          console.log("add index");
                        })
                    );
                  }
                });
              });
              return Promise.all(gridDataPromises);
            })
        );
        return Promise.all(promises);
      } else {
        return null;
      }
    }
  });
