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
 * /api/createUser:
 *   post:
 *     summary: Create a new user based on JWT token
 *     description: |
 *       This endpoint creates a new `User` record in the database using the
 *       user identifier (`oid` or `sub`) from the JWT access token.
 *       If the user already exists, it will return the existing user.
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User created or already exists
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                   example: "12345678-abcd-efgh-9876-abcdef123456"
 *       400:
 *         description: Invalid JWT token
 *       401:
 *         description: Missing or invalid Authorization header
 *       500:
 *         description: Internal server error
 */
export async function createUser(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  const token = AuthUtils.extractToken(request);

  try {
    const userId = AuthUtils.getUserId(token);
    if (!userId) {
      return HttpResponse.unauthorized("Invalid token").toAzureResponse();
    }

    // Check if user exists
    const existing = await db
      .select()
      .from(users)
      .where(eq(users.id, userId))
      .limit(1);

    let user;
    if (existing.length > 0) {
      user = existing[0];
    } else {
      // Insert new user
      const inserted = await db
        .insert(users)
        .values({ id: userId })
        .returning();
      user = inserted[0];
    }

    return HttpResponse.ok(user).toAzureResponse();
  } catch (err) {
    context.log("Error creating user:", (err as Error).message);
    return HttpResponse.internalError().toAzureResponse();
  }
}

app.http("createUser", {
  methods: ["POST"],
  authLevel: "anonymous",
  handler: createUser,
});
