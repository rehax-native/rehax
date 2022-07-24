import nodeResolve from '@rollup/plugin-node-resolve';
import babel from '@rollup/plugin-babel';

const extensions = ['ts', 'tsx', 'js', 'jsx'].map((x) => '.' + x);

export default {
  input: 'src/index.native.jsx',
  output: {
    dir: 'distNative',
    format: 'cjs'
  },
  plugins: [
    nodeResolve({
      extensions
    }),
    // babel({ babelHelpers: 'bundled' })
    babel({
      extensions,
      babelHelpers: 'bundled',
      presets: [
        // use this for Microsoft Edge
        // [
        //   '@babel/preset-env',
        //   {
        //     useBuiltIns: 'usage',
        //     corejs: 3,
        //     forceAllTransforms: true,
        //     targets: { browsers: 'last 2 versions' },
        //   },
        // ],
        [
          'solid',
          {
            "moduleName": "rehax-solidjs",
            "generate": "universal"
          }
        ],
        // '@babel/preset-typescript',
      ],
      // use this for Microsoft Edge
      // plugins: [
      //   '@babel/plugin-syntax-dynamic-import',
      //   '@babel/proposal-class-properties',
      //   '@babel/plugin-proposal-object-rest-spread',
      // ],
      // use use this for Microsoft Edge
      // exclude: [
      //   /(node_modules\/)(?!(solid-js|router5|solid-typefu-router5))/,
      //   /node_modules\/core-js/,
      // ],
      // exclude: /node_modules\//,
    }),
  ]
};