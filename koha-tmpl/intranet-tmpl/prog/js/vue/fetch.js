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
    const apiUrl = "/api/v1/erm/packages/" + package_id;
    let erm_package;
    await fetch(apiUrl, {
        headers: {
            "x-koha-embed": "package_agreements,package_agreements.agreement",
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
    const apiUrl = "/api/v1/erm/packages";
    let packages;
    await fetch(apiUrl)
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

export const fetchEHolding = async function (eholding_id) {
    if (!eholding_id) return;
    const apiUrl = "/api/v1/erm/eholdings/" + eholding_id;
    let erm_eholding;
    await fetch(apiUrl)
        .then(checkError)
        .then(
            (result) => {
                erm_eholding = result;
            },
            (error) => {
                setError(error);
            }
        );
    return erm_eholding;
};

export const fetchEHoldings = async function () {
    const apiUrl = "/api/v1/erm/eholdings";
    let eholdings;
    await fetch(apiUrl)
        .then(checkError)
        .then(
            (result) => {
                eholdings = result;
            },
            (error) => {
                setError(error);
            }
        );
    return eholdings;
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
