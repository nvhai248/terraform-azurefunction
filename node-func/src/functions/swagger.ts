import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import swaggerJsdoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-dist";

// swagger-jsdoc
const options: swaggerJsdoc.Options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Azure Function API",
      version: "1.0.0",
      description: "Auto-generated OpenAPI spec for Azure Functions",
    },
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
      schemas: {
        // ---------------- MEALS ----------------
        CreateMealDto: {
          type: "object",
          required: ["userId"],
          properties: {
            userId: { type: "string" },
            name: { type: "string" },
            imageUrl: { type: "string" },
            calories: { type: "number" },
            protein: { type: "number" },
            carbs: { type: "number" },
            fat: { type: "number" },
            mealType: {
              type: "string",
              enum: ["BREAKFAST", "LUNCH", "DINNER", "SNACK"],
            },
          },
        },
        UpdateMealDto: {
          type: "object",
          properties: {
            name: { type: "string" },
            imageUrl: { type: "string" },
            calories: { type: "number" },
            protein: { type: "number" },
            carbs: { type: "number" },
            fat: { type: "number" },
            mealType: {
              type: "string",
              enum: ["BREAKFAST", "LUNCH", "DINNER", "SNACK"],
            },
          },
        },
        Meal: {
          type: "object",
          properties: {
            id: { type: "string", example: "abc123" },
            userId: { type: "string", example: "user_1" },
            name: { type: "string", example: "Chicken Salad" },
            imageUrl: {
              type: "string",
              format: "uri",
              example: "https://example.com/meal.png",
            },
            calories: { type: "number", example: 350 },
            protein: { type: "number", example: 30 },
            carbs: { type: "number", example: 20 },
            fat: { type: "number", example: 10 },
            mealType: {
              type: "string",
              enum: ["breakfast", "lunch", "dinner", "snack"],
            },
            createdAt: { type: "string", format: "date-time" },
            updatedAt: { type: "string", format: "date-time" },
          },
          required: ["id", "userId", "name"],
        },

        // ---------------- ACTIVITY ----------------
        CreateActivityDto: {
          type: "object",
          required: ["userId", "type"],
          properties: {
            userId: { type: "string" },
            type: {
              type: "string",
              enum: ["RUNNING", "WALKING", "CYCLING", "GYM", "SWIMMING"],
            }, // enum từ ActivityType
            duration: {
              type: "number",
              description: "Thời lượng tính bằng phút",
            },
            calories: { type: "number" },
          },
        },
        UpdateActivityDto: {
          type: "object",
          properties: {
            type: {
              type: "string",
              enum: ["RUNNING", "WALKING", "CYCLING", "GYM", "SWIMMING"],
            },
            duration: { type: "number" },
            calories: { type: "number" },
          },
        },

        // ---------------- USER ----------------
        UpdateUserDto: {
          type: "object",
          properties: {
            age: { type: "number" },
            gender: { type: "string", enum: ["MALE", "FEMALE", "OTHER"] }, // từ Gender
            weight: { type: "number" },
            height: { type: "number" },
            activityLevel: {
              type: "string",
              enum: ["SEDENTARY", "LIGHT", "MODERATE", "ACTIVE", "VERY_ACTIVE"],
            }, // từ ActivityLevel
            dailyCalories: { type: "number" },
            allergies: {
              type: "array",
              items: { type: "string" },
              example: ["peanuts", "gluten"],
            },
            preferences: {
              type: "array",
              items: { type: "string" },
              example: ["vegan", "low-carb"],
            },
            avatarUrl: {
              type: "string",
              format: "uri",
              example: "https://cdn.example.com/avatars/123.png",
            },
          },
        },

        // ---------------- WEIGHT LOG ----------------
        CreateWeightLogDto: {
          type: "object",
          required: ["userId", "weight"],
          properties: {
            userId: { type: "string" },
            weight: { type: "number" },
            note: { type: "string" },
          },
        },
        UpdateWeightLogDto: {
          type: "object",
          properties: {
            weight: { type: "number" },
            note: { type: "string" },
          },
        },
      },
    },
    security: [{ bearerAuth: [] }],
  },
  apis: ["./src/functions/**/*.ts"],
};

const swaggerSpec = swaggerJsdoc(options);

export async function swaggerJson(
  _req: HttpRequest,
  _ctx: InvocationContext
): Promise<HttpResponseInit> {
  return {
    status: 200,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(swaggerSpec, null, 2),
  };
}

app.http("swaggerJson", {
  methods: ["GET"],
  route: "swagger.json",
  authLevel: "anonymous",
  handler: swaggerJson,
});

export async function swaggerDocs(
  _req: HttpRequest,
  _ctx: InvocationContext
): Promise<HttpResponseInit> {
  const swaggerUiAssets = swaggerUi.getAbsoluteFSPath();
  const html = `
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="UTF-8">
      <title>Swagger UI</title>
      <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist/swagger-ui.css" />
    </head>
    <body>
      <div id="swagger-ui"></div>
      <script src="https://unpkg.com/swagger-ui-dist/swagger-ui-bundle.js"></script>
      <script>
        window.onload = () => {
          window.ui = SwaggerUIBundle({
            url: "/api/swagger.json",
            dom_id: '#swagger-ui',
          });
        };
      </script>
    </body>
  </html>
  `;
  return {
    status: 200,
    headers: { "Content-Type": "text/html" },
    body: html,
  };
}

app.http("swaggerDocs", {
  methods: ["GET"],
  route: "docs",
  authLevel: "anonymous",
  handler: swaggerDocs,
});
