import { MealType } from "../const";

export interface CreateMealDto {
  userId: string;
  name?: string;
  imageUrl?: string;
  calories?: number;
  protein?: number;
  carbs?: number;
  fat?: number;
  mealType?: MealType;
}

export interface UpdateMealDto {
  name?: string;
  imageUrl?: string;
  calories?: number;
  protein?: number;
  carbs?: number;
  fat?: number;
  mealType?: MealType;
}
