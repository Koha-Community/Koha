module.exports = {
    arrowParens: "avoid",
    trailingComma: "es5",
    tabWidth: 4,
    useTabs: false,
    overrides: [
        {
            files: "*.vue",
            options: {
                semi: false,
            }
        },
        {
            files: ["*.tt", "*.inc"],
            options: {
                printWidth: 240,
                parser: "jinja-template",
                plugins: ["prettier-plugin-jinja-template"],
            },
        },
    ],
}
