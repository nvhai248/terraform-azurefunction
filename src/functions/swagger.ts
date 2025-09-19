import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import swaggerJsdoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-dist";

// Cấu hình swagger-jsdoc
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
    },
    security: [{ bearerAuth: [] }],
  },
  apis: ["./src/functions/*.ts"],
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
