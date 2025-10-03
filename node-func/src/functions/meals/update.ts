import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, HttpResponse } from "../../core/utils";
import { UpdateMealDto } from "../../core/dtos/meal";
import { and, eq } from "drizzle-orm";
import { db } from "../../core/db/client";
import { meals } from "../../core/db/schema";

/**
 * @openapi
 * /api/meals/{id}:
 *   put:
 *     summary: Update a meal
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
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateMealDto'
 *     responses:
 *       200:
 *         description: Meal updated successfully
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
export async function updateMeal(
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
    const body = (await request.json()) as UpdateMealDto;

    // update meal
    const updated = await db
      .update(meals)
      .set(body)
      .where(and(eq(meals.id, id), eq(meals.userId, userId)))
      .returning();

    if (updated.length === 0)
      return HttpResponse.notFound("Meal not found").toAzureResponse();

    return HttpResponse.ok(updated[0]).toAzureResponse();
  } catch (err) {
    context.log("Error updating meal:", (err as Error).message);
    return HttpResponse.internalError().toAzureResponse();
  }
}

app.http("updateMeal", {
  route: "meals/{id}",
  methods: ["PUT"],
  authLevel: "anonymous",
  handler: updateMeal,
});
