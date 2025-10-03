// ============================
// Constants from env
// ============================
export const DB_URL = process.env.DB_URL;

// Enums

export enum MealType {
  BREAKFAST = "breakfast",
  LUNCH = "lunch",
  DINNER = "dinner",
  SNACK = "snack",
}

export enum ActivityType {
  RUNNING = "running",
  GYM = "gym",
  CYCLING = "cycling",
  SWIMMING = "swimming",
  WALKING = "walking",
  OTHER = "other",
}

export enum ActivityLevel {
  SEDENTARY = "sedentary",
  ACTIVE = "active",
  VERY_ACTIVE = "very_active",
}

export enum Gender {
  MALE = "male",
  FEMALE = "female",
  OTHER = "other",
}
