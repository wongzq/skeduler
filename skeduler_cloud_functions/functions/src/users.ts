import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const userNameUpdated = functions.firestore
  .document("/users/{userDocId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before === null || after === null) {
      return null;
    } else if (before!.name !== after!.name) {
      const userDocId = context.params.userDocId;
      const groupsColRef = admin.firestore().collection("groups");

      const querySnapshot = await groupsColRef
        .where("members", "array-contains", userDocId)
        .get();

      const promises: Array<Promise<any>> = [];

      querySnapshot.forEach(async (groupDoc) => {
        promises.push(
          groupDoc.ref
            .collection("members")
            .doc(userDocId)
            .update({ name: after!.name })
        );
      });

      return Promise.all(promises);
    } else {
      return null;
    }
  });
