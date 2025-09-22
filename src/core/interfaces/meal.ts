import { MealType } from "../const";

export interface IMeal {
  id: string;
  userId: string;
  name?: string;
  imageUrl?: string;
  calories?: number;
  protein?: number;
  carbs?: number;
  fat?: number;
  mealType?: MealType;
  createdAt: Date;
}
