CREATE TABLE "activities" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" varchar,
	"type" text NOT NULL,
	"duration_min" integer,
	"calories" integer,
	"logged_at" timestamp (3) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "meals" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" varchar,
	"image_url" text NOT NULL,
	"description" text,
	"calories" integer,
	"protein" real,
	"fat" real,
	"carbs" real,
	"detected_at" timestamp (3) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" varchar PRIMARY KEY NOT NULL,
	"date_of_birth" timestamp,
	"gender" text,
	"phone_number" varchar(20),
	"avatar_url" text,
	"height" real,
	"weight" real,
	"target_weight" real,
	"bmi" real,
	"activity_level" text,
	"allergies" text[] DEFAULT '{}',
	"medical_history" text,
	"dietary_preference" text,
	"daily_calorie_goal" integer,
	"created_at" timestamp (3) DEFAULT now(),
	"updated_at" timestamp (3) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "weight_logs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" varchar,
	"weight" real NOT NULL,
	"logged_at" timestamp (3) DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "activities" ADD CONSTRAINT "activities_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "meals" ADD CONSTRAINT "meals_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "weight_logs" ADD CONSTRAINT "weight_logs_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;