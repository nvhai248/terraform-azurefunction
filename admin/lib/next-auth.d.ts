import NextAuth, { DefaultSession, DefaultUser, Account } from "next-auth";

declare module "next-auth" {
  interface Session {
    user: {
      id: string;
      accessToken?: string;
    } & DefaultSession["user"];
  }

  interface User extends DefaultUser {
    accessToken?: string;
  }

  interface Account {
    access_token?: string;
    refresh_token?: string;
    expires_in?: number;
  }

  interface JWT {
    id?: string;
    accessToken?: string;
    refreshToken?: string;
    expiresAt?: number;
  }
}
