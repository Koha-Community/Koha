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

    // Framework configuration has no REST CRUD routes, so setup and cleanup use
    // parameterized SQL scoped to the temporary frameworks created by this spec.
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

    function createSampleBiblio(frameworkCode, field008?: string) {
        sampleTitle = `Cypress Advanced Editor missing 008 ${Cypress._.random(
            100000,
            999999
        )}`;

        return cy
            .request({
                method: "POST",
                url: "/api/v1/biblios",
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
                        ...(field008 === undefined
                            ? []
                            : [{ "008": field008 }]),
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
                expect(response.status).to.equal(200);
                expect(response.headers["content-type"]).to.include(
                    "application/json"
                );
                sampleBiblioId = response.body.id;
                expect(sampleBiblioId).to.be.a("number").and.be.greaterThan(0);
                sampleBiblioIds.push(sampleBiblioId);
            })
            .then(() =>
                cy.request({
                    url: `/api/v1/biblios/${sampleBiblioId}`,
                    headers: { Accept: "application/marc-in-json" },
                })
            )
            .then(response => {
                expect(response.status).to.equal(200);
                const record =
                    typeof response.body === "string"
                        ? JSON.parse(response.body)
                        : response.body;
                const values = record.fields
                    .filter(field => "008" in field)
                    .map(field => field["008"]);
                expect(values).to.deep.equal(
                    field008 === undefined ? [] : [field008]
                );
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

    function assertAdvancedEditorFieldValues(tag, assertValues) {
        return cy
            .get("#editor .CodeMirror", { timeout: 30000 })
            .should($editor => {
                expect($editor).to.be.visible;
                const text = ($editor[0] as any).CodeMirror.getValue();
                expect(text).to.contain(sampleTitle);
                const values = text
                    .split("\n")
                    .filter(line => line.startsWith(`${tag} `))
                    .map(line => line.substring(4));
                assertValues(values);
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
            assertAdvancedEditorFieldValues("008", values => {
                expect(values).to.deep.equal([basic008]);
            });
        });
    }

    before(() => {
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
                cy.task("apiGet", {
                    endpoint:
                        "/api/v1/sysprefs?q=" +
                        encodeURIComponent(
                            JSON.stringify({
                                variable: {
                                    "-in": [
                                        "ApplyFrameworkDefaults",
                                        "EnableAdvancedCatalogingEditor",
                                    ],
                                },
                            })
                        ),
                })
            )
            .then(rows => {
                expect(rows).to.have.length(2);
                const preferences = Object.fromEntries(
                    rows.map(row => [row.variable, row.value])
                );
                originalApplyFrameworkDefaults =
                    preferences.ApplyFrameworkDefaults;
                originalEnableAdvancedCatalogingEditor =
                    preferences.EnableAdvancedCatalogingEditor;
            })
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
        cy.get("#logged-in-menu").should("be.visible");
        cy.clearLocalStorage();
        cy.set_syspref("ApplyFrameworkDefaults", "new");
        cy.set_syspref("EnableAdvancedCatalogingEditor", 0);
    });

    after(() => {
        if (originalApplyFrameworkDefaults !== undefined) {
            cy.set_syspref(
                "ApplyFrameworkDefaults",
                originalApplyFrameworkDefaults
            );
        }
        if (originalEnableAdvancedCatalogingEditor !== undefined) {
            cy.set_syspref(
                "EnableAdvancedCatalogingEditor",
                originalEnableAdvancedCatalogingEditor
            );
        }

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
        return cleanup;
    });

    it("initializes a missing mandatory 008 like the basic editor", () => {
        createSampleBiblio(frameworkCodes.mandatoryBlank).then(() => {
            openBasicEditorThenCompareAdvanced008(value => {
                expect(value).not.to.equal(frameworkDefault008);
            });
        });
    });

    it("does not apply a framework default during ordinary editing", () => {
        createSampleBiblio(frameworkCodes.mandatoryDefault).then(() => {
            openBasicEditorThenCompareAdvanced008(value => {
                expect(value).not.to.equal(frameworkDefault008);
            });
        });
    });

    it("preserves the existing blank-008 widget behavior", () => {
        createSampleBiblio(frameworkCodes.mandatoryDefault, "").then(() => {
            cy.visit(
                `/cgi-bin/koha/cataloguing/editor.pl?cypress_test=${sampleBiblioId}#catalog/${sampleBiblioId}`
            );
            assertAdvancedEditorFieldValues("008", values => {
                expect(values).to.have.length(1);
                expect(values[0]).to.have.length(40);
                expect(values[0]).not.to.equal(frameworkDefault008);
            });
        });
    });

    it("preserves an existing populated 008", () => {
        createSampleBiblio(frameworkCodes.mandatoryBlank, existing008).then(
            () => {
                cy.visit(
                    `/cgi-bin/koha/cataloguing/editor.pl?cypress_test=${sampleBiblioId}#catalog/${sampleBiblioId}`
                );
                assertAdvancedEditorFieldValues("008", values => {
                    expect(values).to.deep.equal([existing008]);
                });
            }
        );
    });

    it("does not add an optional missing 008", () => {
        createSampleBiblio(frameworkCodes.optionalBlank).then(() => {
            cy.visit(
                `/cgi-bin/koha/cataloguing/editor.pl?cypress_test=${sampleBiblioId}#catalog/${sampleBiblioId}`
            );
            assertAdvancedEditorFieldValues("008", values => {
                expect(values).to.deep.equal([]);
            });
        });
    });
});
