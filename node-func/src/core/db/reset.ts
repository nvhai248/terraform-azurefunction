import { drizzle } from "drizzle-orm/node-postgres";
export async function main() {
  const db = drizzle(process.env.DATABASE_URL!);
  await db.execute(`DROP SCHEMA public CASCADE; CREATE SCHEMA public;`);
  console.log("Database reset completed.");
}
