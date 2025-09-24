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

    // Build update data dynamically
    const updateData: Partial<UpdateUserDto> = {};
    if (body.height !== undefined) updateData.height = body.height;
    if (body.weight !== undefined) updateData.weight = body.weight;
    if (body.gender !== undefined) updateData.gender = body.gender;
    if (body.activityLevel !== undefined)
      updateData.activityLevel = body.activityLevel;

    // Run update query
    const updatedUsers = await db
      .update(users)
      .set(updateData)
      .where(eq(users.id, userId))
      .returning();

    if (!updatedUsers.length) {
      return HttpResponse.notFound("User not found").toAzureResponse();
    }

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
