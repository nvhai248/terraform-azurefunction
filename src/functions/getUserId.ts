import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils, DecodedToken, HttpResponse } from "../core/utils";

/**
 * @openapi
 * /api/getUserId:
 *   get:
 *     summary: Extract user ID from JWT token
 *     description: |
 *       This endpoint extracts the user identifier (`oid` or `sub`) from the
 *       JWT access token provided in the `Authorization` header.
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User ID successfully extracted
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 userId:
 *                   type: string
 *                   example: "12345678-abcd-efgh-9876-abcdef123456"
 *       400:
 *         description: Invalid JWT token
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 error:
 *                   type: string
 *                   example: "Invalid JWT token"
 *       401:
 *         description: Missing or invalid Authorization header
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 error:
 *                   type: string
 *                   example: "Authorization header missing or invalid"
 *       500:
 *         description: Internal server error while decoding token
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 error:
 *                   type: string
 *                   example: "Internal Server Error"
 */
export async function getUserId(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log(`Processing request for url "${request.url}"`);

  const authHeader = request.headers.get("authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return HttpResponse.unauthorized(
      "Authorization header missing or invalid"
    ).toAzureResponse();
  }

  const token = authHeader.split(" ")[1];
  const decoded: DecodedToken | null = AuthUtils.decodeToken(token);

  if (!decoded) {
    return HttpResponse.badRequest("Invalid JWT token").toAzureResponse();
  }

  try {
    const userId = decoded.oid ?? decoded.sub;
    return HttpResponse.ok({ userId }).toAzureResponse();
  } catch (err) {
    context.log("Error decoding token:", (err as Error).message);
    return HttpResponse.internalError().toAzureResponse();
  }
}

app.http("getUserId", {
  methods: ["GET"],
  authLevel: "anonymous",
  handler: getUserId,
});
