export class TimetableGridData {
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
    this.available = available;
    this.coord = {
      day: day,
      time: { startTime: timeStartTime, endTime: timeEndTime },
      custom: custom,
    };
    this.member = { docId: memberDocId, display: memberDisplay };
    this.subject = { docId: subjectDocId, display: subjectDisplay };
  }

  asFirestoreMap(): any {
    return {
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

export class Group {
  docId: string;
  name: string;
  description: string;
  colorShade: ColorShade;
  owner: Owner;
  members: Array<string>;
  subjects: Array<Subject>;
  timetableMetadatas: Array<TimetableMetadata>;

  constructor(
    docId: string,
    name: string,
    description: string,
    colorShade: ColorShade,
    owner: Owner,
    members: Array<string>,
    subjects: Array<Subject>,
    timetableMetadatas: Array<TimetableMetadata>
  ) {
    this.docId = docId;
    this.name = name;
    this.description = description;
    this.colorShade = colorShade;
    this.owner = owner;
    this.members = members;
    this.subjects = subjects;
    this.timetableMetadatas = timetableMetadatas;
  }
}

export class Subject {
  name: string;
  nickname: string;

  constructor(name: string, nickname: string) {
    this.name = name;
    this.nickname = nickname;
  }
}

export class TimetableMetadata {
  id: string;
  startDate: Date;
  endDate: Date;

  constructor(id: string, startDate: Date, endDate: Date) {
    this.id = id;
    this.startDate = startDate;
    this.endDate = endDate;
  }
}

export class ColorShade {
  themeId: string;
  shadeIndex: number;

  constructor(themeId: string, shadeIndex: number) {
    this.themeId = themeId;
    this.shadeIndex = shadeIndex;
  }
}

export class Owner {
  email: string;
  name: string;

  constructor(email: string, name: string) {
    this.email = email;
    this.name = name;
  }
}
