describe("Patron self-renewal", () => {
    beforeEach(() => {
        cy.task("buildSampleObject", {
            object: "patron_category",
            values: {
                self_renewal_enabled: 1,
                self_renewal_availability_start: 10,
                self_renewal_if_expired: 10,
                self_renewal_failure_message: "This cypress renewal has failed",
                self_renewal_information_message:
                    "This should display before renewal",
                self_renewal_fines_block: 0,
            },
        }).then(patron_category => {
            cy.task("insertObject", {
                type: "category",
                object: patron_category,
            }).then(patron_category => {
                cy.wrap(patron_category).as("patron_category");
                cy.task("insertSamplePatron", {
                    patron_category,
                    patronValues: {
                        password: "Cypress1234",
                        email: "test@email.com",
                        secondary_email: "test@email.com",
                        altaddress_email: "test@email.com",
                    },
                }).then(objects_patron => {
                    cy.wrap(objects_patron).as("objects_patron");
                    cy.loginOpac(
                        objects_patron.patron.cardnumber,
                        "Cypress1234"
                    );
                });
            });
        });
    });

    afterEach(function () {
        this.objects_patron.category = this.patron_category;
        cy.task("deleteSampleObjects", this.objects_patron);
    });

    it("should display a message that self renewal is available", function () {
        cy.visitOpac("/cgi-bin/koha/opac-user.pl");
        cy.get("#self_renewal_available").contains(
            "You are eligible for self-renewal. Please click here to renew your account"
        );
    });
    it("should open the modal for self-renewal", function () {
        cy.visitOpac("/cgi-bin/koha/opac-user.pl");
        cy.get("#patronSelfRenewal", { timeout: 10000 });
        cy.get("#self_renewal_available a").click();
        cy.get("#patronSelfRenewal").should("be.visible");
    });
    it("should verify that the patron wants to renew their account", function () {
        cy.visitOpac("/cgi-bin/koha/opac-user.pl");
        cy.env(["opacBaseUrl"]).then(({ opacBaseUrl }) => {
            cy.intercept(
                "GET",
                opacBaseUrl +
                    "/api/v1/public/patrons/*/self_renewal?_per_page=-1",
                {
                    self_renewal_settings: {
                        opac_patron_details: "0",
                        self_renewal_failure_message:
                            "Your self-renewal can't be processed at this time. Please visit your local branch to complete your renewal.",
                    },
                }
            ).as("renewalConfig");
        });
        cy.get("#patronSelfRenewal", { timeout: 10000 });
        cy.get("#self_renewal_available a").click();
        cy.wait("@renewalConfig");
        cy.get("#patronSelfRenewal .verification_question").contains(
            "Are you sure you want to renew your account?"
        );
    });
    it("should renew a patron's account", function () {
        cy.visitOpac("/cgi-bin/koha/opac-user.pl");
        cy.env(["opacBaseUrl"]).then(({ opacBaseUrl }) => {
            cy.intercept(
                "GET",
                opacBaseUrl +
                    "/api/v1/public/patrons/*/self_renewal?_per_page=-1",
                {
                    self_renewal_settings: {
                        opac_patron_details: "0",
                        self_renewal_failure_message:
                            "Your self-renewal can't be processed at this time. Please visit your local branch to complete your renewal.",
                    },
                }
            ).as("renewalConfig");
        });
        cy.get("#patronSelfRenewal", { timeout: 10000 });
        cy.get("#self_renewal_available a").click();
        cy.wait("@renewalConfig");
        cy.env(["opacBaseUrl"]).then(({ opacBaseUrl }) => {
            cy.intercept(
                "POST",
                opacBaseUrl + "/api/v1/public/patrons/*/self_renewal",
                {
                    statusCode: 201,
                    body: {
                        expiry_date: "2099-01-01",
                        confirmation_sent: true,
                    },
                }
            ).as("submitRenewal");
        });
        cy.get("#patronSelfRenewal .verification_actions")
            .contains("Yes")
            .click();
        cy.wait("@submitRenewal");
        cy.get("#self_renewal_success").contains(
            "Your account has been successfully renewed"
        );
    });
    it("should display an information message step", function () {
        cy.visitOpac("/cgi-bin/koha/opac-user.pl");
        cy.env(["opacBaseUrl"]).then(({ opacBaseUrl }) => {
            cy.intercept(
                "GET",
                opacBaseUrl +
                    "/api/v1/public/patrons/*/self_renewal?_per_page=-1",
                {
                    self_renewal_settings: {
                        opac_patron_details: "0",
                        self_renewal_failure_message:
                            "Your self-renewal can't be processed at this time. Please visit your local branch to complete your renewal.",
                        self_renewal_information_messages: [
                            "This should be shown",
                        ],
                    },
                }
            ).as("renewalConfig");
        });
        cy.get("#patronSelfRenewal", { timeout: 10000 });
        cy.get("#self_renewal_available a").click();
        cy.wait("@renewalConfig");
        cy.env(["opacBaseUrl"]).then(({ opacBaseUrl }) => {
            cy.intercept(
                "POST",
                opacBaseUrl + "/api/v1/public/patrons/*/self_renewal",
                {
                    statusCode: 201,
                    body: {
                        expiry_date: "2099-01-01",
                        confirmation_sent: true,
                    },
                }
            ).as("submitRenewal");
        });
        cy.get("#patronSelfRenewal .verification_question").contains(
            "This should be shown"
        );
        cy.get("#patronSelfRenewal .verification_actions")
            .contains("Yes")
            .click();

        cy.get("#patronSelfRenewal .verification_actions")
            .contains("Yes")
            .click();
        cy.wait("@submitRenewal");
        cy.get("#self_renewal_success").contains(
            "Your account has been successfully renewed"
        );
    });
    it("should confirm patron details if required", function () {
        cy.visitOpac("/cgi-bin/koha/opac-user.pl");
        cy.env(["opacBaseUrl"]).then(({ opacBaseUrl }) => {
            cy.intercept(
                "GET",
                opacBaseUrl +
                    "/api/v1/public/patrons/*/self_renewal?_per_page=-1",
                {
                    self_renewal_settings: {
                        opac_patron_details: "1",
                        self_renewal_failure_message:
                            "Your self-renewal can't be processed at this time. Please visit your local branch to complete your renewal.",
                    },
                }
            ).as("renewalConfig");
        });
        cy.get("#patronSelfRenewal", { timeout: 10000 });
        cy.get("#self_renewal_available a").click();
        cy.wait("@renewalConfig");

        cy.get("#patronSelfRenewal legend").contains(
            "Confirm your account details"
        );
        cy.get("#patronSelfRenewal button").contains("Continue").click();

        cy.get("h1").contains("Your personal details");
        cy.get("#update-account div.alert.alert-info").contains(
            "Please verify your details to proceed with your self-renewal"
        );
        cy.env(["opacBaseUrl"]).then(({ opacBaseUrl }) => {
            cy.intercept(
                "POST",
                opacBaseUrl + "/api/v1/public/patrons/*/self_renewal",
                {
                    statusCode: 201,
                    body: {
                        expiry_date: "2099-01-01",
                        confirmation_sent: true,
                    },
                }
            ).as("submitRenewal");
        });
        cy.get("#update-account fieldset.action input[type='submit']")
            .contains("Submit renewal request")
            .click();
        cy.wait("@submitRenewal");
        cy.get("#self_renewal_success").contains(
            "Your account has been successfully renewed"
        );
    });
});
