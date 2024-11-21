const { faker } = require("@faker-js/faker");
const { readYamlFile } = require("./../plugins/readYamlFile.js");

const generateMockData = type => {
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
        default:
            return faker.lorem.word();
    }
};

const generateDataFromSchema = properties => {
    const mockData = {};
    Object.entries(properties).forEach(([key, value]) => {
        mockData[key] = generateMockData(value.type);
    });
    return mockData;
};

const buildSamplePatron = () => {
    const yamlPath = "api/v1/swagger/definitions/patron.yaml";
    const schema = readYamlFile(yamlPath);
    return generateDataFromSchema(schema.properties);
};

module.exports = {
    generateMockData,
    generateDataFromSchema,
    buildSamplePatron,
};
