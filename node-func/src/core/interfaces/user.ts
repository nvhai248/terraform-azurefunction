import { ActivityLevel, Gender } from "../const";

export interface IUser {
  id: string;
  fullName?: string;
  age?: number;
  gender?: Gender;
  weight?: number;
  height?: number;
  bmi?: number;
  activityLevel?: ActivityLevel;
  dailyCalories?: number;
  allergies?: string; // or string[]
  preferences?: string; // or string[]
  avatarUrl?: string;
  createdAt: Date;
  updatedAt: Date;
}
