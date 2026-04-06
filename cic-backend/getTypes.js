const fs = require("fs");
const optionsDts = fs.readFileSync(
	"./node_modules/better-auth/dist/types/init-options.d.mts",
	"utf8",
);
console.log(
	optionsDts.match(/advanced\?:.*?\{.*?\}/s)
		? optionsDts.match(/advanced\?:.*?\{([\s\S]*?)\}/s)[1]
		: "not found",
);
