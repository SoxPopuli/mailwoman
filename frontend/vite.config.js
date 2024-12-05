import { defineConfig } from "vite";
import melangePlugin from "vite-plugin-melange";

/** @type {import('vite').UserConfig} */
export default defineConfig({
    plugins: [
        melangePlugin({
            buildTarget: "app",
            buildCommand: "dune build",
            watchCommand: "dune build --watch",
        }),
    ]
});
