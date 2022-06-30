import { setError } from "./messages";

export const fetchAgreement = async function (agreement_id) {
    if (!agreement_id) return;
    const apiUrl = "/api/v1/erm/agreements/" + agreement_id;
    let agreement;
    await fetch(apiUrl, {
        headers: {
            "x-koha-embed":
                "periods,user_roles,user_roles.patron,agreement_licenses,agreement_licenses.license,agreement_relationships,agreement_relationships.related_agreement,documents",
        },
    })
        .then(checkError)
        .then(
            (result) => {
                agreement = result;
            },
            (error) => {
                setError(error);
            }
        );
    return agreement;
};

export const fetchAgreements = async function () {
    const apiUrl = "/api/v1/erm/agreements";
    let agreements;
    await fetch(apiUrl)
        .then(checkError)
        .then(
            (result) => {
                agreements = result;
            },
            (error) => {
                setError(error);
            }
        );
    return agreements;
};

export const fetchLicense = async function (license_id) {
    if (!license_id) return;
    const apiUrl = "/api/v1/erm/licenses/" + license_id;
    let license;
    await fetch(apiUrl)
        .then(checkError)
        .then(
            (result) => {
                license = result;
            },
            (error) => {
                setError(error);
            }
        );
    return license;
};

export const fetchLicenses = async function () {
    const apiUrl = "/api/v1/erm/licenses";
    let licenses;
    await fetch(apiUrl)
        .then(checkError)
        .then(
            (result) => {
                licenses = result;
            },
            (error) => {
                setError(error);
            }
        );
    return licenses;
};

export const fetchPatron = async function (patron_id) {
    if (!patron_id) return;
    const apiUrl = "/api/v1/patrons/" + patron_id;
    let patron;
    await fetch(apiUrl)
        .then(checkError)
        .then(
            (result) => {
                patron = result;
            },
            (error) => {
                setError(error);
            }
        );
    return patron;
};

export const fetchVendors = async function () {
    const apiUrl = "/api/v1/acquisitions/vendors";
    let vendors;
    await fetch(apiUrl)
        .then(checkError)
        .then(
            (result) => {
                vendors = result;
            },
            (error) => {
                setError(error);
            }
        );
    return vendors;
};

const _createEditPackage = async function (method, erm_package) {
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

    let r;
    await fetch(apiUrl, options)
        .then(
            (response) => {
                r = response;
            },
            (error) => {
                setError(error);
            }
        )
        .catch((e) => {
            console.log(e);
        });
    return r;
};

export const createPackage = function (erm_package) {
    return _createEditPackage("POST", erm_package);
};
export const editPackage = function (erm_package) {
    return _createEditPackage("PUT", erm_package);
};

const _fetchPackage = async function (apiUrl, package_id) {
    if (!package_id) return;
    let erm_package;
    await fetch(apiUrl, {
        headers: {
            "x-koha-embed":
                "package_agreements,package_agreements.agreement,resources+count,vendor",
        },
    })
        .then(checkError)
        .then(
            (result) => {
                erm_package = result;
            },
            (error) => {
                setError(error);
            }
        );
    return erm_package;
};
export const fetchLocalPackage = function (package_id) {
    const apiUrl = "/api/v1/erm/eholdings/local/packages/" + package_id;
    return _fetchPackage(apiUrl, package_id);
};
export const fetchEBSCOPackage = function (package_id) {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/packages/" + package_id;
    return _fetchPackage(apiUrl, package_id);
};

export const _fetchPackages = async function (apiUrl) {
    let packages;
    await fetch(apiUrl, {
        headers: {
            "x-koha-embed": "resources+count,vendor.name",
        },
    })
        .then(checkError)
        .then(
            (result) => {
                packages = result;
            },
            (error) => {
                setError(error);
            }
        );
    return packages;
};
export const fetchLocalPackages = function () {
    const apiUrl = "/api/v1/erm/eholdings/local/packages";
    return _fetchPackages(apiUrl);
};
export const fetchEBSCOPackages = function () {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/packages";
    return _fetchPackages(apiUrl);
};

export const _fetchTitle = async function (apiUrl, title_id) {
    if (!title_id) return;
    let title;
    await fetch(apiUrl, {
        headers: {
            "x-koha-embed": "resources,resources.package",
        },
    })
        .then(checkError)
        .then(
            (result) => {
                title = result;
            },
            (error) => {
                setError(error);
            }
        );
    return title;
};
export const fetchLocalTitle = function (title_id) {
    const apiUrl = "/api/v1/erm/eholdings/local/titles/" + title_id;
    return _fetchTitle(apiUrl, title_id);
};
export const fetchEBSCOTitle = function (title_id) {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/titles/" + title_id;
    return _fetchTitle(apiUrl, title_id);
};

export const _fetchTitles = async function (apiUrl) {
    let titles;
    await fetch(apiUrl)
        .then(checkError)
        .then(
            (result) => {
                titles = result;
            },
            (error) => {
                setError(error);
            }
        );
    return titles;
};
export const fetchLocalTitles = function () {
    const apiUrl = "/api/v1/erm/eholdings/local/titles";
    return _fetchTitles(apiUrl);
};
export const fetchEBSCOTitles = function () {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/titles";
    return _fetchTitles(apiUrl);
};

export const _fetchResource = async function (apiUrl, resource_id) {
    if (!resource_id) return;
    let resource;
    await fetch(apiUrl, {
        headers: {
            "x-koha-embed": "title,package,vendor",
        },
    })
        .then(checkError)
        .then(
            (result) => {
                resource = result;
            },
            (error) => {
                setError(error);
            }
        );
    return resource;
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
    let resources;
    await fetch(apiUrl)
        .then(checkError)
        .then(
            (result) => {
                resources = result;
            },
            (error) => {
                setError(error);
            }
        );
    return resources;
};

export const fetchLocalResources = function () {
    const apiUrl = "/api/v1/erm/eholdings/local/resources";
    return _fetchResources(apiUrl);
};
export const fetchEBSCOResources = function () {
    const apiUrl = "/api/v1/erm/eholdings/ebsco/resources";
    return _fetchResources(apiUrl);
};

function checkError(response) {
    if (response.status >= 200 && response.status <= 299) {
        return response.json();
    } else {
        console.log("Server returned an error:");
        console.log(response);
        setError("%s (%s)".format(response.statusText, response.status));
    }
}
