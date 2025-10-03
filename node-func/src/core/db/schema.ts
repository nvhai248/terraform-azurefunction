import {
  pgTable,
  text,
  varchar,
  uuid,
  timestamp,
  real,
  integer,
  pgEnum,
} from "drizzle-orm/pg-core";
import { MealType } from "../const";

// Users table
export const users = pgTable("users", {
  id: varchar("id").primaryKey(),

  dateOfBirth: timestamp("date_of_birth", { mode: "date" }),
  gender: text("gender"),
  phoneNumber: varchar("phone_number", { length: 20 }),
  avatarUrl: text("avatar_url"),

  height: real("height"),
  weight: real("weight"),
  targetWeight: real("target_weight"),
  bmi: real("bmi"),
  activityLevel: text("activity_level"),
  allergies: text("allergies").array().default([]),
  medicalHistory: text("medical_history"),

  dietaryPreference: text("dietary_preference"),
  dailyCalorieGoal: integer("daily_calorie_goal"),

  createdAt: timestamp("created_at", {
    mode: "date",
    precision: 3,
  }).defaultNow(),
  updatedAt: timestamp("updated_at", {
    mode: "date",
    precision: 3,
  }).defaultNow(),
});

// map MealType enum to a PostgreSQL enum
export const mealTypeEnum = pgEnum("meal_type", [
  MealType.BREAKFAST,
  MealType.LUNCH,
  MealType.DINNER,
  MealType.SNACK,
]);

// Meals
export const meals = pgTable("meals", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: varchar("user_id").references(() => users.id, {
    onDelete: "cascade",
  }),
  imageUrl: text("image_url").notNull(),
  name: varchar("name", { length: 255 }),
  description: text("description"),
  mealType: mealTypeEnum("meal_type"),
  calories: integer("calories"),
  protein: real("protein"),
  fat: real("fat"),
  carbs: real("carbs"),
  detectedAt: timestamp("detected_at", {
    mode: "date",
    precision: 3,
  }).defaultNow(),
});

// Weight logs
export const weightLogs = pgTable("weight_logs", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: varchar("user_id").references(() => users.id),
  weight: real("weight").notNull(),
  loggedAt: timestamp("logged_at", { mode: "date", precision: 3 }).defaultNow(),
});

// Activities
export const activities = pgTable("activities", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: varchar("user_id").references(() => users.id),
  type: text("type").notNull(),
  durationMin: integer("duration_min"),
  calories: integer("calories"),
  loggedAt: timestamp("logged_at", { mode: "date", precision: 3 }).defaultNow(),
});
