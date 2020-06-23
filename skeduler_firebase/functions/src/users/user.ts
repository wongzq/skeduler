import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const updateUserName = functions.firestore
  .document("/users/{userDocId}")
  .onUpdate(async (change, context) => {
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
    } else if (beforeData.name !== afterData.name) {
      const userDocId = context.params.userDocId;
      const promises: Promise<any>[] = [];

      // update group owner
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .where("owner", "==", {
            email: change.before.id,
            name: beforeData.name,
          })
          .get()
          .then(async (groupsSnap) => {
            const updateGroupPromises: Promise<any>[] = [];
            groupsSnap.forEach(async (groupDocSnap) => {
              updateGroupPromises.push(
                groupDocSnap.ref.update({
                  owner: {
                    email: change.after.id,
                    name: afterData.name,
                  },
                })
              );
            });
          })
      );

      // update group member
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .where("members", "array-contains", userDocId)
          .get()
          .then(async (groupsSnap) => {
            const updateGroupMemberPromises: Promise<any>[] = [];
            groupsSnap.forEach(async (groupDocSnap) => {
              updateGroupMemberPromises.push(
                groupDocSnap.ref
                  .collection("members")
                  .doc(userDocId)
                  .update({ name: afterData.name })
              );
              return Promise.all(updateGroupMemberPromises);
            });
          })
      );

      return Promise.all(promises);
    } else {
      return null;
    }
  });
