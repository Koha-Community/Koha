/**
 * Mock Data Generation for Cypress Testing
 *
 * This module provides functions to generate realistic test data for Koha objects
 * based on OpenAPI schema definitions. It uses Faker.js to generate random data
 * that conforms to the API specifications.
 *
 * @module mockData
 */

const { faker } = require("@faker-js/faker");
const { readYamlFile } = require("./../plugins/readYamlFile.js");
const { query } = require("./db.js");
const fs = require("fs");

/**
 * Cache to store generated ID values to prevent duplicates
 * @type {Set<string>}
 */
const generatedDataCache = new Set();

/**
 * Generates mock data for a specific data type based on OpenAPI schema properties.
 *
 * @function generateMockData
 * @param {string} type - The data type (string, integer, boolean, array, number, date, date-time)
 * @param {Object} properties - OpenAPI schema properties for the field
 * @param {Array} [properties.enum] - Enumerated values to choose from
 * @param {number} [properties.maxLength] - Maximum length for strings
 * @param {number} [properties.minLength] - Minimum length for strings
 * @returns {*} Generated mock data appropriate for the type
 * @private
 * @example
 * // Generate a string with max length 50
 * const name = generateMockData('string', { maxLength: 50 });
 *
 * // Generate from enum values
 * const status = generateMockData('string', { enum: ['active', 'inactive'] });
 */
const generateMockData = (type, properties) => {
    if (properties.hasOwnProperty("enum")) {
        let values = properties.enum;
        return values[Math.floor(Math.random() * values.length)];
    }

    switch (type) {
        case "string":
            if (properties?.maxLength) {
                // The propability to have a string with length=1 is the same as length=10
                // We have very limited pool of possible values for length=1 which will result in a "Duplicate ID" error from the server
                // Setting minLength to 3 to prevent this kind of failures
                let minLength =
                    properties.minLength === 1 ||
                    properties.minLength === undefined
                        ? 3
                        : properties.minLength;

                if (
                    properties.maxLength !== undefined &&
                    properties.maxLength < minLength
                ) {
                    minLength = properties.maxLength;
                }
                return (value = faker.string.alpha({
                    length: {
                        min: minLength,
                        max: properties.maxLength,
                    },
                }));
            }
            return (value = faker.lorem.words(3));
        case "integer":
            // Do not return more than int(11);
            return faker.number.int(2 ** 31 - 1);
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

/**
 * Generates mock data for an entire object based on OpenAPI schema properties.
 *
 * @function generateDataFromSchema
 * @param {Object} properties - OpenAPI schema properties object
 * @param {Object} [values={}] - Override values for specific fields
 * @returns {Object} Generated mock object with all required fields
 * @private
 * @description This function:
 * - Iterates through all properties in the schema
 * - Generates appropriate mock data for each field
 * - Handles object relationships (libraries, items, etc.)
 * - Ensures unique values for ID fields
 * - Applies any override values provided
 *
 * Special handling for object relationships:
 * - home_library/holding_library -> generates library object
 * - item_type -> generates item_type object
 * - Automatically sets corresponding _id fields
 */
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
                    case "pickup_library":
                        data = buildSampleObject({ object: "library" });
                        fk_name = "pickup_library_id";
                        break;
                    case "library":
                        data = buildSampleObject({ object: "library" });
                        fk_name = "library_id";
                        break;
                    case "item_type":
                        data = buildSampleObject({ object: "item_type" });
                        fk_name = "item_type_id";
                        break;
                    case "item":
                        data = buildSampleObject({ object: "item" });
                        fk_name = "item_id";
                        break;
                    default:
                        try {
                            data = generateMockData(type, value);
                        } catch (e) {
                            throw new Error(
                                `Failed to generate data for (${key}): ${e}`
                            );
                        }
                }
                if (typeof data === "object") {
                    ids[key] = data[fk_name];
                }
            } else {
                try {
                    if (key.match(/_id$/)) {
                        let attempts = 0;

                        do {
                            data = generateMockData(type, value);
                            attempts++;
                            if (attempts > 10) {
                                throw new Error(
                                    "Could not generate unique string after 10 attempts"
                                );
                            }
                        } while (generatedDataCache.has(data));

                        generatedDataCache.add(data);
                    } else {
                        data = generateMockData(type, value);
                    }
                } catch (e) {
                    throw new Error(
                        `Failed to generate data for ${key} (${type}): ${e}`
                    );
                }
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

/**
 * Builds an array of sample objects based on OpenAPI schema definitions.
 *
 * @function buildSampleObjects
 * @param {Object} params - Configuration parameters
 * @param {string} params.object - Object type to generate (must match YAML file name)
 * @param {Object} [params.values] - Override values for specific fields
 * @param {number} [params.count=1] - Number of objects to generate
 * @returns {Array<Object>} Array of generated objects
 * @throws {Error} When object type is not supported or generation fails
 * @description This function:
 * - Reads the OpenAPI schema from api/v1/swagger/definitions/{object}.yaml
 * - Generates the specified number of objects
 * - Applies any override values to all generated objects
 * - Ensures all objects conform to the API schema
 *
 * @example
 * // Generate 3 patron objects
 * const patrons = buildSampleObjects({
 *   object: 'patron',
 *   count: 3
 * });
 *
 * @example
 * // Generate 2 items with specific library
 * const items = buildSampleObjects({
 *   object: 'item',
 *   values: { library_id: 'CPL' },
 *   count: 2
 * });
 */
const buildSampleObjects = ({ object, values, count = 1 }) => {
    const yamlPath = `api/v1/swagger/definitions/${object}.yaml`;
    if (!fs.existsSync(yamlPath)) {
        throw new Error(
            `Object type not supported: '${object}'. No spec file.`
        );
    }
    const schema = readYamlFile(yamlPath);
    let generatedObject;
    try {
        generatedObject = Array.from({ length: count }, () =>
            generateDataFromSchema(schema.properties, values)
        );
    } catch (e) {
        throw new Error(`Failed to generate data for object '${object}': ${e}`);
    }
    return generatedObject;
};

/**
 * Builds a single sample object based on OpenAPI schema definitions.
 *
 * @function buildSampleObject
 * @param {Object} params - Configuration parameters
 * @param {string} params.object - Object type to generate (must match YAML file name)
 * @param {Object} [params.values={}] - Override values for specific fields
 * @returns {Object} Generated object conforming to API schema
 * @throws {Error} When object type is not supported or generation fails
 * @description This is a convenience function that generates a single object
 * by calling buildSampleObjects with count=1 and returning the first result.
 *
 * Supported object types include:
 * - patron: Library patron/borrower
 * - item: Bibliographic item
 * - biblio: Bibliographic record
 * - library: Library/branch
 * - hold: Hold/reservation request
 * - checkout: Circulation checkout
 * - vendor: Acquisitions vendor
 * - basket: Acquisitions basket
 * - And others as defined in api/v1/swagger/definitions/
 *
 * @example
 * // Generate a single patron
 * const patron = buildSampleObject({ object: 'patron' });
 *
 * @example
 * // Generate an item with specific values
 * const item = buildSampleObject({
 *   object: 'item',
 *   values: {
 *     barcode: '12345678',
 *     home_library_id: 'CPL'
 *   }
 * });
 */
const buildSampleObject = ({ object, values = {} }) => {
    return buildSampleObjects({ object, values })[0];
};

module.exports = {
    generateMockData,
    generateDataFromSchema,
    buildSampleObject,
    buildSampleObjects,
};
