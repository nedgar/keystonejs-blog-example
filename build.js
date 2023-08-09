// This works around a problem with `keystone build` hanging.
// See https://github.com/keystonejs/keystone/issues/8581#issuecomment-1590581788

const scripts = require("@keystone-6/core/scripts/cli");

(async () => {
  await scripts.cli(__dirname, ["build"]);
  process.exit();
})();
