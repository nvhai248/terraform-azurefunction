import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, HttpResponse } from "../../core/utils";
import { prisma } from "../../core/database";
import { CreateMealDto } from "../../core/dtos/meal";
import { Prisma } from "@prisma/client";

/**
 * @openapi
 * /api/meals:
 *   post:
 *     summary: Create a new meal
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateMealDto'
 *     responses:
 *       201:
 *         description: Meal created successfully
 */
export async function createMeal(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  const token = AuthUtils.extractToken(request);
  const userId = AuthUtils.getUserId(token);
  if (!userId)
    return HttpResponse.unauthorized("Invalid token").toAzureResponse();

  try {
    const body = (await request.json()) as CreateMealDto;
    const meal = await prisma.meal.create({
      data: {
        ...body,
        userId, // works because it's in the Unchecked type
      } as Prisma.MealUncheckedCreateInput,
    });
    return HttpResponse.created(meal).toAzureResponse();
  } catch (err) {
    context.log("Error creating meal:", (err as Error).message);
    return HttpResponse.internalError().toAzureResponse();
  }
}

app.http("createMeal", {
  route: "meals",
  methods: ["POST"],
  authLevel: "anonymous",
  handler: createMeal,
});
