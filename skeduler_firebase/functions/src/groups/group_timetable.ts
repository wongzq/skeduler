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