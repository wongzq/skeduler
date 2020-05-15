import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const createGroup = functions.firestore
  .document("/groups/{groupDocId}")
  .onCreate(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const groupData = snapshot.data();

    if (snapshot == null || groupData == null) {
      return null;
    } else {
      const ownerEmail: string = groupData.owner.email;
      const ownerName: string = groupData.owner.name;

      return await admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .collection("members")
        .doc(ownerEmail)
        .set({ name: ownerName, nickname: ownerName, role: 3 });
    }
  });

export const deleteGroup = functions.firestore
  .document("/groups/{groupDocId}")
  .onDelete(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;

    if (snapshot == null) {
      return null;
    } else {
      const promises: Promise<any>[] = [];

      // delete members subcollection
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .doc(groupDocId)
          .collection("members")
          .listDocuments()
          .then(async (documents) => {
            const memberDeletePromises: Promise<
              FirebaseFirestore.WriteResult
            >[] = [];
            documents.forEach(async (document) => {
              memberDeletePromises.push(document.delete());
            });
            return Promise.all(memberDeletePromises);
          })
      );

      // delete timetables subcollection
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .doc(groupDocId)
          .collection("timetables")
          .listDocuments()
          .then(async (documents) => {
            const timetableDeletePromises: Promise<
              FirebaseFirestore.WriteResult
            >[] = [];
            documents.forEach(async (document) => {
              timetableDeletePromises.push(document.delete());
            });
            return Promise.all(timetableDeletePromises);
          })
      );

      return Promise.all(promises);
    }
  });
