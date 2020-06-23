import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const createGroup = functions.firestore
  .document("/groups/{groupDocId}")
  .onCreate((snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const groupData:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (!snapshot.exists || groupData === undefined || groupData === null) {
      return null;
    } else {
      const ownerEmail: string = groupData.owner.email;
      const ownerName: string = groupData.owner.name;

      // {role: 4} is group owner
      return admin
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
  .onDelete((snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;

    if (!snapshot.exists) {
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
          .then((members) =>
            Promise.all(members.map((member) => member.delete()))
          )
      );

      // delete subjects subcollection
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .doc(groupDocId)
          .collection("subjects")
          .listDocuments()
          .then((subjects) =>
            Promise.all(subjects.map((subject) => subject.delete()))
          )
      );

      // delete timetables subcollection
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .doc(groupDocId)
          .collection("timetables")
          .listDocuments()
          .then((timetables) =>
            Promise.all(timetables.map((timetable) => timetable.delete()))
          )
      );

      return Promise.all(promises);
    }
  });
