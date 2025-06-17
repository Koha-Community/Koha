describe("circ/pendingreserves/holdst", () => {
    const table_id = "holdst";
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.task("insertSampleBiblio", {
            item_count: 2,
            options: { different_libraries: true },
        }).then(objects_biblio_1 => {
            cy.wrap(objects_biblio_1).as("objects_biblio_1");
            const commonLibraryId = objects_biblio_1.items[0].home_library_id;
            cy.task("insertSampleHold", {
                biblio: objects_biblio_1.biblio,
                library_id: commonLibraryId,
            }).then(objects_hold_1 => {
                cy.wrap(objects_hold_1).as("objects_hold_1");
            });
            cy.task("insertSampleBiblio", { item_count: 1 }).then(
                objects_biblio_2 => {
                    cy.wrap(objects_biblio_2).as("objects_biblio_2");
                    cy.task("insertSampleHold", {
                        biblio: objects_biblio_2.biblio,
                        library_id: objects_biblio_2.items[0].home_library_id,
                    }).then(objects_hold_2 => {
                        cy.wrap(objects_hold_2).as("objects_hold_2");
                    });
                    cy.task("query", {
                        sql: "UPDATE items SET homebranch=?, holdingbranch=? WHERE itemnumber=?",
                        values: [
                            commonLibraryId,
                            commonLibraryId,
                            objects_biblio_2.items[0].item_id,
                        ],
                    });
                }
            );
        });
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", [
            this.objects_hold_1,
            this.objects_hold_2,
            this.objects_biblio_1,
            this.objects_biblio_2,
        ]);
    });

    it("Should render library filters", function () {
        cy.visit(
            "/cgi-bin/koha/circ/pendingreserves.pl?from=2000-01-01&to=2999-12-31&run_report=Submit"
        );

        cy.get(`#${table_id} thead tr:eq(1) th:eq(5)`).should(
            "have.text",
            "Libraries"
        );

        // select has library names in value and text, this table is not using server-side processing
        let libraries = this.objects_biblio_1.libraries
            .map(library => library.name)
            .sort();
        cy.get(`#${table_id} thead tr:eq(1) th:eq(5) select`)
            .children()
            .should("have.length", 3)
            .then(options => {
                expect(options.eq(0).val()).to.eq("");
                expect(options.eq(1).val()).to.eq(libraries[0]);
                expect(options.eq(2).val()).to.eq(libraries[1]);
            });
    });

    it("Should filter table on library", function () {
        cy.visit(
            "/cgi-bin/koha/circ/pendingreserves.pl?from=2000-01-01&to=2999-12-31&run_report=Submit"
        );

        cy.get(`#${table_id} thead tr:eq(1) th:eq(5) select`).select(
            this.objects_biblio_1.libraries[0].name,
            { force: true }
        );
        cy.get(`#${table_id} tbody tr:eq(0) td:eq(4)`).should(
            "contain",
            this.objects_biblio_1.biblio.title
        );
        cy.get(`#${table_id} tbody tr:eq(1) td:eq(4)`).should(
            "contain",
            this.objects_biblio_2.biblio.title
        );
        cy.get(`#${table_id} tbody tr`).should("have.length", 2);

        cy.get(`#${table_id} thead tr:eq(1) th:eq(5) select`).select(
            this.objects_biblio_1.libraries[1].name
        );
        cy.get(`#${table_id} tbody tr:eq(0) td:eq(4)`).should(
            "contain",
            this.objects_biblio_1.biblio.title
        );
        cy.get(`#${table_id} tbody tr`).should("have.length", 1);
    });
});
