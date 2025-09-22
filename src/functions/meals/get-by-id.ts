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
 *   get:
 *     summary: Get a specific meal
 *     security:
 *       - bearerAuth: []
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
    const meal = await prisma.meal.findFirst({ where: { id, userId } });
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
