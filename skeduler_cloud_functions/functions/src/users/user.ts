import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const updateUserName = functions.firestore
  .document("/users/{userDocId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

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
          .then(async (snapshot) => {
            const updateGroupPromises: Promise<any>[] = [];
            snapshot.forEach(async (group) => {
              updateGroupPromises.push(
                group.ref.update({
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
          .then(async (querySnapshot) => {
            const updateGroupMemberPromises: Promise<any>[] = [];
            querySnapshot.forEach(async (groupDoc) => {
              updateGroupMemberPromises.push(
                groupDoc.ref
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
