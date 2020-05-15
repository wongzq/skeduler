import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const updateUserName = functions.firestore
  .document("/users/{userDocId}")
  .onUpdate(async (change, context) => {
    const before:
      | FirebaseFirestore.DocumentData
      | undefined = change.before.data();
    const after:
      | FirebaseFirestore.DocumentData
      | undefined = change.after.data();

    if (before == null || after == null) {
      return null;
    } else if (before.name != after.name) {
      const userDocId = context.params.userDocId;
      const promises: Promise<any>[] = [];

      // update group owner
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .where("owner", "==", { email: change.before.id, name: before.name })
          .get()
          .then(async (groupsSnap) => {
            const updateGroupPromises: Promise<any>[] = [];
            groupsSnap.forEach(async (groupDocSnap) => {
              updateGroupPromises.push(
                groupDocSnap.ref.update({
                  owner: {
                    email: change.after.id,
                    name: after.name,
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
                  .update({ name: after.name })
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
