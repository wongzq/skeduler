import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {
  TimetableGridData,
  Timetable,
  TimetableGroup,
} from "../models/custom_classes";

export const createGroupSubject = functions.firestore
  .document("/groups/{groupDocId}/subjects/{subjectDocId}")
  .onCreate(async (snapshot, context) => {
    const groupDocId: string = context.params.groupDocId;
    const subjectSnap:
      | FirebaseFirestore.DocumentData
      | undefined = snapshot.data();

    if (subjectSnap === undefined || subjectSnap === null) {
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

    if (subjectSnap === undefined || subjectSnap === null) {
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

export const updateGroupSubject = functions.firestore
  .document("/groups/{groupDocId}/subjects/{subjectDocId}")
  .onUpdate(async (change, context) => {
    const groupDocId: string = context.params.groupDocId;
    const subjectDocId: string = context.params.subjectDocId;

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
    } else {
      const promises: Promise<any>[] = [];

      // check nickname changed
      if (beforeData.nickname !== afterData.nickname) {
        promises.push(
          validateSubjectNickname({
            groupDocId: groupDocId,
            subjectDocId: subjectDocId,
            nickname: afterData.nickname,
          })
        );
      }

      return Promise.all(promises);
    }
  });

interface ValidateSubjectNicknameArgs {
  groupDocId: string;
  subjectDocId: string;
  nickname: string;
}

export async function validateSubjectNickname({
  groupDocId,
  subjectDocId,
  nickname,
}: ValidateSubjectNicknameArgs): Promise<any> {
  if (groupDocId === undefined || groupDocId === null) {
    return null;
  } else {
    const promises: Promise<any>[] = [];

    const timetables: Timetable[] = await admin
      .firestore()
      .collection("groups")
      .doc(groupDocId)
      .collection("timetables")
      .get()
      .then((timetablesQuery) =>
        timetablesQuery.docs.map((timetableQueryDoc) =>
          Timetable.fromFirestoreDocument(timetableQueryDoc)
        )
      );

    // iterate through timetables
    for (const timetable of timetables) {
      const newGroups: TimetableGroup[] = timetable.groups.map((value) =>
        TimetableGroup.from(value)
      );

      // iterate through groups
      for (const group of timetable.groups) {
        const newGroup: TimetableGroup = TimetableGroup.from(group);

        // iterate through gridDataList
        for (const gridData of group.gridDataList) {
          if (gridData.subject.docId === subjectDocId) {
            // new grid data
            const newGridData: TimetableGridData = TimetableGridData.from(
              gridData
            );
            newGridData.subject.display = nickname;

            // remove old gridData in gridDataList
            newGroup.gridDataList = newGroup.gridDataList.filter((value) =>
              value.notEqual(gridData)
            );
            // add new gridData to gridDataList
            newGroup.gridDataList.push(newGridData);
          }
        }

        // update group
        const groupIndex: number = timetable.groups.indexOf(group);
        newGroups.splice(groupIndex, 1, newGroup);
      }

      // update in firestore
      promises.push(
        admin
          .firestore()
          .collection("groups")
          .doc(groupDocId)
          .collection("timetables")
          .doc(timetable.docId)
          .update({
            groups: newGroups.map((group) => group.asFirestoreMap()),
          })
      );
    }

    return Promise.all(promises);
  }
}
