import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, HttpResponse } from "../../core/utils";
import { CreateMealDto } from "../../core/dtos/meal";
import { db } from "../../core/db/client";
import { meals } from "../../core/db/schema";

/**
 * @openapi
 * /api/meals:
 *   post:
 *     summary: Create a new meal
 *     description: |
 *       Creates a meal for the authenticated user.
 *       The `userId` is taken from the JWT token, not the request body.
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
 *       400:
 *         description: Invalid request
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Internal server error
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

    const [meal] = await db
      .insert(meals)
      .values({
        userId, // taken from token
        name: body.name,
        imageUrl: body.imageUrl,
        calories: body.calories,
        protein: body.protein,
        carbs: body.carbs,
        fat: body.fat,
        mealType: body.mealType,
      })
      .returning();

    return HttpResponse.created(meal).toAzureResponse();
  } catch (err) {
    context.error("Error creating meal:", (err as Error).message);
    return HttpResponse.internalError().toAzureResponse();
  }
}

app.http("createMeal", {
  route: "meals",
  methods: ["POST"],
  authLevel: "anonymous",
  handler: createMeal,
});
