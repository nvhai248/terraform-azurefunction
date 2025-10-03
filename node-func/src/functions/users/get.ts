import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, HttpResponse } from "../../core/utils";
import { eq } from "drizzle-orm";
import { db } from "../../core/db/client";
import { users } from "../../core/db/schema";

/**
 * @openapi
 * /api/users/me:
 *   get:
 *     summary: Get current user profile
 *     description: |
 *       Retrieves the authenticated user's profile information based on
 *       the `Authorization` bearer token.
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                   example: "12345678-abcd-efgh-9876-abcdef123456"
 *                 age:
 *                   type: number
 *                   example: 25
 *                 gender:
 *                   type: string
 *                   enum: [MALE, FEMALE, OTHER]
 *                 height:
 *                   type: number
 *                   example: 170
 *                 weight:
 *                   type: number
 *                   example: 65
 *                 activityLevel:
 *                   type: string
 *                   enum: [SEDENTARY, LIGHT, MODERATE, ACTIVE, VERY_ACTIVE]
 *                 dailyCalories:
 *                   type: number
 *                   example: 2200
 *                 allergies:
 *                   type: array
 *                   items:
 *                     type: string
 *                   example: ["peanuts", "gluten"]
 *                 preferences:
 *                   type: array
 *                   items:
 *                     type: string
 *                   example: ["vegan", "low-carb"]
 *                 avatarUrl:
 *                   type: string
 *                   format: uri
 *                   example: "https://cdn.example.com/avatars/123.png"
 *       401:
 *         description: Unauthorized (missing or invalid token)
 *       404:
 *         description: User not found
 *       500:
 *         description: Internal server error
 */
export async function getUser(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  const token = AuthUtils.extractToken(request);
  const userId = AuthUtils.getUserId(token);
  if (!userId) {
    return HttpResponse.unauthorized("Invalid token").toAzureResponse();
  }

  try {
    const user = await db.query.users.findFirst({
      where: eq(users.id, userId),
    });

    if (!user) {
      return HttpResponse.notFound("User not found").toAzureResponse();
    }

    return HttpResponse.ok(user).toAzureResponse();
  } catch (err) {
    context.log("Error fetching user:", (err as Error).message);
    return HttpResponse.internalError().toAzureResponse();
  }
}

app.http("getUser", {
  methods: ["GET"],
  authLevel: "anonymous",
  route: "users/me",
  handler: getUser,
});
