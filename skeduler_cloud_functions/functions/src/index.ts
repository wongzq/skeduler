import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const helloWorld = functions.https.onRequest((request, response) => {
  response.send("Hello from Firebase!");
});

export const userNameUpdated = functions.firestore
  .document("/users/{userDocId}")
  .onUpdate((change) => {
    const after = change.after.data();

    const payload = {
      data: {
        temp: String(after!.temp),
        conditions: after!.conditions,
      },
    };

    return admin
      .messaging()
      .sendToTopic("user name changed", payload)
      .catch((error) => {
        console.error()
      });
  });
