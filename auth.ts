import { createAuth } from "@keystone-6/auth";
import { statelessSessions } from "@keystone-6/core/session";

const { withAuth } = createAuth({
  listKey: "User",
  identityField: "email",
  secretField: "password",
  initFirstItem: {
    fields: ['name', 'email', 'password'],
  },
  sessionData: "name",
});

const session = statelessSessions({
  maxAge: 60 * 60 * 24 * 30, // 30 days
  secret: "-- DEV COOKIE SECRET; CHANGE ME --",
});

export { withAuth, session };