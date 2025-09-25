import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, HttpResponse } from "../../core/utils";
import { UpdateUserDto } from "../../core/dtos/user";
import { eq } from "drizzle-orm";
import { db } from "../../core/db/client";
import { users } from "../../core/db/schema";
import { differenceInYears } from "date-fns";
import { calculateBMI, calculateDailyCalories } from "../../core/libs/user-lib";

/**
 * @openapi
 * /api/users:
 *   put:
 *     summary: Update user profile
 *     description: |
 *       Update user profile fields (height, weight, gender, activityLevel).
 *       The user is identified from the `Authorization` bearer token.
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateUserDto'
 *     responses:
 *       200:
 *         description: User successfully updated
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 height:
 *                   type: number
 *                 weight:
 *                   type: number
 *                 gender:
 *                   type: string
 *                   enum: [male, female, other]
 *                 activityLevel:
 *                   type: string
 *                   enum: [sedentary, active, very_active]
 *       400:
 *         description: Invalid request body
 *       401:
 *         description: Unauthorized (missing or invalid token)
 *       500:
 *         description: Internal server error
 */
export async function updateUser(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  const token = AuthUtils.extractToken(request);
  const userId = AuthUtils.getUserId(token);
  if (!userId)
    return HttpResponse.unauthorized("Invalid token").toAzureResponse();

  try {
    const body = (await request.json()) as UpdateUserDto;

    // Fetch current user (to get dateOfBirth, gender if not provided)
    const existingUser = await db.query.users.findFirst({
      where: eq(users.id, userId),
    });
    if (!existingUser) {
      return HttpResponse.notFound("User not found").toAzureResponse();
    }

    const updateData: any = {};

    if (body.height !== undefined) updateData.height = body.height;
    if (body.weight !== undefined) updateData.weight = body.weight;
    if (body.gender !== undefined) updateData.gender = body.gender;
    if (body.activityLevel !== undefined)
      updateData.activityLevel = body.activityLevel;
    if (body.avatarUrl !== undefined) updateData.avatarUrl = body.avatarUrl;
    if (body.allergies !== undefined) updateData.allergies = body.allergies;
    if (body.preferences !== undefined)
      updateData.dietaryPreference = body.preferences.join(",");

    // ---- Auto-calculated fields ----
    const gender = updateData.gender ?? existingUser.gender;
    const weight = updateData.weight ?? existingUser.weight;
    const height = updateData.height ?? existingUser.height;
    const activityLevel =
      updateData.activityLevel ?? existingUser.activityLevel;

    // Calculate age from dateOfBirth
    const dob = existingUser.dateOfBirth;
    const age = dob ? differenceInYears(new Date(), new Date(dob)) : undefined;

    // Calculate BMI
    const bmi = calculateBMI(weight, height);
    if (bmi) updateData.bmi = bmi;

    // Calculate daily calories
    const dailyCalorieGoal = calculateDailyCalories(
      gender,
      weight,
      height,
      age,
      activityLevel
    );
    if (dailyCalorieGoal) updateData.dailyCalorieGoal = dailyCalorieGoal;

    // Always update updatedAt
    updateData.updatedAt = new Date();

    // Run update query
    const updatedUsers = await db
      .update(users)
      .set(updateData)
      .where(eq(users.id, userId))
      .returning();

    return HttpResponse.ok(updatedUsers[0]).toAzureResponse();
  } catch (err) {
    context.log("Error updating user:", (err as Error).message);
    return HttpResponse.internalError().toAzureResponse();
  }
}

app.http("updateUser", {
  methods: ["PUT"],
  authLevel: "anonymous",
  handler: updateUser,
});
