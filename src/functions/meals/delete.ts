import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, HttpResponse } from "../../core/utils";
import { prisma } from "../../core/database";

/**
 * @openapi
 * /api/meals/{id}:
 *   delete:
 *     summary: Delete a meal
 *     security:
 *       - bearerAuth: []
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
    const deleted = await prisma.meal.deleteMany({ where: { id, userId } });
    if (deleted.count === 0)
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
