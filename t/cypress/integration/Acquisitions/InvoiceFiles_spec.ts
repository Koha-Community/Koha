describe("Invoice files - Bug 42080: File type handling and CSP headers", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.task("buildSampleObject", {
            object: "vendor",
            values: { active: 1 },
        })
            .then(generatedVendor => {
                delete generatedVendor.list_currency;
                delete generatedVendor.invoice_currency;
                return cy.task("insertObject", {
                    type: "vendor",
                    object: generatedVendor,
                });
            })
            .then(vendor => {
                cy.wrap(vendor).as("vendor");
                return cy.task("buildSampleObject", {
                    object: "invoice",
                    values: { vendor_id: vendor.id },
                });
            })
            .then(generatedInvoice => {
                return cy.task("insertObject", {
                    type: "invoice",
                    object: generatedInvoice,
                });
            })
            .then(invoice => {
                cy.wrap(invoice).as("invoice");
            });

        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='AcqEnableFiles'",
        }).then(value => {
            cy.wrap(value).as("syspref_AcqEnableFiles");
        });

        cy.set_syspref("AcqEnableFiles", 1);
    });

    afterEach(function () {
        const invoice = this.invoice;
        if (invoice && invoice.invoice_id) {
            cy.task("query", {
                sql: "DELETE FROM misc_files WHERE table_tag = 'aqinvoices' AND record_id = ?",
                values: [invoice.invoice_id],
            });
        }
        cy.task("deleteSampleObjects", [
            { vendor: this.vendor, invoice: this.invoice },
        ]);
        cy.set_syspref("AcqEnableFiles", this.syspref_AcqEnableFiles);
    });

    it("should serve PDF files inline with CSP header", function () {
        const invoice = this.invoice;

        cy.task("insertObject", {
            type: "invoice_file",
            object: {
                invoice_id: invoice.invoice_id,
                file_name: "test.pdf",
                file_type: "application/pdf",
                file_content: "hex:255044462d312e340a0a",
                file_description: "Test PDF",
            },
        }).then(file => {
            cy.wrap(file).as("pdfFile");
        });

        cy.get("@pdfFile").then(file => {
            cy.request(
                `/cgi-bin/koha/acqui/invoice-files.pl?invoiceid=${invoice.invoice_id}&op=download&view=1&file_id=${file.file_id}`
            ).then(response => {
                expect(response.headers["content-security-policy"]).to.include(
                    "default-src 'none'"
                );
                expect(response.headers["content-type"]).to.include(
                    "application/pdf"
                );
            });
        });
    });

    it("should force download when view parameter is not present", function () {
        const invoice = this.invoice;

        cy.task("insertObject", {
            type: "invoice_file",
            object: {
                invoice_id: invoice.invoice_id,
                file_name: "test.pdf",
                file_type: "application/pdf",
                file_content: "hex:255044462d312e340a0a",
                file_description: "Test PDF",
            },
        }).then(file => {
            cy.wrap(file).as("pdfFile");
        });

        cy.get("@pdfFile").then(file => {
            cy.request(
                `/cgi-bin/koha/acqui/invoice-files.pl?invoiceid=${invoice.invoice_id}&op=download&file_id=${file.file_id}`
            ).then(response => {
                expect(response.headers["content-disposition"]).to.include(
                    "attachment"
                );
                expect(response.headers["content-disposition"]).to.include(
                    file.file_name
                );
            });
        });
    });
});
