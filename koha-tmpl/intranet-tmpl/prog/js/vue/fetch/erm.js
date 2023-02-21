import { setError } from "../messages";

//TODO: all of these functions should be deleted and reimplemented in the components using ERMAPIClient

export const fetchPatron = function (patron_id) {
    if (!patron_id) return;
    const apiUrl = "/api/v1/patrons/" + patron_id;
    return myFetch(apiUrl);
};

export const fetchVendors = function () {
    const apiUrl = "/api/v1/acquisitions/vendors?_per_page=-1";
    return myFetch(apiUrl);
};

const _createEditPackage = function (method, erm_package) {
    let apiUrl = "/api/v1/erm/eholdings/local/packages";

    if (method == "PUT") {
        apiUrl += "/" + erm_package.package_id;
    }
    delete erm_package.package_id;
    delete erm_package.resources;
    delete erm_package.vendor;
    delete erm_package.resources_count;
    delete erm_package.is_selected;

    erm_package.package_agreements = erm_package.package_agreements.map(
        ({ package_id, agreement, ...keepAttrs }) => keepAttrs
    );

    const options = {
        method: method,
        body: JSON.stringify(erm_package),
        headers: {
            "Content-Type": "application/json;charset=utf-8",
        },
    };

    return myFetch(apiUrl, options, 1);
};

export const createPackage = function (erm_package) {
    return _createEditPackage("POST", erm_package);
};
export const editPackage = function (erm_package) {
    return _createEditPackage("PUT", erm_package);
};

const _fetchPackage = function (apiUrl, package_id) {
    if (!package_id) return;
    return myFetch(apiUrl, {
        headers: {
            "x-koha-embed":
                "package_agreements,package_agreements.agreement,resources+count,vendor",
        },
    });
};
export const fetchLocalPackage = function (package_id) {
    const apiUrl = "/api/v1/erm/eholdings/local/packages/" + package_id;
    return _fetchPackage(apiUrl, package_id);
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
export const fetchLocalPackages = function () {
    const apiUrl = "/api/v1/erm/eholdings/local/packages?_per_page=-1";
    return _fetchPackages(apiUrl);
};
export const fetchEBSCOPackages = function () {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/packages";
    return _fetchPackages(apiUrl);
};

export const fetchLocalPackageCount = function (filters) {
    const q = filters
        ? {
              "me.name": { like: "%" + filters.package_name + "%" },
              ...(filters.content_type
                  ? { "me.content_type": filters.content_type }
                  : {}),
          }
        : {};

    const params = {
        _page: 1,
        _per_page: 1,
        q: JSON.stringify(q),
    };
    var apiUrl = "/api/v1/erm/eholdings/local/packages";
    return myFetchTotal(apiUrl + "?" + new URLSearchParams(params));
};

export const _fetchTitle = function (apiUrl, title_id) {
    if (!title_id) return;
    return myFetch(apiUrl, {
        headers: {
            "x-koha-embed": "resources,resources.package",
        },
    });
};
export const fetchLocalTitle = function (title_id) {
    const apiUrl = "/api/v1/erm/eholdings/local/titles/" + title_id;
    return _fetchTitle(apiUrl, title_id);
};
export const fetchEBSCOTitle = function (title_id) {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/titles/" + title_id;
    return _fetchTitle(apiUrl, title_id);
};

export const fetchLocalTitleCount = function (filters) {
    const q = filters
        ? {
              ...(filters.publication_title
                  ? {
                        "me.publication_title": {
                            like: "%" + filters.publication_title + "%",
                        },
                    }
                  : {}),
              ...(filters.publication_type
                  ? { "me.publication_type": filters.publication_type }
                  : {}),
          }
        : undefined;
    const params = {
        _page: 1,
        _per_page: 1,
        ...(q ? { q: JSON.stringify(q) } : {}),
    };
    var apiUrl = "/api/v1/erm/eholdings/local/titles";
    return myFetchTotal(apiUrl + "?" + new URLSearchParams(params));
};

export const _fetchResource = function (apiUrl, resource_id) {
    if (!resource_id) return;
    return myFetch(apiUrl, {
        headers: {
            "x-koha-embed": "title,package,vendor",
        },
    });
};
export const fetchLocalResource = function (resource_id) {
    const apiUrl = "/api/v1/erm/eholdings/local/resources/" + resource_id;
    return _fetchResource(apiUrl, resource_id);
};
export const fetchEBSCOResource = function (resource_id) {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/resources/" + resource_id;
    return _fetchResource(apiUrl, resource_id);
};

export const _fetchResources = async function (apiUrl) {
    return await myFetch(apiUrl);
};

export const fetchLocalResources = function () {
    const apiUrl = "/api/v1/erm/eholdings/local/resources";
    return _fetchResources(apiUrl);
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
