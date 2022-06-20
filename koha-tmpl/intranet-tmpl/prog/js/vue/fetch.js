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

export const fetchPackage = async function (package_id) {
    if (!package_id) return;
    const apiUrl = "/api/v1/erm/eholdings/packages/" + package_id;
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

export const fetchPackages = async function () {
    const apiUrl = "/api/v1/erm/eholdings/packages";
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

export const fetchTitle = async function (title_id) {
    if (!title_id) return;
    const apiUrl = "/api/v1/erm/eholdings/titles/" + title_id;
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

export const fetchTitles = async function () {
    const apiUrl = "/api/v1/erm/eholdings/titles";
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

export const fetchResource = async function (resource_id) {
    if (!resource_id) return;
    const apiUrl = "/api/v1/erm/eholdings/resources/" + resource_id;
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

export const fetchResources = async function () {
    const apiUrl = "/api/v1/erm/eholdings/resources";
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

export const fetchPackageResources = async function (package_id) {
    const apiUrl =
        "/api/v1/erm/eholdings/packages/" + package_id + "/resources";
    let resources;
    await fetch(apiUrl, {
        headers: {
            "x-koha-embed": "title.publication_title",
        },
    })
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

function checkError(response) {
    if (response.status >= 200 && response.status <= 299) {
        return response.json();
    } else {
        console.log("Server returned an error:");
        console.log(response);
        setError("%s (%s)".format(response.statusText, response.status));
    }
}
