const scripts = require("@keystone-6/core/scripts/cli");

(async () => {
  await scripts.cli(__dirname, ["build"]);
  process.exit();
})();
