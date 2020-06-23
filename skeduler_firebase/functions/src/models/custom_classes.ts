import * as admin from "firebase-admin";

// used classes

export class Time {
  // attributes
  startTime: FirebaseFirestore.Timestamp;
  endTime: FirebaseFirestore.Timestamp;

  // constructors
  constructor(
    startTime: FirebaseFirestore.Timestamp,
    endTime: FirebaseFirestore.Timestamp
  ) {
    this.startTime = startTime;
    this.endTime = endTime;
  }

  static from(time: Time): Time {
    return new Time(time.startTime, time.endTime);
  }

  // getter methods
  get startDate(): Date {
    return this.startTime.toDate();
  }

  get endDate(): Date {
    return this.endTime.toDate();
  }

  // methods
  sameDateAsIgnoreTime(time: Time): boolean {
    return (
      this.startDate.getFullYear() === time.startDate.getFullYear() &&
      this.startDate.getMonth() === time.startDate.getMonth() &&
      this.startDate.getDate() === time.startDate.getDate() &&
      this.endDate.getFullYear() === time.endDate.getFullYear() &&
      this.endDate.getMonth() === time.endDate.getMonth() &&
      this.endDate.getDate() === time.endDate.getDate()
    );
  }

  withinDateTimeOf(time: Time): boolean {
    return this.startDate >= time.startDate && this.endDate <= time.endDate;
  }

  notWithinDateTimeOf(time: Time): boolean {
    return this.endDate <= time.startDate || this.startDate >= time.endDate;
  }

  withinTimeOf(time: Time): boolean {
    const tmpStartDate = new Date(
      this.startDate.getUTCFullYear(),
      this.startDate.getUTCMonth(),
      this.startDate.getUTCDate(),
      time.startDate.getUTCHours(),
      time.startDate.getUTCMinutes()
    );

    const tmpEndDate = new Date(
      this.endDate.getUTCFullYear(),
      this.endDate.getUTCMonth(),
      this.endDate.getUTCDate(),
      time.endDate.getUTCHours(),
      time.endDate.getUTCMinutes()
    );

    return this.startDate >= tmpStartDate && this.endDate <= tmpEndDate;
  }

  notWithinTimeOf(time: Time): boolean {
    const tmpStartDate = new Date(
      this.startDate.getUTCFullYear(),
      this.startDate.getUTCMonth(),
      this.startDate.getUTCDate(),
      time.startDate.getUTCHours(),
      time.startDate.getUTCMinutes()
    );

    const tmpEndDate = new Date(
      this.endDate.getUTCFullYear(),
      this.endDate.getUTCMonth(),
      this.endDate.getUTCDate(),
      time.endDate.getUTCHours(),
      time.endDate.getUTCMinutes()
    );

    return this.endDate <= tmpStartDate || this.startDate >= tmpEndDate;
  }

  isEqual(time: Time): boolean {
    return (
      this.startTime.isEqual(time.startTime) &&
      this.endTime.isEqual(time.endTime)
    );
  }

  notEqual(time: Time): boolean {
    return !this.isEqual(time);
  }

  asFirestoreMap(): any {
    return { startTime: this.startTime, endTime: this.endTime };
  }

  // static functions
  static daysInMonth(year: number, month: number): number {
    return new Date(year, month + 1, 0).getDate();
  }

  static generateTimes(
    months: number[],
    weekdays: number[],
    time: Time,
    startDate: Date,
    endDate: Date
  ): Time[] {
    endDate.setDate(endDate.getDate() + 1);

    const times: Time[] = [];

    // iterate through each month
    for (const month of months) {
      // iterate through each day
      const year: number = new Date(Date.now()).getUTCFullYear();

      for (let day = 0; day < Time.daysInMonth(year, month); day++) {
        const newTime: Date = new Date(year, month, day);

        // iterate through each weekday
        for (const weekday of weekdays) {
          if (newTime.getDay() === weekday + 1) {
            const newStartTime: Date = new Date(
              newTime.getUTCFullYear(),
              newTime.getUTCMonth(),
              newTime.getUTCDate(),
              time.startDate.getUTCHours(),
              time.startDate.getUTCMinutes()
            );

            const newEndTime: Date = new Date(
              newTime.getUTCFullYear(),
              newTime.getUTCMonth(),
              newTime.getUTCDate(),
              time.endDate.getUTCHours(),
              time.endDate.getUTCMinutes()
            );

            if (newStartTime >= startDate && newEndTime <= endDate) {
              times.push(
                new Time(
                  admin.firestore.Timestamp.fromDate(newStartTime),
                  admin.firestore.Timestamp.fromDate(newEndTime)
                )
              );
            }
          }
        }
      }
    }

    return times;
  }
}

export class Member {
  docId: string;
  alwaysAvailable: boolean;
  name: string;
  nickname: string;
  role: number;
  timesAvailable: Time[];
  timesUnavailable: Time[];

  constructor(
    docId: string,
    alwaysAvailable: boolean,
    name: string,
    nickname: string,
    role: number,
    timesAvailable: any,
    timesUnavailable: any
  ) {
    this.docId = docId;
    this.alwaysAvailable = alwaysAvailable;
    this.name = name;
    this.nickname = nickname;
    this.role = role;
    this.timesAvailable = [];
    this.timesUnavailable = [];

    if (timesAvailable !== null) {
      for (let time of timesAvailable) {
        this.timesAvailable.push(new Time(time.startTime, time.endTime));
      }
    }

    if (timesUnavailable !== null) {
      for (let time of timesUnavailable) {
        this.timesUnavailable.push(new Time(time.startTime, time.endTime));
      }
    }
  }

  static fromFirestoreDocument(
    snapshot: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>
  ): Member {
    return new Member(
      snapshot.id,
      snapshot.data()!.alwaysAvailable,
      snapshot.data()!.name,
      snapshot.data()!.nickname,
      snapshot.data()!.role,
      snapshot.data()!.timesAvailable,
      snapshot.data()!.timesUnavailable
    );
  }
}

export class Timetable {
  docId: string;
  startTimestamp: FirebaseFirestore.Timestamp;
  endTimestamp: FirebaseFirestore.Timestamp;
  groups: TimetableGroup[];

  constructor(
    docId: string,
    startTimestamp: FirebaseFirestore.Timestamp,
    endTimestamp: FirebaseFirestore.Timestamp,
    groups: any[]
  ) {
    this.docId = docId;
    this.startTimestamp = startTimestamp;
    this.endTimestamp = endTimestamp;
    this.groups = groups ?? [];
  }

  static fromFirestoreDocument(
    snapshot: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>
  ): Timetable {
    return new Timetable(
      snapshot.id,
      snapshot.data()!.startDate,
      snapshot.data()!.endDate,
      (snapshot.data()!.groups as any[]).map((value) =>
        TimetableGroup.fromFirestoreArrayValue(value)
      )
    );
  }

  get startDate(): Date {
    return this.startTimestamp.toDate();
  }

  get endDate(): Date {
    return this.endTimestamp.toDate();
  }
}

export class TimetableGroup {
  axisDay: any[];
  axisTime: any[];
  axisCustom: any[];
  gridDataList: TimetableGridData[];

  constructor(
    axisDay: any[],
    axisTime: any[],
    axisCustom: any[],
    gridDataList: TimetableGridData[]
  ) {
    this.axisDay = axisDay ?? [];
    this.axisTime = axisTime ?? [];
    this.axisCustom = axisCustom ?? [];
    this.gridDataList = gridDataList ?? [];
  }

  static from(group: TimetableGroup): TimetableGroup {
    return new TimetableGroup(
      group.axisDay,
      group.axisTime,
      group.axisCustom,
      group.gridDataList
    );
  }

  static fromFirestoreArrayValue(value: any): TimetableGroup {
    return new TimetableGroup(
      value.axisDay as any[],
      value.axisTime as any[],
      value.axisCustom as any[],
      (value.gridDataList as any[]).map((gridData) =>
        TimetableGridData.fromFirestoreField(gridData)
      )
    );
  }

  asFirestoreMap(): any {
    return {
      axisDay: this.axisDay ?? [],
      axisTime: this.axisTime ?? [],
      axisCustom: this.axisCustom ?? [],
      gridDataList:
        this.gridDataList.map((gridData) => gridData.asFirestoreMap()) ?? [],
    };
  }
}

export class TimetableGridData {
  ignore: boolean;
  available: boolean;
  coord: {
    day: number;
    time: {
      startTime: Date;
      endTime: Date;
    };
    custom: string;
  };
  member: {
    docId: string;
    display: string;
  };
  subject: {
    docId: string;
    display: string;
  };

  constructor(
    ignore: boolean,
    available: boolean,
    day: number,
    timeStartTime: Date,
    timeEndTime: Date,
    custom: string,
    memberDocId: string,
    memberDisplay: string,
    subjectDocId: string,
    subjectDisplay: string
  ) {
    this.ignore = ignore;
    this.available = available;
    this.coord = {
      day: day,
      time: { startTime: timeStartTime, endTime: timeEndTime },
      custom: custom,
    };
    this.member = { docId: memberDocId, display: memberDisplay };
    this.subject = { docId: subjectDocId, display: subjectDisplay };
  }

  static from(gridData: TimetableGridData): TimetableGridData {
    return new TimetableGridData(
      gridData.ignore,
      gridData.available,
      gridData.coord.day,
      gridData.coord.time.startTime,
      gridData.coord.time.endTime,
      gridData.coord.custom,
      gridData.member.docId,
      gridData.member.display,
      gridData.subject.docId,
      gridData.subject.display
    );
  }
  
  static fromFirestoreField(gridData: any): TimetableGridData {
    return new TimetableGridData(
      gridData.ignore,
      gridData.available,
      gridData.coord.day,
      gridData.coord.time.startTime.toDate(),
      gridData.coord.time.endTime.toDate(),
      gridData.coord.custom,
      gridData.member.docId,
      gridData.member.display,
      gridData.subject.docId,
      gridData.subject.display
    );
  }

  isEqual(gridData: TimetableGridData): boolean {
    return (
      this.ignore === gridData.ignore &&
      this.available === gridData.available &&
      this.coord.day === gridData.coord.day &&
      this.coord.time.startTime.valueOf() ==
        gridData.coord.time.startTime.valueOf() &&
      this.coord.time.endTime.valueOf() ==
        gridData.coord.time.endTime.valueOf() &&
      this.coord.custom === gridData.coord.custom &&
      this.member.docId === gridData.member.docId &&
      this.member.display === gridData.member.display &&
      this.subject.docId === gridData.subject.docId &&
      this.subject.display === gridData.subject.display
    );
  }

  notEqual(gridData: TimetableGridData): boolean {
    return !this.isEqual(gridData);
  }

  asFirestoreMap(): any {
    return {
      ignore: this.ignore,
      available: this.available,
      coord: {
        day: this.coord.day,
        time: {
          startTime: this.coord.time.startTime,
          endTime: this.coord.time.endTime,
        },
        custom: this.coord.custom,
      },
      member: {
        docId: this.member.docId,
        display: this.member.display,
      },
      subject: {
        docId: this.subject.docId,
        display: this.subject.display,
      },
    };
  }
}

export class Conflict {
  timetable: string;
  groupIndex: number;
  gridData: TimetableGridData;
  member: { docId: string; name: string; nickname: string };
  conflictDates: FirebaseFirestore.Timestamp[];

  constructor(
    timetable: string,
    groupIndex: number,
    gridData: TimetableGridData,
    memberDocId: string,
    memberName: string,
    memberNickname: string,
    conflictDates: FirebaseFirestore.Timestamp[]
  ) {
    this.timetable = timetable;
    this.groupIndex = groupIndex;
    this.gridData = gridData;
    this.member = {
      docId: memberDocId,
      name: memberName,
      nickname: memberNickname,
    };
    this.conflictDates = conflictDates ?? [];
  }

  static create(
    timetable: string,
    groupIndex: number,
    gridData: TimetableGridData,
    memberDocId: string,
    memberName: string,
    memberNickname: string,
    conflictDates: Date[]
  ): Conflict {
    const conflictTimestamps: FirebaseFirestore.Timestamp[] = [];

    for (const date of conflictDates) {
      conflictTimestamps.push(admin.firestore.Timestamp.fromDate(date));
    }

    return new Conflict(
      timetable,
      groupIndex,
      gridData,
      memberDocId,
      memberName,
      memberNickname,
      conflictTimestamps
    );
  }

  static fromFirestoreField(conflict: any) {
    return new Conflict(
      conflict.timetable,
      conflict.groupIndex,
      TimetableGridData.fromFirestoreField(conflict.gridData),
      conflict.member.docId,
      conflict.member.name,
      conflict.member.nickname,
      conflict.conflictDates
    );
  }

  static from(conflict: Conflict) {
    return new Conflict(
      conflict.timetable,
      conflict.groupIndex,
      conflict.gridData,
      conflict.member.docId,
      conflict.member.name,
      conflict.member.nickname,
      conflict.conflictDates
    );
  }

  asFirestoreMap(): any {
    return {
      timetable: this.timetable ?? "",
      groupIndex: this.groupIndex ?? 0,
      gridData: this.gridData.asFirestoreMap(),
      member: {
        docId: this.member.docId ?? "",
        name: this.member.name ?? "",
        nickname: this.member.nickname ?? "",
      },
      conflictDates: this.conflictDates ?? [],
    };
  }
}

// unused classes
// export class Group {
//   docId: string;
//   name: string;
//   description: string;
//   colorShade: ColorShade;
//   owner: Owner;
//   members: Array<string>;
//   subjects: Array<Subject>;
//   timetableMetadatas: Array<TimetableMetadata>;

//   constructor(
//     docId: string,
//     name: string,
//     description: string,
//     colorShade: ColorShade,
//     owner: Owner,
//     members: Array<string>,
//     subjects: Array<Subject>,
//     timetableMetadatas: Array<TimetableMetadata>
//   ) {
//     this.docId = docId;
//     this.name = name;
//     this.description = description;
//     this.colorShade = colorShade;
//     this.owner = owner;
//     this.members = members;
//     this.subjects = subjects;
//     this.timetableMetadatas = timetableMetadatas;
//   }
// }

// export class Subject {
//   docId: string;
//   name: string;
//   nickname: string;

//   constructor(docId: string, name: string, nickname: string) {
//     this.docId = docId;
//     this.name = name;
//     this.nickname = nickname;
//   }
// }

// export class TimetableMetadata {
//   id: string;
//   startDate: Date;
//   endDate: Date;

//   constructor(id: string, startDate: Date, endDate: Date) {
//     this.id = id;
//     this.startDate = startDate;
//     this.endDate = endDate;
//   }
// }

// export class ColorShade {
//   themeId: string;
//   shadeIndex: number;

//   constructor(themeId: string, shadeIndex: number) {
//     this.themeId = themeId;
//     this.shadeIndex = shadeIndex;
//   }
// }

// export class Owner {
//   email: string;
//   name: string;

//   constructor(email: string, name: string) {
//     this.email = email;
//     this.name = name;
//   }
// }
