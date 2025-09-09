import * as crypto from "crypto";
import * as jwt from "jsonwebtoken";
import { SECRET_KEY, TOKEN_EXP_SECONDS } from "./const";

export class AuthUtils {
  private secretKey: string;

  constructor(secretKey: string = SECRET_KEY) {
    this.secretKey = secretKey;
  }

  // ============================
  // Password utilities
  // ============================
  public hashPassword(password: string, salt?: string): string {
    if (!salt) {
      salt = crypto.randomBytes(16).toString("base64url");
    }
    const hash = crypto.pbkdf2Sync(password, salt, 100000, 32, "sha256");
    return `${salt}$${hash.toString("base64url")}`;
  }

  public verifyPassword(password: string, hashedValue: string): boolean {
    try {
      const [salt, hashB64] = hashedValue.split("$");
      const newHash = crypto.pbkdf2Sync(password, salt, 100000, 32, "sha256");
      return crypto.timingSafeEqual(
        Buffer.from(newHash),
        Buffer.from(Buffer.from(hashB64, "base64url"))
      );
    } catch {
      return false;
    }
  }

  // ============================
  // JWT utilities
  // ============================
  public generateToken(userId: string): string {
    const payload = {
      sub: userId,
      exp: Math.floor(Date.now() / 1000) + TOKEN_EXP_SECONDS,
    };
    return jwt.sign(payload, this.secretKey, { algorithm: "HS256" });
  }

  public verifyToken(token: string): any | null {
    try {
      return jwt.verify(token, this.secretKey, { algorithms: ["HS256"] });
    } catch {
      return null;
    }
  }
}
