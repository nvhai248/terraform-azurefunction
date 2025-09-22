import { ActivityType } from "../const";

export interface CreateActivityDto {
  userId: string;
  type: ActivityType;
  duration?: number;
  calories?: number;
}

export interface UpdateActivityDto {
  type?: string;
  duration?: number;
  calories?: number;
}
