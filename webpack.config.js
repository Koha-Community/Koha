const { VueLoaderPlugin } = require("vue-loader");
const autoprefixer = require("autoprefixer");
const path = require("path");
const webpack = require('webpack');

module.exports = {
  entry: {
    erm: "./koha-tmpl/intranet-tmpl/prog/js/vue/modules/erm.ts",
  },
  output: {
    filename: "[name].js",
    path: path.resolve(__dirname, "koha-tmpl/intranet-tmpl/prog/js/vue/dist/"),
    chunkFilename: "[name].js",
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: "vue-loader",
        exclude: [path.resolve(__dirname, "t/cypress/")],
      },
      {
        test: /\.ts$/,
        loader: 'ts-loader',
        options: {
          appendTsSuffixTo: [/\.vue$/]
        },
        exclude: [path.resolve(__dirname, "t/cypress/")],
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      }
    ],
  },
  plugins: [
    new VueLoaderPlugin(),
    new webpack.DefinePlugin({
      __VUE_OPTIONS_API__: true,
      __VUE_PROD_DEVTOOLS__: false,
    }),
  ],
};
