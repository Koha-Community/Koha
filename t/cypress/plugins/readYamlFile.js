/**
 * YAML File Reading Utilities for Cypress Testing
 *
 * This module provides utilities for reading and parsing YAML files,
 * primarily used for loading OpenAPI schema definitions during test
 * data generation.
 *
 * @module readYamlFile
 */

const path = require("path");
const fs = require("fs");
const yaml = require("yaml");

/**
 * Reads and parses a YAML file.
 *
 * @function readYamlFile
 * @param {string} filePath - Path to the YAML file (relative or absolute)
 * @returns {Object} Parsed YAML content as a JavaScript object
 * @throws {Error} When file doesn't exist or YAML parsing fails
 * @description This function:
 * - Resolves the file path to an absolute path
 * - Checks if the file exists before attempting to read
 * - Reads the file content as UTF-8 text
 * - Parses the YAML content into a JavaScript object
 *
 * @example
 * // Read an OpenAPI schema definition
 * const patronSchema = readYamlFile('api/v1/swagger/definitions/patron.yaml');
 *
 * @example
 * // Read a configuration file
 * const config = readYamlFile('./config/test-config.yaml');
 */
const readYamlFile = filePath => {
    const absolutePath = path.resolve(filePath);
    if (!fs.existsSync(absolutePath)) {
        throw new Error(`File not found: ${absolutePath}`);
    }
    const fileContent = fs.readFileSync(absolutePath, "utf8");
    return yaml.parse(fileContent);
};

module.exports = { readYamlFile };
