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
                this.setError(error);
            }
        );
    return agreement;
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
                this.setError(error);
            }
        );
    return license;
};
