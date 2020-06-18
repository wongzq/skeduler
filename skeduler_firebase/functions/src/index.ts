import * as admin from "firebase-admin";
admin.initializeApp();

export * from "./users/user";
export * from "./groups/group";
export * from "./groups/group_member";
export * from "./groups/group_subject";
export * from "./groups/group_timetable";
export * from "./groups/group_timetable_group";
