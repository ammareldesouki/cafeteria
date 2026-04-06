import { bearer, jwt } from "better-auth/plugins";

console.log("bearer configured:", bearer());
console.log("jwt configured:", jwt());
