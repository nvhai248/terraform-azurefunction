import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";

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
  methods: ["GET", "POST"],
  authLevel: "anonymous",
  handler: healthCheck,
});
