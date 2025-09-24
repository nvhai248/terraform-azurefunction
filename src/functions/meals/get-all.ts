import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, HttpResponse } from "../../core/utils";
import { eq } from "drizzle-orm";
import { db } from "../../core/db/client";
import { meals } from "../../core/db/schema";

/**
 * @openapi
 * /api/meals:
 *   get:
 *     summary: List meals for current user
 *     tags:
 *       - Meals
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: A list of meals
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Meal'
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Internal server error
 */
export async function getMeals(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  const token = AuthUtils.extractToken(request);
  const userId = AuthUtils.getUserId(token);
  if (!userId)
    return HttpResponse.unauthorized("Invalid token").toAzureResponse();

  try {
    const results = await db
      .select()
      .from(meals)
      .where(eq(meals.userId, userId));

    return HttpResponse.ok(results).toAzureResponse();
  } catch (err) {
    context.log("Error fetching meals:", (err as Error).message);
    return HttpResponse.internalError().toAzureResponse();
  }
}

app.http("getMeals", {
  route: "meals",
  methods: ["GET"],
  authLevel: "anonymous",
  handler: getMeals,
});
