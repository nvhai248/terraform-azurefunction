import { ActivityType } from "../const";

export interface IActivity {
  id: string;
  userId: string;
  type: ActivityType;
  duration?: number; // minutes
  calories?: number;
  createdAt: Date;
}
