const { faker } = require("@faker-js/faker");
const { readYamlFile } = require("./../plugins/readYamlFile.js");
const fs = require("fs");

const generateMockData = (type, properties) => {
    switch (type) {
        case "string":
            if (properties?.maxLength) {
                return faker.string.alpha({
                    length: {
                        min: properties.minLength || 1,
                        max: properties.maxLength,
                    },
                });
            }
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
    const ids = {};
    Object.entries(properties).forEach(([key, value]) => {
        if (values.hasOwnProperty(key)) {
            mockData[key] = values[key];
        } else {
            let data;
            let type = value.type;
            if (Array.isArray(type)) {
                type = type.filter(t => t != '"null"')[0];
            }

            type =
                value?.format == "date" || value?.format == "date-time"
                    ? value.format
                    : type;
            let fk_name;
            if (type == "object") {
                switch (key) {
                    case "home_library":
                    case "holding_library":
                        data = buildSampleObject({ object: "library" });
                        fk_name = "library_id";
                        break;
                    case "item_type":
                        data = buildSampleObject({ object: "item_type" });
                        fk_name = "item_type_id";
                        break;
                    default:
                        data = generateMockData(type, value);
                }
                if (typeof data === "object") {
                    ids[key] = data[fk_name];
                }
            } else {
                data = generateMockData(type, value);
            }
            mockData[key] = data;
        }
    });

    Object.keys(ids).forEach(k => {
        if (
            mockData.hasOwnProperty(k + "_id") &&
            !values.hasOwnProperty(k + "_id")
        ) {
            mockData[k + "_id"] = ids[k];
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
