import { setError } from "./messages";

export const fetchAgreement = async function (agreement_id) {
    if (!agreement_id) return;
    const apiUrl = "/api/v1/erm/agreements/" + agreement_id;
    let agreement;
    await fetch(apiUrl, {
        headers: {
            "x-koha-embed":
                "periods,user_roles,user_roles.patron,agreement_licenses,agreement_licenses.license",
        },
    })
        .then((res) => res.json())
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
        .then((res) => res.json())
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
        .then((res) => res.json())
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
        .then((res) => res.json())
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
        .then((res) => res.json())
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
        .then((res) => res.json())
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
