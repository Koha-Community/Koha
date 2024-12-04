const { faker } = require("@faker-js/faker");
const { readYamlFile } = require("./../plugins/readYamlFile.js");
const fs = require('fs');

const generateMockData = type => {
    if (Array.isArray(type)) {
        type = type.filter(t => t != '"null"')[0];
    }
    switch (type) {
        case "string":
            return faker.lorem.words(3);
        case "integer":
            return faker.number.int();
        case "boolean":
            return faker.datatype.boolean();
        case "array":
            return [faker.lorem.word(), faker.lorem.word()];
        case "number":
            return faker.number.float();
        case "date":
            return new Date().toISOString().split("T")[0];
        case "date-time":
            return new Date().toISOString();
        default:
            return faker.lorem.word();
    }
};

const generateDataFromSchema = (properties, values = {}) => {
    const mockData = {};
    Object.entries(properties).forEach(([key, value]) => {
        if (values.hasOwnProperty(key)) {
            mockData[key] = values[key];
        } else {
            let type =
                value?.format == "date" || value?.format == "date-time"
                    ? value.format
                    : value.type;
            mockData[key] = generateMockData(type);
        }
    });
    return mockData;
};

const buildSampleObjects = ({ object, values, count = 1 }) => {
    const yamlPath = `api/v1/swagger/definitions/${object}.yaml`;
    if (!fs.existsSync(yamlPath)) {
        throw new Error(
            `Object type not supported: '${object}'. No spec file.`
        );
    }
    const schema = readYamlFile(yamlPath);
    return Array.from({ length: count }, () =>
        generateDataFromSchema(schema.properties, values)
    );
};

const buildSampleObject = ({ object, values = {} }) => {
    return buildSampleObjects({ object, values })[0];
};

module.exports = {
    generateMockData,
    generateDataFromSchema,
    buildSampleObject,
    buildSampleObjects,
};
