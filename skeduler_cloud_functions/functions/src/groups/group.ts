import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const createGroup = functions.firestore
  .document("/groups/{groupDocId}")
  .onCreate(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const groupData:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (snapshot == null || groupData == null) {
      return null;
    } else {
      const ownerEmail: string = groupData.owner.email;
      const ownerName: string = groupData.owner.name;

      // {role: 4} is group owner
      return await admin
        .firestore()
        .collection("groups")
        .doc(groupDocId)
        .collection("members")
        .doc(ownerEmail)
        .set({ name: ownerName, nickname: ownerName, role: 4 });
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
          .then(async (memberDocRefs) => {
            const memberDeletePromises: Promise<
              FirebaseFirestore.WriteResult
            >[] = [];
            memberDocRefs.forEach(async (memberDocRef) => {
              memberDeletePromises.push(memberDocRef.delete());
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
          .then(async (timetableDocRefs) => {
            const timetableDeletePromises: Promise<
              FirebaseFirestore.WriteResult
            >[] = [];
            timetableDocRefs.forEach(async (timetableDocRef) => {
              timetableDeletePromises.push(timetableDocRef.delete());
            });
            return Promise.all(timetableDeletePromises);
          })
      );

      return Promise.all(promises);
    }
  });