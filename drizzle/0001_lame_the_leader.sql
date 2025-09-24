CREATE TYPE "public"."meal_type" AS ENUM('breakfast', 'lunch', 'dinner', 'snack');--> statement-breakpoint
ALTER TABLE "meals" ADD COLUMN "name" varchar(255);--> statement-breakpoint
ALTER TABLE "meals" ADD COLUMN "meal_type" "meal_type";