import * as functions from "firebase-functions";
import { validateConflicts } from "./group";

export const updateGroupTimetableGroup = functions.firestore
  .document(
    "/groups/{groupDocId}/timetables/{timetableDocId}/groups/{timetableGroupDocId}"
  )
  .onUpdate(async (change, context) => {
    const groupDocId: string = context.params.groupDocId;
    const timetableDocId: string = context.params.timetableDocId;

    const beforeData:
      | FirebaseFirestore.DocumentData
      | undefined = change.before.data();
    const afterData:
      | FirebaseFirestore.DocumentData
      | undefined = change.after.data();

    if (beforeData == null || afterData == null) {
      return null;
    } else {
      const promises: Promise<any>[] = [];

      promises.push(
        validateConflicts({
          groupDocId: groupDocId,
          timetableDocId: timetableDocId,
        })
      );

      return Promise.all(promises);
    }
  });
