import nodeResolve from "@rollup/plugin-node-resolve";
import babel from "@rollup/plugin-babel";
import commonjs from "@rollup/plugin-commonjs";
import typescript from "@rollup/plugin-typescript";
import dts from "rollup-plugin-dts";

const extensions = ["ts", "tsx", "js", "jsx"].map((x) => "." + x);

export default [
  {
    input: "index.ts",
    output: {
      dir: "dist",
      format: "cjs",
    },
    plugins: [
      typescript(),
      nodeResolve({
        extensions,
      }),
      commonjs(),
      babel({
        extensions,
        babelHelpers: "bundled",
        presets: [
          [
            "solid",
            {
              moduleName: "./componentRenderer",
              moduleName: "rehax-solidjs",
              // generate: "universal",
            },
          ],
        ],
      }),
    ],
  },
  {
    input: "index.ts",
    plugins: [dts()],
    output: {
      file: `dist/index.d.ts`,
      format: "es",
    },
  },
];
