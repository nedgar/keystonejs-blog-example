import { createAuth } from "@keystone-6/auth";
import { statelessSessions } from "@keystone-6/core/session";
import dotenv from "dotenv";

dotenv.config();

const { withAuth } = createAuth({
  listKey: "User",
  identityField: "email",
  secretField: "password",
  initFirstItem: {
    fields: ["name", "email", "password"],
  },
  sessionData: "name",
});

const { SESSION_SECRET } = process.env;
console.log("SESSION_SECRET:", SESSION_SECRET);

const session = statelessSessions({
  maxAge: 60 * 60 * 24 * 30, // 30 days
  secret: SESSION_SECRET,
});

export { withAuth, session };
