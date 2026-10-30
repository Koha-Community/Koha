// Notices management (tools/notices.pl), the Notices tab of a patron (members/notices.pl) and
// printing notices (members/print_notice.pl)
//
// The notices are queued directly in the database for patrons created here, and removed afterwards, as
// are the staff members. The preferences and the CONVERTED_TO_PRINT notice that are changed are restored.

const password = "Passw0rd!x";
const subjectPrefix = "cy-notice";

// A secret that must not be shown or printed
const sensitiveCodes = [
    "PASSWORD_RESET",
    "STAFF_PASSWORD_RESET",
    "OPAC_REG_VERIFY",
    "2FA_OTP_TOKEN",
];

const NOTICES_PERMISSION: [number, string] = [13, "view_generated_notices"];
const PATRONS_PERMISSION: [number, string] = [4, "edit_borrowers"];

describe("Notices management", { scrollBehavior: "center" }, () => {
    let patronCPL: { id: number }; // library CPL, patron category PT
    let patronMPL: { id: number }; // library MPL, patron category S
    let staff: { id: number; userid: string }[] = [];
    let savedPrefs: Record<string, string> = {};
    let savedTemplate: any[] = [];
    const prefs = ["NoticesManagement", "IndependentBranches", "RESTBasicAuth"];

    const query = (sql: string, values: any[] = []) =>
        cy.task("query", { sql, values });

    const setPrefs = (values: Record<string, string | number>) => {
        cy.visit("/cgi-bin/koha/mainpage.pl");
        Object.entries(values).forEach(([name, value]) =>
            cy.set_syspref(name, value)
        );
    };

    // Queue a notice, returns its id
    const queue = (
        patron: { id: number },
        values: Record<string, any> = {}
    ): Cypress.Chainable<number> => {
        const message = {
            subject: `${subjectPrefix}-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
            content: "Hello patron",
            message_transport_type: "email",
            status: "sent",
            letter_code: "HOLD",
            to_address: "patron@example.org",
            from_address: "library@example.org",
            content_type: "text/plain; charset=UTF-8",
            time_queued: "2026-01-15 10:00:00",
            ...values,
        };
        return cy
            .task("query", {
                sql: "INSERT INTO message_queue (borrowernumber, subject, content, message_transport_type, status, letter_code, to_address, from_address, content_type, time_queued) VALUES (?,?,?,?,?,?,?,?,?,?)",
                values: [
                    patron.id,
                    message.subject,
                    message.content,
                    message.message_transport_type,
                    message.status,
                    message.letter_code,
                    message.to_address,
                    message.from_address,
                    message.content_type,
                    message.time_queued,
                ],
            })
            .then(result => result.insertId as number);
    };

    const subjectOf = (id: number) =>
        query("SELECT subject FROM message_queue WHERE message_id = ?", [
            id,
        ]).then(rows => rows[0].subject as string);

    const statusOf = (id: number) =>
        query("SELECT status FROM message_queue WHERE message_id = ?", [
            id,
        ]).then(rows => rows[0].status as string);

    // A staff member with the permissions, who can log in
    const createStaff = (
        library: string,
        permissions: [number, string][]
    ): Cypress.Chainable<{ id: number; userid: string }> =>
        cy
            .task("insertSamplePatron", { library: { library_id: library } })
            .then(objects => {
                const id = objects.patron.patron_id;
                const userid = `cy_staff_${id}`;
                // Access to the staff interface (catalogue), and the modules of the permissions
                const flags = permissions.reduce(
                    (all, [bit]) => all | (1 << bit),
                    1 << 2
                );
                query(
                    "UPDATE borrowers SET userid = ?, flags = ?, branchcode = ?, categorycode = 'S', dateexpiry = '2099-01-01', login_attempts = 0, password_expiration_date = NULL WHERE borrowernumber = ?",
                    [userid, flags, library, id]
                );
                permissions.forEach(([module_bit, code]) =>
                    query(
                        "INSERT INTO user_permissions (borrowernumber, module_bit, code) VALUES (?,?,?)",
                        [id, module_bit, code]
                    )
                );
                cy.task("apiPost", {
                    endpoint: `/api/v1/patrons/${id}/password`,
                    body: { password, password_2: password },
                });
                const user = { id, userid };
                staff.push(user);
                return cy.wrap(user);
            });

    // Without the session of the superlibrarian, whose token the login form would otherwise take
    const loginAs = (user: { userid: string }) => {
        cy.clearAllCookies();
        cy.login(user.userid, password);
    };

    const visitNotices = (parameters = "") => {
        cy.visit(`/cgi-bin/koha/tools/notices.pl${parameters}`);
        cy.get("#notices").should("exist");
    };

    // The list on the page
    const listed = () => cy.get("#notices tbody tr");

    const row = (subject: string) => cy.contains("#notices tbody tr", subject);

    // Format a date in the format of the system, for the search
    const format = (iso: string, dateformat: string) => {
        const [year, month, day] = iso.split("-");
        return dateformat === "us"
            ? `${month}/${day}/${year}`
            : dateformat === "metric"
              ? `${day}/${month}/${year}`
              : iso;
    };

    before(() => {
        query(
            `SELECT variable, value FROM systempreferences WHERE variable IN (${prefs.map(() => "?").join(",")})`,
            prefs
        ).then(rows => rows.forEach(r => (savedPrefs[r.variable] = r.value)));
        query(
            "SELECT * FROM letter WHERE module = 'members' AND code = 'CONVERTED_TO_PRINT'"
        ).then(rows => (savedTemplate = rows));

        cy.task("insertSamplePatron", { library: { library_id: "CPL" } }).then(
            objects => {
                patronCPL = { id: objects.patron.patron_id };
                query(
                    "UPDATE borrowers SET branchcode = 'CPL', categorycode = 'PT', surname = 'CypressNotices' WHERE borrowernumber = ?",
                    [patronCPL.id]
                );
            }
        );
        cy.task("insertSamplePatron", { library: { library_id: "MPL" } }).then(
            objects => {
                patronMPL = { id: objects.patron.patron_id };
                query(
                    "UPDATE borrowers SET branchcode = 'MPL', categorycode = 'S', surname = 'CypressNotices' WHERE borrowernumber = ?",
                    [patronMPL.id]
                );
            }
        );
    });

    after(() => {
        query("DELETE FROM message_queue WHERE subject LIKE ?", [
            `${subjectPrefix}%`,
        ]);
        query(
            "DELETE FROM letter WHERE module = 'members' AND code = 'CONVERTED_TO_PRINT'"
        );
        savedTemplate.forEach(t =>
            query(
                "INSERT INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type, lang, style) VALUES (?,?,?,?,?,?,?,?,?,?)",
                [
                    t.module,
                    t.code,
                    t.branchcode,
                    t.name,
                    t.is_html,
                    t.title,
                    t.content,
                    t.message_transport_type,
                    t.lang,
                    t.style,
                ]
            )
        );
        [...staff.map(s => s.id), patronCPL?.id, patronMPL?.id]
            .filter(Boolean)
            .forEach(id => {
                query("DELETE FROM message_queue WHERE borrowernumber = ?", [
                    id,
                ]);
                query("DELETE FROM user_permissions WHERE borrowernumber = ?", [
                    id,
                ]);
                query("DELETE FROM borrowers WHERE borrowernumber = ?", [id]);
            });
        // The session of the last test is still valid
        setPrefs(savedPrefs);
    });

    beforeEach(() => {
        // The print page prints when it is shown, which would stop the browser on a dialog.
        // Wherever the page is reached from, including by submitting a form
        cy.on("window:before:load", win => {
            win.print = () => {
                (win as any).__printed = true;
            };
        });
        query("DELETE FROM message_queue WHERE subject LIKE ?", [
            `${subjectPrefix}%`,
        ]);
        cy.login();
        // RESTBasicAuth: the staff members are given their passwords through the API
        setPrefs({
            NoticesManagement: 1,
            IndependentBranches: 0,
            RESTBasicAuth: 1,
        });
    });

    describe("Access", () => {
        it("goes to the tools home when the notices management is disabled", () => {
            setPrefs({ NoticesManagement: 0 });
            cy.visit("/cgi-bin/koha/tools/notices.pl");
            cy.url().should("contain", "/tools/tools-home.pl");
        });

        it("is not available without the view_generated_notices permission", () => {
            createStaff("CPL", [PATRONS_PERMISSION]).then(user => {
                loginAs(user);
                cy.visit("/cgi-bin/koha/tools/notices.pl");
                cy.get("#notices").should("not.exist");
                cy.title().should("match", /Access denied|Log in/);
            });
        });

        it("is in the tools menu and on the tools home for who has the permission", () => {
            cy.visit("/cgi-bin/koha/tools/tools-home.pl");
            cy.contains("a", "Notices management").should("exist");
        });
    });

    describe("Filters", () => {
        let ids: Record<string, number> = {};
        let subjects: Record<string, string> = {};

        // Four notices of different types, statuses, patrons and dates
        beforeEach(() => {
            const seed = (
                name: string,
                patron: { id: number },
                values: Record<string, any>
            ) =>
                queue(patron, values).then(id => {
                    ids[name] = id;
                    return subjectOf(id).then(subject => {
                        subjects[name] = subject;
                    });
                });
            seed("hold_sent_cpl", patronCPL, {
                letter_code: "HOLD",
                status: "sent",
                time_queued: "2026-01-10 10:00:00",
            });
            seed("hold_failed_mpl", patronMPL, {
                letter_code: "HOLD",
                status: "failed",
                time_queued: "2026-01-15 23:30:00",
            });
            seed("checkout_sent_cpl", patronCPL, {
                letter_code: "CHECKOUT",
                status: "sent",
                time_queued: "2026-01-16 00:30:00",
            });
            seed("checkout_pending_mpl", patronMPL, {
                letter_code: "CHECKOUT",
                status: "pending",
                time_queued: "2026-01-20 12:00:00",
            });
        });

        const search = () =>
            cy.get("#notices-search input[type='submit']").click();

        // Only these of the four notices queued here are listed. There can be other notices in
        // the database, which are not looked at
        const only = (...names: string[]) => {
            names.forEach(name => row(subjects[name]).should("exist"));
            Object.keys(subjects)
                .filter(name => !names.includes(name))
                .forEach(name =>
                    cy.get("#notices").should("not.contain", subjects[name])
                );
        };

        it("lists the notices of the patrons, the most recent first", () => {
            visitNotices("?status=");
            listed().then($rows => {
                const text = [...$rows].map(r => r.textContent);
                const position = (name: string) =>
                    text.findIndex(t => t.includes(subjects[name]));
                expect(position("checkout_pending_mpl")).to.be.lessThan(
                    position("checkout_sent_cpl")
                );
                expect(position("checkout_sent_cpl")).to.be.lessThan(
                    position("hold_failed_mpl")
                );
                expect(position("hold_failed_mpl")).to.be.lessThan(
                    position("hold_sent_cpl")
                );
            });
        });

        it("filters on the status, which stays selected", () => {
            visitNotices("?status=failed");
            only("hold_failed_mpl");
            cy.get("#status").should("have.value", "failed");

            visitNotices("?status=pending");
            only("checkout_pending_mpl");
            cy.get("#status").should("have.value", "pending");
        });

        it("filters on the notice type", () => {
            visitNotices("?letter_code=CHECKOUT");
            only("checkout_sent_cpl", "checkout_pending_mpl");
            cy.get("#letter_code").should("have.value", "CHECKOUT");
        });

        it("filters on the patron category", () => {
            visitNotices("?categorycode=S");
            only("hold_failed_mpl", "checkout_pending_mpl");
            visitNotices("?categorycode=PT");
            only("hold_sent_cpl", "checkout_sent_cpl");
        });

        it("filters on the library of the patron", () => {
            visitNotices("?branchcode=MPL");
            only("hold_failed_mpl", "checkout_pending_mpl");
            visitNotices("?branchcode=CPL");
            only("hold_sent_cpl", "checkout_sent_cpl");
            // The label says what it is
            cy.get("label[for='branchcode']").should(
                "contain",
                "Patron library"
            );
        });

        it("filters on the dates, which are included", () => {
            query(
                "SELECT value FROM systempreferences WHERE variable = 'dateformat'"
            ).then(rows => {
                const dateformat = rows[0].value;

                // The notices of one day, whatever the time
                visitNotices(
                    `?from=${format("2026-01-15", dateformat)}&to=${format("2026-01-15", dateformat)}`
                );
                only("hold_failed_mpl");

                visitNotices(
                    `?from=${format("2026-01-15", dateformat)}&to=${format("2026-01-16", dateformat)}`
                );
                only("hold_failed_mpl", "checkout_sent_cpl");

                visitNotices(`?from=${format("2026-01-16", dateformat)}`);
                only("checkout_sent_cpl", "checkout_pending_mpl");

                visitNotices(`?to=${format("2026-01-10", dateformat)}`);
                only("hold_sent_cpl");
            });
        });

        it("ignores a date that is not one", () => {
            visitNotices("?from=not-a-date&status=failed");
            only("hold_failed_mpl");
        });

        it("combines the filters", () => {
            visitNotices(
                "?letter_code=HOLD&status=sent&branchcode=CPL&categorycode=PT"
            );
            only("hold_sent_cpl");

            // Nothing matches, and then there is no table
            cy.visit(
                "/cgi-bin/koha/tools/notices.pl?letter_code=HOLD&status=sent&branchcode=MPL"
            );
            cy.get("#notices-search").should("exist");
            Object.values(subjects).forEach(subject =>
                cy.get("body").should("not.contain", subject)
            );
        });

        it("searches with the form", () => {
            visitNotices("?status=");
            cy.get("#status").select("failed");
            cy.get("#branchcode").select("MPL");
            search();
            only("hold_failed_mpl");
            cy.get("#status").should("have.value", "failed");
            cy.get("#branchcode").should("have.value", "MPL");
        });

        it("offers the statuses that notices can have, including printed and converted", () => {
            visitNotices();
            [
                "sent",
                "pending",
                "failed",
                "deleted",
                "printed",
                "converted",
            ].forEach(status =>
                cy.get(`#status option[value='${status}']`).should("exist")
            );
        });
    });

    describe("Restrictions", () => {
        let subjectCPL: string;
        let subjectMPL: string;
        let idMPL: number;

        beforeEach(() => {
            queue(patronCPL).then(id =>
                subjectOf(id).then(subject => (subjectCPL = subject))
            );
            queue(patronMPL).then(id => {
                idMPL = id;
                return subjectOf(id).then(subject => (subjectMPL = subject));
            });
        });

        it("shows the notices of all the patrons to who can see all the patrons", () => {
            visitNotices("?status=");
            cy.then(() => {
                row(subjectCPL).should("exist");
                row(subjectMPL).should("exist");
            });
            cy.get("#branchcode").should("exist");
        });

        it("only shows the notices of the patrons of their library with IndependentBranches", () => {
            setPrefs({ IndependentBranches: 1 });
            createStaff("CPL", [NOTICES_PERMISSION, PATRONS_PERMISSION]).then(
                user => {
                    loginAs(user);
                    visitNotices("?status=");
                    cy.then(() => {
                        row(subjectCPL).should("exist");
                        cy.get("#notices").should("not.contain", subjectMPL);
                    });
                    // Asking for them does not show them either
                    cy.visit(
                        "/cgi-bin/koha/tools/notices.pl?status=&branchcode=MPL"
                    );
                    cy.get("#notices-search").should("exist");
                    cy.then(() =>
                        cy.get("body").should("not.contain", subjectMPL)
                    );
                    // Only one library can be seen: nothing to filter on
                    cy.get("#branchcode").should("not.exist");
                }
            );
        });

        it("cannot print the notice of a patron of another library", () => {
            setPrefs({ IndependentBranches: 1 });
            createStaff("CPL", [NOTICES_PERMISSION, PATRONS_PERMISSION]).then(
                user => {
                    loginAs(user);
                    cy.visit(
                        `/cgi-bin/koha/members/print_notice.pl?message_ids=${idMPL}`
                    );
                    cy.get("iframe.notice-frame").should("not.exist");
                    cy.contains("No notices were found to print").should(
                        "exist"
                    );
                    statusOf(idMPL).should("eq", "sent");
                }
            );
        });

        it("does not give an error for notices that do not exist or that are not numbers", () => {
            cy.visit(
                "/cgi-bin/koha/members/print_notice.pl?message_ids=99999999&message_ids=abc"
            );
            cy.contains("No notices were found to print").should("exist");
        });
    });

    describe("Printing", () => {
        const printPage = (ids: number[]) =>
            cy.visit(
                `/cgi-bin/koha/members/print_notice.pl?${ids.map(id => `message_ids=${id}`).join("&")}`
            );

        it("shows each notice in a frame that cannot run anything", () => {
            queue(patronCPL, {
                content_type: "text/html; charset=UTF-8",
                content:
                    '<script>window.parent.__pwned = 1</script><img src=x onerror="window.parent.__pwned = 2"><p>Visible text</p>',
            }).then(id => {
                printPage([id]);
                cy.get("iframe.notice-frame")
                    .should("have.length", 1)
                    .and("have.attr", "sandbox")
                    .and("not.contain", "allow-scripts");
                cy.get("iframe.notice-frame")
                    .its("0.contentDocument.body")
                    .should("contain.text", "Visible text");
                cy.window().its("__pwned").should("be.undefined");
            });
        });

        it("shows the notices as text when they are", () => {
            queue(patronCPL, { content: "1 < 2 & <b>not bold</b>" }).then(
                id => {
                    printPage([id]);
                    cy.get("iframe.notice-frame")
                        .its("0.contentDocument.body")
                        .should("contain.text", "1 < 2 & <b>not bold</b>");
                }
            );
        });

        it("puts the notices one after the other, each in full", () => {
            queue(patronCPL, { content: "First notice" }).then(first =>
                queue(patronCPL, { content: "Second notice" }).then(second => {
                    printPage([first, second]);
                    cy.get("iframe.notice-frame").should("have.length", 2);
                    cy.get("div.pagebreak").should("have.length", 1);
                    cy.get("iframe.notice-frame")
                        .eq(1)
                        .its("0.contentDocument.body")
                        .should("contain.text", "Second notice");
                    // Sized to their content
                    cy.get("iframe.notice-frame")
                        .first()
                        .invoke("attr", "style")
                        .should("match", /height: \d+px/);
                })
            );
        });

        it("starts printing when the page is shown", () => {
            queue(patronCPL).then(id => {
                cy.visit(
                    `/cgi-bin/koha/members/print_notice.pl?message_ids=${id}`
                );
                cy.get("iframe.notice-frame").should("exist");
                cy.window().its("__printed").should("eq", true);
            });
        });

        it("does not change the notice when only showing it", () => {
            queue(patronCPL).then(id => {
                printPage([id]);
                cy.get("iframe.notice-frame").should("exist");
                statusOf(id).should("eq", "sent");
            });
        });

        it("marks a notice printed when printing it from the list", () => {
            queue(patronCPL).then(id => {
                visitNotices("?status=sent");
                cy.get("#print_single").invoke("removeAttr", "target");
                subjectOf(id).then(subject =>
                    row(subject).find("button.print").click()
                );
                cy.url().should("contain", "print_notice.pl");
                statusOf(id).should("eq", "printed");
            });
        });

        it("marks the notices printed when printing the selected ones", () => {
            queue(patronCPL).then(first =>
                queue(patronMPL).then(second => {
                    visitNotices("?status=sent");
                    cy.get("#print_multiple").invoke("removeAttr", "target");
                    [first, second].forEach(id =>
                        cy
                            .get(`input[name='message_ids'][value='${id}']`)
                            .check()
                    );
                    cy.get("#print_multiple_button").click();
                    cy.url().should("contain", "print_notice.pl");
                    statusOf(first).should("eq", "printed");
                    statusOf(second).should("eq", "printed");
                })
            );
        });

        sensitiveCodes.forEach(code => {
            it(`does not show or print the content of ${code} notices`, () => {
                queue(patronCPL, {
                    letter_code: code,
                    content:
                        "Reset your password: https://example.org/secret-token",
                }).then(id => {
                    printPage([id]);
                    cy.contains("No notices were found to print").should(
                        "exist"
                    );
                    cy.get("iframe.notice-frame").should("not.exist");
                    statusOf(id).should("eq", "sent");

                    // The notice is listed, without its content
                    visitNotices("?status=sent");
                    subjectOf(id).then(subject => {
                        row(subject).should("exist");
                        row(subject)
                            .find("iframe.notice")
                            .should("have.attr", "srcdoc")
                            .and("not.contain", "secret-token");
                        row(subject).find("button.print").should("not.exist");
                    });
                });
            });
        });

        it("does not print pending notices, unless they are print notices", () => {
            queue(patronCPL, { status: "pending" }).then(email => {
                queue(patronCPL, {
                    status: "pending",
                    message_transport_type: "print",
                }).then(print => {
                    printPage([email, print]);
                    cy.get("iframe.notice-frame").should("have.length", 1);
                    cy.get(`iframe.notice-frame#notice_${print}`).should(
                        "exist"
                    );
                    cy.get(`iframe.notice-frame#notice_${email}`).should(
                        "not.exist"
                    );
                });
            });
        });

        it("does not print converted notices, their print notice is", () => {
            queue(patronCPL, { status: "converted" }).then(id => {
                printPage([id]);
                cy.contains("No notices were found to print").should("exist");
            });
        });

        it("needs a request that changes things, with its token, to mark notices printed", () => {
            queue(patronCPL).then(id => {
                // A request without the CSRF token is refused
                cy.request({
                    method: "POST",
                    url: "/cgi-bin/koha/members/print_notice.pl",
                    form: true,
                    body: { op: "cud-print", message_ids: id },
                    failOnStatusCode: false,
                }).then(response => {
                    expect(response.status).to.be.oneOf([200, 400, 403]);
                });
                statusOf(id).should("eq", "sent");
            });
        });
    });

    describe("Converting to print", () => {
        const setTemplate = (content: string | null) => {
            query(
                "DELETE FROM letter WHERE module = 'members' AND code = 'CONVERTED_TO_PRINT'"
            );
            if (content !== null) {
                query(
                    "INSERT INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES ('members', 'CONVERTED_TO_PRINT', '', 'Notice converted to print', 1, '[% original_message.subject %]', ?, 'print', 'default')",
                    [content]
                );
            }
        };
        const goodTemplate =
            "<p>[% borrower.address %]</p><p>[% original_message.status %]</p>[% original_message.content_as_html %]";

        const convertButton = (subject: string) =>
            row(subject).find("button.convert");

        beforeEach(() => setTemplate(goodTemplate));

        it("converts a notice to a print notice, and links the two", () => {
            queue(patronCPL, { status: "failed" }).then(id => {
                visitNotices("?status=failed");
                subjectOf(id).then(subject => convertButton(subject).click());

                cy.contains(
                    ".alert-success",
                    "converted to a print notice"
                ).should("exist");
                statusOf(id).should("eq", "converted");
                query(
                    "SELECT message_id, status, message_transport_type, failure_code FROM message_queue WHERE borrowernumber = ? AND failure_code = ?",
                    [patronCPL.id, `CONVERTED_FROM:${id}`]
                ).then(rows => {
                    expect(rows).to.have.length(1);
                    expect(rows[0].status).to.equal("pending");
                    expect(rows[0].message_transport_type).to.equal("print");
                    query(
                        "SELECT failure_code FROM message_queue WHERE message_id = ?",
                        [id]
                    ).then(original =>
                        expect(original[0].failure_code).to.equal(
                            `CONVERTED_TO_PRINT:${rows[0].message_id}`
                        )
                    );

                    // Both are told apart on the page
                    visitNotices("?status=converted");
                    cy.contains(
                        "#notices tbody tr",
                        `Converted to print notice ${rows[0].message_id}`
                    ).should("exist");
                    visitNotices("?status=pending");
                    cy.contains(
                        "#notices tbody tr",
                        `Converted from notice ${id}`
                    ).should("exist");
                });
            });
        });

        it("queues a print notice that has the address, the original and what happened to it", () => {
            queue(patronCPL, {
                status: "sent",
                content: "The original words",
            }).then(id => {
                visitNotices("?status=sent");
                subjectOf(id).then(subject => convertButton(subject).click());
                query(
                    "SELECT content FROM message_queue WHERE failure_code = ?",
                    [`CONVERTED_FROM:${id}`]
                ).then(rows => {
                    expect(rows[0].content).to.contain("The original words");
                    expect(rows[0].content).to.contain("sent");
                });
            });
        });

        it("can be done from the Notices tab of the patron", () => {
            queue(patronCPL, { status: "failed" }).then(id => {
                cy.visit(
                    `/cgi-bin/koha/members/notices.pl?borrowerNumber=${patronCPL.id}&borrowernumber=${patronCPL.id}`
                );
                subjectOf(id).then(subject =>
                    cy
                        .contains("#noticestable tbody tr", subject)
                        .find("button.convert")
                        .click()
                );
                cy.contains(
                    ".alert-success",
                    "converted to a print notice"
                ).should("exist");
                statusOf(id).should("eq", "converted");
            });
        });

        it("is only offered for the notices that can be converted", () => {
            // The most recent, which are listed first: the page lists a number of them at a time
            const now = new Date().toISOString().slice(0, 19).replace("T", " ");
            const ids: Record<string, number> = {};
            const seed = (name: string, values: Record<string, any>) =>
                queue(patronCPL, { time_queued: now, ...values }).then(id => {
                    ids[name] = id;
                });
            seed("pending", { status: "pending" });
            seed("print", { status: "sent", message_transport_type: "print" });
            seed("secret", { status: "sent", letter_code: "PASSWORD_RESET" });
            seed("converted", { status: "converted" });
            seed("sent", { status: "sent" });

            cy.then(() => {
                visitNotices("?status=");
                ["pending", "print", "secret", "converted"].forEach(name =>
                    subjectOf(ids[name]).then(subject =>
                        row(subject).find("button.convert").should("not.exist")
                    )
                );
                subjectOf(ids.sent).then(subject =>
                    convertButton(subject).should("exist")
                );
            });
        });

        it("is not offered when the CONVERTED_TO_PRINT notice does not exist", () => {
            setTemplate(null);
            queue(patronCPL, { status: "sent" }).then(id => {
                visitNotices("?status=sent");
                subjectOf(id).then(subject => {
                    row(subject).find("button.convert").should("not.exist");
                    // Nor to print it
                    row(subject).find("button.print").should("exist");
                });
                cy.visit(
                    `/cgi-bin/koha/members/notices.pl?borrowernumber=${patronCPL.id}`
                );
                cy.get("button.convert:visible").should("not.exist");
            });
        });

        it("says what is missing when asked to convert without the CONVERTED_TO_PRINT notice", () => {
            queue(patronCPL, { status: "sent" }).then(id => {
                visitNotices("?status=sent");
                subjectOf(id).then(subject =>
                    convertButton(subject).should("exist")
                );
                // The notice is deleted after the page was shown
                cy.then(() => setTemplate(null));
                subjectOf(id).then(subject => convertButton(subject).click());

                cy.get(".alert-danger")
                    .should(
                        "contain",
                        "CONVERTED_TO_PRINT notice does not exist"
                    )
                    .and("contain", "Notices and slips");
                statusOf(id).should("eq", "sent");
            });
        });

        it("says that the notice has an error, and logs it, when it cannot be processed", () => {
            queue(patronCPL, { status: "sent" }).then(id => {
                setTemplate("<p>[% IF 1 %] never closed</p>");
                visitNotices("?status=sent");
                subjectOf(id).then(subject => convertButton(subject).click());

                cy.get(".alert-danger")
                    .should("contain", "CONVERTED_TO_PRINT notice has an error")
                    .and("contain", "Notices and slips");
                // Nothing was changed
                statusOf(id).should("eq", "sent");
                query(
                    "SELECT COUNT(*) AS n FROM message_queue WHERE failure_code = ?",
                    [`CONVERTED_FROM:${id}`]
                ).then(rows => expect(rows[0].n).to.equal(0));
            });
        });

        it("says that the notice has an error for an unknown variable too", () => {
            queue(patronCPL, { status: "sent" }).then(id => {
                setTemplate("<p>[% borrower.biblio.title %]</p>");
                visitNotices("?status=sent");
                subjectOf(id).then(subject => convertButton(subject).click());
                cy.get(".alert-danger").should("contain", "has an error");
                statusOf(id).should("eq", "sent");
            });
        });

        it("cannot convert the notice of a patron of another library", () => {
            setPrefs({ IndependentBranches: 1 });
            queue(patronMPL, { status: "sent" }).then(id =>
                createStaff("CPL", [
                    NOTICES_PERMISSION,
                    PATRONS_PERMISSION,
                ]).then(user => {
                    loginAs(user);
                    visitNotices("?status=");
                    subjectOf(id).then(subject =>
                        cy.get("#notices").should("not.contain", subject)
                    );
                    statusOf(id).should("eq", "sent");
                })
            );
        });

        it("converts the notice of a patron of their library for a staff member who is limited to it", () => {
            setPrefs({ IndependentBranches: 1 });
            queue(patronCPL, { status: "sent" }).then(id =>
                createStaff("CPL", [
                    NOTICES_PERMISSION,
                    PATRONS_PERMISSION,
                ]).then(user => {
                    loginAs(user);
                    // The case that died, as the patrons are joined to limit the notices
                    cy.visit(
                        `/cgi-bin/koha/members/notices.pl?borrowernumber=${patronCPL.id}`
                    );
                    subjectOf(id).then(subject =>
                        cy
                            .contains("#noticestable tbody tr", subject)
                            .find("button.convert")
                            .click()
                    );
                    cy.contains(
                        ".alert-success",
                        "converted to a print notice"
                    ).should("exist");
                    statusOf(id).should("eq", "converted");
                })
            );
        });
    });

    describe("Notices tab of a patron", () => {
        it("has the actions for who has the view_generated_notices permission", () => {
            queue(patronCPL).then(id => {
                cy.visit(
                    `/cgi-bin/koha/members/notices.pl?borrowernumber=${patronCPL.id}`
                );
                subjectOf(id).then(subject => {
                    cy.contains("#noticestable tbody tr", subject)
                        .find("button.print")
                        .should("exist");
                });
            });
        });

        it("does not have the print actions for who does not", () => {
            queue(patronCPL).then(id =>
                createStaff("CPL", [PATRONS_PERMISSION]).then(user => {
                    loginAs(user);
                    cy.visit(
                        `/cgi-bin/koha/members/notices.pl?borrowernumber=${patronCPL.id}`
                    );
                    subjectOf(id).then(subject => {
                        cy.contains("#noticestable tbody tr", subject).should(
                            "exist"
                        );
                        cy.get("#noticestable button.print").should(
                            "not.exist"
                        );
                        cy.get("#noticestable button.convert").should(
                            "not.exist"
                        );
                    });
                })
            );
        });

        it("shows the content of the notices in frames that cannot run anything", () => {
            queue(patronCPL, {
                content_type: "text/html; charset=UTF-8",
                content:
                    "<script>window.parent.__pwned = 1</script><p>Shown</p>",
            }).then(id => {
                cy.visit(
                    `/cgi-bin/koha/members/notices.pl?borrowernumber=${patronCPL.id}`
                );
                subjectOf(id).then(subject =>
                    cy
                        .contains("#noticestable tbody tr", subject)
                        .find("iframe.notice")
                        .should("have.attr", "sandbox", "")
                );
                cy.window().its("__pwned").should("be.undefined");
            });
        });

        it("does not show the content of the notices that contain a secret", () => {
            queue(patronCPL, {
                letter_code: "PASSWORD_RESET",
                content: "https://example.org/reset?token=secret-token",
            }).then(id => {
                cy.visit(
                    `/cgi-bin/koha/members/notices.pl?borrowernumber=${patronCPL.id}`
                );
                subjectOf(id).then(subject =>
                    cy
                        .contains("#noticestable tbody tr", subject)
                        .find("iframe.notice")
                        .should("have.attr", "srcdoc")
                        .and("not.contain", "secret-token")
                );
            });
        });
    });
});
