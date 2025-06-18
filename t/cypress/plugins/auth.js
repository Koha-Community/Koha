const { Buffer } = require("buffer");

const getBasicAuthHeader = (username, password) => {
    const credentials = Buffer.from(`${username}:${password}`).toString(
        "base64"
    );
    return `Basic ${credentials}`;
};

module.exports = {
    getBasicAuthHeader,
};
