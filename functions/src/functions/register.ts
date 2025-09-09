import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { AuthUtils } from "../core/utils";
import { prisma } from "../core/database";

const auth = new AuthUtils();

interface RegisterRequestBody {
  email?: string;
  password?: string;
}

export async function register(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log(`Register function processed request for url "${request.url}"`);

  try {
    // Ensure request body is parsed as an object
    const body: RegisterRequestBody = (
      request.body && typeof request.body === "object" ? request.body : {}
    ) as RegisterRequestBody;

    const email = body.email || request.query.get("email");
    const password = body.password || request.query.get("password");

    if (!email || !password) {
      return {
        status: 400,
        body: JSON.stringify({ error: "email and password are required" }),
        headers: { "Content-Type": "application/json" },
      };
    }

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });
    if (existingUser) {
      return {
        status: 409,
        body: JSON.stringify({ error: "email already exists" }),
        headers: { "Content-Type": "application/json" },
      };
    }

    // Hash the password
    const hashedPassword = auth.hashPassword(password);

    // Save user to DB
    const newUser = await prisma.user.create({
      data: {
        email,
        passwordHash: hashedPassword,
      },
    });

    // (Optional) Save email + hashedPassword to DB here
    // await saveUserToDB(email, hashedPassword);

    // Generate a token for the new user
    const token = auth.generateToken(email);

    return {
      status: 201,
      body: JSON.stringify({
        message: `User ${email} registered successfully`,
        token,
      }),
      headers: { "Content-Type": "application/json" },
    };
  } catch (err) {
    context.log("Error registering user:", err);
    return {
      status: 500,
      body: JSON.stringify({ error: "Internal server error" }),
      headers: { "Content-Type": "application/json" },
    };
  }
}

app.http("register", {
  methods: ["POST"],
  authLevel: "anonymous",
  handler: register,
});
