describe("Advanced Editor missing 008", () => {
    const frameworkDefault008 = "000000s2020    xx            000 0 eng d";
    const existing008 = "240101b        |||||||| |||| 00| 0 fin d";
    let frameworkCodes;
    let originalApplyFrameworkDefaults;
    let originalEnableAdvancedCatalogingEditor;
    let createdFrameworkCodes = [];
    let sampleBiblioId;
    let sampleBiblioIds = [];
    let sampleTitle;

    function createFrameworkWith008(frameworkCode, mandatory, defaultValue) {
        return cy
            .task("query", {
                sql: "INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES (?, ?)",
                values: [frameworkCode, "Cypress Advanced Editor 008"],
            })
            .then(() => {
                createdFrameworkCodes.push(frameworkCode);
                return cy.task("query", {
                    sql: "INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, important, authorised_value, ind1_defaultvalue, ind2_defaultvalue, frameworkcode) SELECT tagfield, liblibrarian, libopac, repeatable, mandatory, important, authorised_value, ind1_defaultvalue, ind2_defaultvalue, ? FROM marc_tag_structure WHERE frameworkcode = '' AND tagfield IN ('008', '245')",
                    values: [frameworkCode],
                });
            })
            .then(() =>
                cy.task("query", {
                    sql: "INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, important, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue, maxlength, display_order) SELECT tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, important, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, ?, seealso, link, defaultvalue, maxlength, display_order FROM marc_subfield_structure WHERE frameworkcode = '' AND tagfield IN ('008', '245')",
                    values: [frameworkCode],
                })
            )
            .then(() =>
                cy.task("query", {
                    sql: "UPDATE marc_tag_structure SET mandatory = ? WHERE tagfield = '008' AND frameworkcode = ?",
                    values: [mandatory, frameworkCode],
                })
            )
            .then(() =>
                cy.task("query", {
                    sql: "UPDATE marc_subfield_structure SET mandatory = ?, defaultvalue = ? WHERE tagfield = '008' AND tagsubfield = '@' AND frameworkcode = ?",
                    values: [mandatory, defaultValue, frameworkCode],
                })
            );
    }

    function createBiblioWithout008(frameworkCode) {
        sampleTitle = `Cypress Advanced Editor missing 008 ${Cypress._.random(
            100000,
            999999
        )}`;

        return cy
            .request({
                method: "POST",
                url: "/api/v1/biblios",
                failOnStatusCode: false,
                followRedirect: false,
                headers: {
                    Accept: "application/json",
                    "Content-Type": "application/marc-in-json",
                    "x-confirm-not-duplicate": 1,
                    "x-framework-id": frameworkCode,
                },
                body: {
                    leader: "     nam a22     7a 4500",
                    fields: [
                        {
                            "245": {
                                ind1: "",
                                ind2: "",
                                subfields: [{ a: sampleTitle }],
                            },
                        },
                    ],
                },
            })
            .then(response => {
                expect([200, 201, 302]).to.include(response.status);
                const isJson = String(
                    response.headers["content-type"] || ""
                ).includes("application/json");
                const result = isJson
                    ? typeof response.body === "string"
                        ? JSON.parse(response.body)
                        : response.body
                    : null;
                const locationMatch = String(
                    response.headers.location || ""
                ).match(/\/(\d+)$/);
                sampleBiblioId = result?.id || Number(locationMatch?.[1]);
                expect(sampleBiblioId).to.be.a("number").and.not.equal(0);
                sampleBiblioIds.push(sampleBiblioId);
            });
    }

    function add008ToSampleBiblio(value) {
        return cy.task("query", {
            sql: "UPDATE biblio_metadata SET metadata = REPLACE(metadata, '</leader>', CONCAT('</leader><controlfield tag=\"008\">', ?, '</controlfield>')) WHERE biblionumber = ?",
            values: [value, sampleBiblioId],
        });
    }

    function getBasicEditorGenerated008() {
        return cy
            .get("li[id^='tag_008_'] input.input_marceditor", {
                timeout: 30000,
            })
            .should("have.length", 1)
            .should("have.value", "")
            .click()
            .invoke("val")
            .then(value => String(value));
    }

    function getAdvancedEditorFieldValues(tag) {
        return cy
            .get("#editor .CodeMirror", { timeout: 30000 })
            .should("be.visible")
            .should($editor => {
                const text = ($editor[0] as any).CodeMirror.getValue();
                expect(text).to.contain(sampleTitle);
            })
            .then($editor => {
                const text = ($editor[0] as any).CodeMirror.getValue();
                return text
                    .split("\n")
                    .filter(line => line.startsWith(`${tag} `))
                    .map(line => line.substring(4));
            });
    }

    function openBasicEditorThenCompareAdvanced008(checkBasicValue) {
        cy.visit(
            `/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=${sampleBiblioId}`
        );
        getBasicEditorGenerated008().then(basic008 => {
            expect(basic008).to.have.length(40);
            checkBasicValue(basic008);

            cy.visit(
                `/cgi-bin/koha/cataloguing/editor.pl?cypress_test=${sampleBiblioId}#catalog/${sampleBiblioId}`
            );
            getAdvancedEditorFieldValues("008").should("deep.equal", [
                basic008,
            ]);
        });
    }

    before(() => {
        cy.login();
        cy.clearLocalStorage();
        return cy
            .task("query", {
                sql: "SELECT frameworkcode FROM biblio_framework",
            })
            .then(rows => {
                const existingCodes = new Set(
                    rows.map(row => row.frameworkcode)
                );
                const availableCodes = [];
                for (let i = 0; i < 36 ** 3 && availableCodes.length < 3; i++) {
                    const code = `Z${i
                        .toString(36)
                        .padStart(3, "0")
                        .toUpperCase()}`;
                    if (!existingCodes.has(code)) availableCodes.push(code);
                }
                expect(availableCodes).to.have.length(3);
                frameworkCodes = {
                    mandatoryBlank: availableCodes[0],
                    mandatoryDefault: availableCodes[1],
                    optionalBlank: availableCodes[2],
                };
            })
            .then(() =>
                cy.task("query", {
                    sql: "SELECT variable, value FROM systempreferences WHERE variable IN ('ApplyFrameworkDefaults', 'EnableAdvancedCatalogingEditor')",
                })
            )
            .then(rows => {
                const preferences = Object.fromEntries(
                    rows.map(row => [row.variable, row.value])
                );
                originalApplyFrameworkDefaults =
                    preferences.ApplyFrameworkDefaults;
                originalEnableAdvancedCatalogingEditor =
                    preferences.EnableAdvancedCatalogingEditor;
            })
            .then(() => cy.set_syspref("ApplyFrameworkDefaults", "new"))
            .then(() => cy.set_syspref("EnableAdvancedCatalogingEditor", 0))
            .then(() =>
                createFrameworkWith008(frameworkCodes.mandatoryBlank, 1, "")
            )
            .then(() =>
                createFrameworkWith008(
                    frameworkCodes.mandatoryDefault,
                    1,
                    frameworkDefault008
                )
            )
            .then(() =>
                createFrameworkWith008(frameworkCodes.optionalBlank, 0, "")
            );
    });

    beforeEach(() => {
        sampleBiblioId = null;
        sampleTitle = null;
        cy.login();
        cy.clearLocalStorage();
    });

    after(() => {
        let cleanup = cy.wrap(null);
        sampleBiblioIds.forEach(biblioId => {
            cleanup = cleanup.then(() =>
                cy.task("deleteSampleObjects", {
                    biblio: { biblio_id: biblioId },
                })
            );
        });
        createdFrameworkCodes.forEach(frameworkCode => {
            cleanup = cleanup
                .then(() =>
                    cy.task("query", {
                        sql: "DELETE FROM marc_subfield_structure WHERE frameworkcode = ?",
                        values: [frameworkCode],
                    })
                )
                .then(() =>
                    cy.task("query", {
                        sql: "DELETE FROM marc_tag_structure WHERE frameworkcode = ?",
                        values: [frameworkCode],
                    })
                )
                .then(() =>
                    cy.task("query", {
                        sql: "DELETE FROM biblio_framework WHERE frameworkcode = ?",
                        values: [frameworkCode],
                    })
                );
        });
        return cleanup
            .then(() =>
                cy.set_syspref(
                    "ApplyFrameworkDefaults",
                    originalApplyFrameworkDefaults
                )
            )
            .then(() =>
                cy.set_syspref(
                    "EnableAdvancedCatalogingEditor",
                    originalEnableAdvancedCatalogingEditor
                )
            );
    });

    it("initializes a missing mandatory 008 like the basic editor", () => {
        createBiblioWithout008(frameworkCodes.mandatoryBlank).then(() => {
            openBasicEditorThenCompareAdvanced008(value => {
                expect(value).not.to.equal(frameworkDefault008);
            });
        });
    });

    it("does not apply a framework default during ordinary editing", () => {
        createBiblioWithout008(frameworkCodes.mandatoryDefault).then(() => {
            openBasicEditorThenCompareAdvanced008(value => {
                expect(value).not.to.equal(frameworkDefault008);
            });
        });
    });

    it("preserves the existing blank-008 widget behavior", () => {
        createBiblioWithout008(frameworkCodes.mandatoryDefault)
            .then(() => add008ToSampleBiblio(""))
            .then(() => {
                cy.visit(
                    `/cgi-bin/koha/cataloguing/editor.pl?cypress_test=${sampleBiblioId}#catalog/${sampleBiblioId}`
                );
                getAdvancedEditorFieldValues("008").should(values => {
                    expect(values).to.have.length(1);
                    expect(values[0]).to.have.length(40);
                    expect(values[0]).not.to.equal(frameworkDefault008);
                });
            });
    });

    it("preserves an existing populated 008", () => {
        createBiblioWithout008(frameworkCodes.mandatoryBlank)
            .then(() => add008ToSampleBiblio(existing008))
            .then(() => {
                cy.visit(
                    `/cgi-bin/koha/cataloguing/editor.pl?cypress_test=${sampleBiblioId}#catalog/${sampleBiblioId}`
                );
                getAdvancedEditorFieldValues("008").should("deep.equal", [
                    existing008,
                ]);
            });
    });

    it("does not add an optional missing 008", () => {
        createBiblioWithout008(frameworkCodes.optionalBlank).then(() => {
            cy.visit(
                `/cgi-bin/koha/cataloguing/editor.pl?cypress_test=${sampleBiblioId}#catalog/${sampleBiblioId}`
            );
            getAdvancedEditorFieldValues("008").should("deep.equal", []);
        });
    });
});
