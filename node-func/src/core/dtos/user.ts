import { ActivityLevel, Gender } from "../const";

export interface UpdateUserDto {
  age?: number;
  gender?: Gender;
  weight?: number;
  height?: number;
  activityLevel?: ActivityLevel;
  dailyCalories?: number;
  allergies?: string[];
  preferences?: string[];
  avatarUrl?: string;
}
