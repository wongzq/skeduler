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