import Alert from "@koha-vue/components/Alert.vue";

describe("Alert", () => {
    it("does not make static information an assertive announcement", () => {
        cy.mount(Alert, {
            props: {
                message: "Booking constraint active",
            },
        });

        cy.get(".alert").should("contain.text", "Booking constraint active");
        cy.get(".alert").should("not.have.attr", "role");
        cy.get(".alert").should("not.have.attr", "aria-live");
    });

    it("supports an explicit polite status contract", () => {
        cy.mount(Alert, {
            props: {
                message: "No items are available",
                role: "status",
                live: "polite",
            },
        });

        cy.get(".alert")
            .should("have.attr", "role", "status")
            .and("have.attr", "aria-live", "polite");
    });

    it("supports an explicit assertive alert contract", () => {
        cy.mount(Alert, {
            props: {
                message: "The booking could not be saved",
                role: "alert",
                live: "assertive",
            },
        });

        cy.get(".alert")
            .should("have.attr", "role", "alert")
            .and("have.attr", "aria-live", "assertive");
    });
});
