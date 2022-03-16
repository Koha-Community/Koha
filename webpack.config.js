const { VueLoaderPlugin } = require("vue-loader");
const autoprefixer = require("autoprefixer");
const path = require("path");

module.exports = {
  entry: {
    main: "./koha-tmpl/intranet-tmpl/prog/js/vue/main-erm.ts",
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
      },
      {
        test: /\.ts$/,
        loader: 'ts-loader',
        options: {
          appendTsSuffixTo: [/\.vue$/]
        }
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      }
    ],
  },
  plugins: [
    new VueLoaderPlugin(),
  ],
};
