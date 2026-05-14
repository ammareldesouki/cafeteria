import { defineConfig } from "tsup";

export default defineConfig({
	entry: ["src/server.ts"], // Multiple entries allowed when adding CLI etc.
	outDir: "dist", // Output directory
	format: ["esm"],
	dts: true, // Generate type declaration files (.d.ts)
	sourcemap: true, // Generate sourcemaps
	clean: true, // Clean dist folder before build
	target: "es2020", // Transpile target
	minify: false, // Minify JS files to reduce size
	treeshake: true, // Remove unused code (default true, explicit)
	// alias, swc options apply automatically from tsconfig.json
	// external: [], // Exclude node_modules when needed
});
