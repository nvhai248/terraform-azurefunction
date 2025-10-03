import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, HttpResponse } from "../../core/utils";
import { and, eq } from "drizzle-orm";
import { db } from "../../core/db/client";
import { meals } from "../../core/db/schema";

/**
 * @openapi
 * /api/meals/{id}:
 *   get:
 *     summary: Get a specific meal by ID
 *     tags:
 *       - Meals
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *         description: The meal ID
 *     responses:
 *       200:
 *         description: Meal details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Meal'
 *       400:
 *         description: Meal ID required
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Meal not found
 *       500:
 *         description: Internal server error
 */
export async function getMealById(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  const token = AuthUtils.extractToken(request);
  const userId = AuthUtils.getUserId(token);
  if (!userId)
    return HttpResponse.unauthorized("Invalid token").toAzureResponse();

  const id = request.params["id"];
  if (!id) return HttpResponse.badRequest("Meal ID required").toAzureResponse();

  try {
    const [meal] = await db
      .select()
      .from(meals)
      .where(and(eq(meals.id, id), eq(meals.userId, userId)));

    if (!meal) return HttpResponse.notFound("Meal not found").toAzureResponse();

    return HttpResponse.ok(meal).toAzureResponse();
  } catch (err) {
    context.log("Error fetching meal:", (err as Error).message);
    return HttpResponse.internalError().toAzureResponse();
  }
}

app.http("getMealById", {
  route: "meals/{id}",
  methods: ["GET"],
  authLevel: "anonymous",
  handler: getMealById,
});
