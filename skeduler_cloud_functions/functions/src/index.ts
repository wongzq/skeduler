import * as firebaseAdmin from "firebase-admin";
firebaseAdmin.initializeApp();

exports.users = require("./users");
exports.groupMembers = require("./group_members");
