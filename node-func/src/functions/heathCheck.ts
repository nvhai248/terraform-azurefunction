import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";

/**
 * @openapi
 * /api/healcheck:
 *   get:
 *     summary: Health check endpoint
 *     description: Returns a hello message to confirm the service is running.
 *     parameters:
 *       - in: query
 *         name: name
 *         schema:
 *           type: string
 *         description: Optional name to include in the response
 *     responses:
 *       200:
 *         description: Successful response
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: "Hello, world!"
 *   post:
 *     summary: Health check endpoint (POST)
 *     description: Accepts text/plain body and returns hello message.
 *     requestBody:
 *       required: false
 *       content:
 *         text/plain:
 *           schema:
 *             type: string
 *             example: "Azure"
 *     responses:
 *       200:
 *         description: Successful response
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: "Hello, Azure!"
 */
export async function healthCheck(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log(
    `Health check, function processed request for url "${request.url}"`
  );

  const name = request.query.get("name") || (await request.text()) || "world";

  return { body: `Hello, ${name}!` };
}

app.http("healcheck", {
  methods: ["GET"],
  authLevel: "anonymous",
  handler: healthCheck,
});
