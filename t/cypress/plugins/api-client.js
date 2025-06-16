const { APIClient } = require("./dist/api-client.cjs.js");

const client = APIClient.default.koha;

const prepareRequest = params => {
    const { baseUrl, endpoint, authHeader, headers = {}, ...rest } = params;
    const url = baseUrl + endpoint;
    const finalHeaders = {
        ...headers,
        ...(authHeader ? { Authorization: authHeader } : {}),
    };
    return { url, headers: finalHeaders, rest };
};

const apiGet = params => {
    const { url, headers, rest } = prepareRequest(params);
    return client.get({
        endpoint: url,
        headers,
        ...rest,
    });
};

const apiPost = params => {
    const { url, headers, rest } = prepareRequest(params);
    return client.post({
        endpoint: url,
        headers,
        ...rest,
    });
};

const apiPut = params => {
    const { url, headers, rest } = prepareRequest(params);
    return client.put({
        endpoint: url,
        headers,
        ...rest,
    });
};

const apiDelete = params => {
    const { url, headers, rest } = prepareRequest(params);
    return client.delete({
        endpoint: url,
        headers,
        ...rest,
    });
};

module.exports = {
    apiGet,
    apiPost,
    apiPut,
    apiDelete,
};
