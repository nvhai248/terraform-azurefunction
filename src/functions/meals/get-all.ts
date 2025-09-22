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
 * /api/meals:
 *   get:
 *     summary: List meals for current user
 *     security:
 *       - bearerAuth: []
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
    const meals = await prisma.meal.findMany({ where: { userId } });
    return HttpResponse.ok(meals).toAzureResponse();
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
