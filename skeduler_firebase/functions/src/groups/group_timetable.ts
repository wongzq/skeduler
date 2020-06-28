import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

export const createGroupTimetable = functions.firestore
  .document("/groups/{groupDocId}/timetables/{timetableDocId}")
  .onCreate((snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const timetableDocId: string = context.params.timetableDocId;

    const timetableData:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (
      !snapshot.exists ||
      timetableData === undefined ||
      timetableData === null
    ) {
      return null;
    } else {
      return admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .update({
          timetables: admin.firestore.FieldValue.arrayUnion({
            docId: timetableDocId,
            startDate: timetableData.startDate,
            endDate: timetableData.endDate,
          }),
        });
    }
  });

export const deleteGroupTimetable = functions.firestore
  .document("/groups/{groupDocId}/timetables/{timetableDocId}")
  .onDelete((snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const timetableDocId: string = context.params.timetableDocId;

    const timetableData:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (
      !snapshot.exists ||
      timetableData === undefined ||
      timetableData === null
    ) {
      return null;
    } else {
      return admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .update({
          timetables: admin.firestore.FieldValue.arrayRemove({
            docId: timetableDocId,
            startDate: timetableData.startDate,
            endDate: timetableData.endDate,
          }),
        });
    }
  });

export const updateGroupTimetable = functions.firestore
  .document("/groups/{groupDocId}/timetables/{timetableDocId}")
  .onUpdate((change, context) => {
    const groupDocId: string = context.params.groupDocId;
    const timetableDocId: string = context.params.timetableDocId;

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

      if (
        !beforeData.startDate.isEqual(afterData.startDate) ||
        !beforeData.endDate.isEqual(afterData.endDate)
      ) {
        promises.push(
          admin
            .firestore()
            .collection("groups")
            .doc(groupDocId)
            .update({
              timetables: admin.firestore.FieldValue.arrayRemove({
                docId: timetableDocId,
                startDate: beforeData.startDate,
                endDate: beforeData.endDate,
              }),
            })
        );

        promises.push(
          admin
            .firestore()
            .collection("groups")
            .doc(groupDocId)
            .update({
              timetables: admin.firestore.FieldValue.arrayUnion({
                docId: timetableDocId,
                startDate: afterData.startDate,
                endDate: afterData.endDate,
              }),
            })
        );
      }

      return Promise.all(promises);
    }
  });
