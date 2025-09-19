import jwt, { JwtPayload } from "jsonwebtoken";

export interface DecodedToken extends JwtPayload {
  oid?: string;
  sub?: string;
  [key: string]: any;
}

export class AuthUtils {
  public static decodeToken(token: string): DecodedToken | null {
    try {
      const decoded = jwt.decode(token) as DecodedToken | null;
      return decoded;
    } catch (error) {
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
