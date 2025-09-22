import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, HttpResponse } from "../../core/utils";
import { prisma } from "../../core/database";
import { UpdateMealDto } from "../../core/dtos/meal";

/**
 * @openapi
 * /api/meals/{id}:
 *   put:
 *     summary: Update a meal
 *     security:
 *       - bearerAuth: []
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
    const meal = await prisma.meal.updateMany({
      where: { id, userId },
      data: body,
    });
    if (meal.count === 0)
      return HttpResponse.notFound("Meal not found").toAzureResponse();
    const updated = await prisma.meal.findUnique({ where: { id } });
    return HttpResponse.ok(updated).toAzureResponse();
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
