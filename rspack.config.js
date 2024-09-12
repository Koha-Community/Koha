const { VueLoaderPlugin } = require("vue-loader");
//const autoprefixer = require("autoprefixer");
const path = require("path");
const rspack = require("@rspack/core");

module.exports = {
    resolve: {
        alias: {
            "@fetch": path.resolve(
                __dirname,
                "koha-tmpl/intranet-tmpl/prog/js/fetch"
            ),
        },
    },
    experiments: {
        css: true,
    },
    entry: {
        erm: "./koha-tmpl/intranet-tmpl/prog/js/vue/modules/erm.ts",
        preservation:
            "./koha-tmpl/intranet-tmpl/prog/js/vue/modules/preservation.ts",
        "admin/record_sources":
            "./koha-tmpl/intranet-tmpl/prog/js/vue/modules/admin/record_sources.ts",
        islands: "./koha-tmpl/intranet-tmpl/prog/js/vue/modules/islands.ts",
    },
    output: {
        filename: "[name].js",
        path: path.resolve(
            __dirname,
            "koha-tmpl/intranet-tmpl/prog/js/vue/dist/"
        ),
        chunkFilename: "[name].js",
        globalObject: "window",
    },
    module: {
        rules: [
            {
                test: /\.vue$/,
                loader: "vue-loader",
                options: {
                    experimentalInlineMatchResource: true,
                },
                exclude: [path.resolve(__dirname, "t/cypress/")],
            },
            {
                test: /\.ts$/,
                loader: "builtin:swc-loader",
                options: {
                    jsc: {
                        parser: {
                            syntax: "typescript",
                        },
                    },
                    appendTsSuffixTo: [/\.vue$/],
                },
                exclude: [
                    /node_modules/,
                    path.resolve(__dirname, "t/cypress/"),
                ],
                type: "javascript/auto",
            },
            {
                test: /\.css$/i,
                type: "javascript/auto",
                use: ["style-loader", "css-loader"],
            },
        ],
    },
    /**
    optimization: {
        splitChunks: {
            chunks: "all",
            cacheGroups: {
                default: false, // Disable default cache groups to avoid affecting existing bundles
                vendors: false, // Disable vendor caching
                vue: {
                    test: /[\\/]node_modules[\\/]vue[\\/]/,
                    name: "vue",
                    chunks: "all",
                    enforce: true,
                },
            },
        },
    },
    */
    plugins: [
        new VueLoaderPlugin(),
        new rspack.DefinePlugin({
            __VUE_OPTIONS_API__: true,
            __VUE_PROD_DEVTOOLS__: false,
            __VUE_PROD_HYDRATION_MISMATCH_DETAILS__: false,
        }),
    ],
    externals: {
        jquery: "jQuery",
        "datatables.net": "DataTable",
        "datatables.net-buttons": "DataTable",
        "datatables.net-buttons/js/buttons.html5": "DataTable",
        "datatables.net-buttons/js/buttons.print": "DataTable",
        "datatables.net-buttons/js/buttons.colVis": "DataTable",
    },
};
