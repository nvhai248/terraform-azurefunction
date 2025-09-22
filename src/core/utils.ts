import { HttpRequest } from "@azure/functions";
import jwt, { JwtPayload } from "jsonwebtoken";

export interface DecodedToken extends JwtPayload {
  oid?: string;
  sub?: string;
  [key: string]: any;
}

export class AuthUtils {
  /**
   * Extracts bearer token from Authorization header
   */
  static extractToken(request: HttpRequest): string | null {
    const authHeader = request.headers.get("authorization");
    if (!authHeader) return null;

    const [scheme, token] = authHeader.split(" ");
    if (scheme !== "Bearer" || !token) return null;

    return token;
  }

  /**
   * Decodes a JWT and extracts userId
   * By default uses `sub`, but also checks for `oid` (Azure AD)
   */
  static getUserId(token: string | null): string | null {
    if (!token) return null;

    try {
      const decoded = jwt.decode(token) as JwtPayload | null;
      if (!decoded) return null;

      // Prefer Azure AD Object ID (`oid`), fallback to standard `sub`
      return (decoded["oid"] as string) || (decoded.sub as string) || null;
    } catch {
      return null;
    }
  }
}

// Wrapper class for HttpResponse in Azure Function
export class HttpResponse {
  status: number;
  headers: Record<string, string>;
  body?: unknown;

  constructor(
    status: number = 200,
    body?: unknown,
    headers: Record<string, string> = { "Content-Type": "application/json" }
  ) {
    this.status = status;
    this.body = body;
    this.headers = headers;
  }

  static ok(body?: unknown): HttpResponse {
    return new HttpResponse(200, body);
  }

  static badRequest(message: string = "Bad Request"): HttpResponse {
    return new HttpResponse(400, { error: message });
  }

  static unauthorized(message: string = "Unauthorized"): HttpResponse {
    return new HttpResponse(401, { error: message });
  }

  static notFound(message: string = "Not Found"): HttpResponse {
    return new HttpResponse(404, { error: message });
  }

  static forbidden(message: string = "Forbidden"): HttpResponse {
    return new HttpResponse(403, { error: message });
  }

  static created(body?: unknown): HttpResponse {
    return new HttpResponse(201, body);
  }

  static internalError(
    message: string = "Internal Server Error"
  ): HttpResponse {
    return new HttpResponse(500, { error: message });
  }

  toAzureResponse(): any {
    return {
      status: this.status,
      headers: this.headers,
      body: this.body,
    };
  }
}
