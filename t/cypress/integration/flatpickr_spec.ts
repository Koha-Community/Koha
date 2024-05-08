import { mount } from "@cypress/vue";

const dayjs = require("dayjs");

const dates = {
    today_iso: dayjs().format("YYYY-MM-DD"),
    today_us: dayjs().format("MM/DD/YYYY"),
    tomorrow_iso: dayjs().add(1, "day").format("YYYY-MM-DD"),
    tomorrow_us: dayjs().add(1, "day").format("MM/DD/YYYY"),
};

describe("Flatpickr", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("'Clear filter' works correctly", () => {
        cy.visit("/cgi-bin/koha/circ/overdue.pl");

        cy.get("#from+span > input").click();
        cy.get(".flatpickr-calendar")
            .eq(0)
            .find("span.today")
            .click({ force: true });
        cy.get("#from").invoke("val").should("eq", dates["today_iso"]);

        cy.get("#from+span > a").click();
        cy.get("#from").invoke("val").should("have.length", 0);

        cy.get("#from+span > input").should("exist");
    });
});
