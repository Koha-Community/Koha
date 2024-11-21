const path = require("path");
const fs = require("fs");
const yaml = require("yaml");

const readYamlFile = filePath => {
    const absolutePath = path.resolve(filePath);
    if (!fs.existsSync(absolutePath)) {
        throw new Error(`File not found: ${absolutePath}`);
    }
    const fileContent = fs.readFileSync(absolutePath, "utf8");
    return yaml.parse(fileContent);
};

module.exports = { readYamlFile };
