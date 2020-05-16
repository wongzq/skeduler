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
