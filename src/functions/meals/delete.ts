import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, HttpResponse } from "../../core/utils";
import { eq, and } from "drizzle-orm";
import { db } from "../../core/db/client";
import { meals } from "../../core/db/schema";

/**
 * @openapi
 * /api/meals/{id}:
 *   delete:
 *     summary: Delete a meal
 *     tags:
 *       - Meals
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Meal deleted successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Meal not found
 *       500:
 *         description: Internal server error
 */
export async function deleteMeal(
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
    const deleted = await db
      .delete(meals)
      .where(and(eq(meals.id, id), eq(meals.userId, userId)));

    if (deleted.rowCount === 0)
      return HttpResponse.notFound("Meal not found").toAzureResponse();

    return HttpResponse.ok({ message: "Meal deleted" }).toAzureResponse();
  } catch (err) {
    context.log("Error deleting meal:", (err as Error).message);
    return HttpResponse.internalError().toAzureResponse();
  }
}

app.http("deleteMeal", {
  route: "meals/{id}",
  methods: ["DELETE"],
  authLevel: "anonymous",
  handler: deleteMeal,
});
