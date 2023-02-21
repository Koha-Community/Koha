import { setError } from "../messages";

//TODO: all of these functions should be deleted and reimplemented in the components using ERMAPIClient

const _fetchPackage = function (apiUrl, package_id) {
    if (!package_id) return;
    return myFetch(apiUrl, {
        headers: {
            "x-koha-embed":
                "package_agreements,package_agreements.agreement,resources+count,vendor",
        },
    });
};
export const fetchEBSCOPackage = function (package_id) {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/packages/" + package_id;
    return _fetchPackage(apiUrl, package_id);
};

export const _fetchPackages = function (apiUrl) {
    return myFetch(apiUrl, {
        headers: {
            "x-koha-embed": "resources+count,vendor.name",
        },
    });
};
export const fetchEBSCOPackages = function () {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/packages";
    return _fetchPackages(apiUrl);
};

export const _fetchTitle = function (apiUrl, title_id) {
    if (!title_id) return;
    return myFetch(apiUrl, {
        headers: {
            "x-koha-embed": "resources,resources.package",
        },
    });
};
export const fetchEBSCOTitle = function (title_id) {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/titles/" + title_id;
    return _fetchTitle(apiUrl, title_id);
};

export const _fetchResource = function (apiUrl, resource_id) {
    if (!resource_id) return;
    return myFetch(apiUrl, {
        headers: {
            "x-koha-embed": "title,package,vendor",
        },
    });
};
export const fetchEBSCOResource = function (resource_id) {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/resources/" + resource_id;
    return _fetchResource(apiUrl, resource_id);
};

export const _fetchResources = async function (apiUrl) {
    return await myFetch(apiUrl);
};

export const fetchEBSCOResources = function () {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/resources";
    return _fetchResources(apiUrl);
};

export const myFetch = async function (url, options, return_response) {
    let r;
    await fetch(url, options || {})
        .then((response) => checkError(response, return_response))
        .then(
            (result) => {
                r = result;
            },
            (error) => {
                setError(error.toString());
            }
        )
        .catch((error) => {
            setError(error);
        });
    return r;
};
export const myFetchTotal = async function (url, options) {
    let r;
    await myFetch(url, options, 1).then(
        (response) => {
            if (response) {
                r = response.headers.get("X-Total-Count");
            }
        },
        (error) => {
            setError(error.toString());
        }
    );
    return r;
};

export const checkError = function (response, return_response) {
    if (response.status >= 200 && response.status <= 299) {
        return return_response ? response : response.json();
    } else {
        console.log("Server returned an error:");
        console.log(response);
        throw Error("%s (%s)".format(response.statusText, response.status));
    }
};
