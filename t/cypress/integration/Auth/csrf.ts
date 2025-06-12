import { mount } from "@cypress/vue";

const branchcode = "TEST_LIB";
const branchname = "test_branchname";

function cleanup() {
    const sql = "DELETE FROM branches WHERE branchcode=?";
    cy.task("query", { sql, values: [branchcode] });
}

describe("CSRF", () => {
    beforeEach(() => {
        cleanup();
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    afterEach(() => {
        cleanup();
    });

    it("Add using POST without csrf", () => {
        cy.visit("/cgi-bin/koha/admin/branches.pl");

        cy.get("#newbranch").click();
        cy.get("#Aform").find("input[name='csrf_token']").invoke("remove");
        cy.get("#branchcode").type(branchcode);
        cy.get("#branchname").type(branchname);
        cy.get("#Aform").contains("Submit").click();

        cy.get(".main")
            .find(".alert")
            .contains(/No CSRF token passed for POST/);

        cy.task("query", {
            sql: "SELECT COUNT(*) as count FROM branches WHERE branchcode=?",
            values: [branchcode],
        }).then(result => {
            expect(result[0].count).to.equal(0);
        });
    });

    it("Add using POST with invalid csrf", () => {
        cy.visit("/cgi-bin/koha/admin/branches.pl");

        cy.get("#newbranch").click();
        cy.get("#Aform").find("input[name='csrf_token']").invoke("val", "foo");
        cy.get("#branchcode").type(branchcode);
        cy.get("#branchname").type(branchname);
        cy.get("#Aform").contains("Submit").click();

        cy.get(".main")
            .find(".alert")
            .contains(/Wrong CSRF token/);

        cy.task("query", {
            sql: "SELECT COUNT(*) as count FROM branches WHERE branchcode=?",
            values: [branchcode],
        }).then(result => {
            expect(result[0].count).to.equal(0);
        });
    });

    it("Add using GET", () => {
        // Trying correct op=cud-add_validate
        cy.visit(
            "/cgi-bin/koha/admin/branches.pl?op=cud-add_validate&branchcode=" +
                branchcode +
                "&branchname=" +
                branchname,
            { failOnStatusCode: false }
        );

        cy.get(".main")
            .find(".alert")
            .contains(
                /Programming error - op 'cud-add_validate' must not start with 'cud-' for GET/
            );

        // Trying incorrect op=add_validate
        cy.visit(
            "/cgi-bin/koha/admin/branches.pl?op=add_validate&branchcode=" +
                branchcode +
                "&branchname=" +
                branchname
        );

        // We do not display a message
        // We do not want Wrong CSRF token here
        cy.get(".message").should("not.exist");

        cy.task("query", {
            sql: "SELECT COUNT(*) as count FROM branches WHERE branchcode=?",
            values: [branchcode],
        }).then(result => {
            expect(result[0].count).to.equal(0);
        });
    });

    it("Add", () => {
        cy.visit("/cgi-bin/koha/admin/branches.pl");

        cy.get("#newbranch").click();
        cy.get("#branchcode").type(branchcode);
        cy.get("#branchname").type(branchname);
        cy.get("#Aform").contains("Submit").click();

        cy.get(".main")
            .find(".alert")
            .contains(/Library added successfully/);

        cy.get("select[name='libraries_length']").select("-1");
        cy.get("td").contains(branchcode);

        cy.task("query", {
            sql: "SELECT COUNT(*) as count FROM branches WHERE branchcode=?",
            values: [branchcode],
        }).then(result => {
            expect(result[0].count).to.equal(1);
        });
    });

    it("Delete without CSRF", () => {
        cy.task("query", {
            sql: "INSERT INTO branches(branchcode, branchname) VALUES (?, ?)",
            values: [branchcode, branchname],
        });

        cy.visit("/cgi-bin/koha/admin/branches.pl");
        cy.get("select[name='libraries_length']").select("-1");
        cy.get("#delete_library_" + branchcode).click({ force: true });

        // Remove CSRF Token
        cy.get("form[method='post']")
            .find("input[name='csrf_token']")
            .invoke("remove");

        cy.contains("Yes, delete").click();

        cy.get(".main")
            .find(".alert")
            .contains(/No CSRF token passed for POST/);

        cy.task("query", {
            sql: "SELECT COUNT(*) as count FROM branches WHERE branchcode=?",
            values: [branchcode],
        }).then(result => {
            expect(result[0].count).to.equal(1);
        });
    });

    it("Delete", () => {
        cy.task("query", {
            sql: "INSERT INTO branches(branchcode, branchname) VALUES (?, ?)",
            values: [branchcode, branchname],
        });

        cy.visit("/cgi-bin/koha/admin/branches.pl");
        cy.get("select[name='libraries_length']").select("-1");
        cy.get("#delete_library_" + branchcode).click({ force: true });

        cy.contains("Yes, delete").click();

        cy.get(".main")
            .find(".alert")
            .contains(/Library deleted successfully/);

        cy.task("query", {
            sql: "SELECT COUNT(*) as count FROM branches WHERE branchcode=?",
            values: [branchcode],
        }).then(result => {
            expect(result[0].count).to.equal(0);
        });
    });
});
