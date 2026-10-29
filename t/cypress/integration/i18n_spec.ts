describe("i18n.js", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    // Translations in the misc/translator/po2json format of locale_data.js:
    // msgid_plural (or null) first, then the translations
    const json_locale_data = {
        Koha: {
            "": {
                Language: " ru-RU",
                "Plural-Forms":
                    " nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;",
            },
            Title: [null, "Заглавие"],
            "{count} item": [
                "{count} items",
                "{count} экземпляр",
                "{count} экземпляра",
                "{count} экземпляров",
            ],
            "Verb\u0004Hold": [null, "Зарезервировать"],
            "Noun\u0004{count} hold": [
                "{count} holds",
                "{count} резервирование",
                "{count} резервирования",
                "{count} резервирований",
            ],
            "{count} empty": ["{count} empties", "", "", ""],
        },
    };

    it("Translates with the locale data, without Gettext.js", () => {
        cy.visit("/cgi-bin/koha/mainpage.pl", {
            onBeforeLoad(win) {
                win.json_locale_data = json_locale_data;
            },
        });
        cy.window().then(win => {
            expect(win.Gettext).to.be.undefined;

            expect(win.__("Title")).to.eq("Заглавие");
            expect(win.__("Untranslated")).to.eq("Untranslated");
            expect(win.__x("{count} item", { count: 3 })).to.eq("3 экземпляр");

            // Russian plural forms
            [
                [1, "{count} экземпляр"],
                [2, "{count} экземпляра"],
                [5, "{count} экземпляров"],
                [11, "{count} экземпляров"],
                [21, "{count} экземпляр"],
                [22, "{count} экземпляра"],
            ].forEach(([count, expected]) => {
                expect(
                    win.__n("{count} item", "{count} items", count),
                    `count=${count}`
                ).to.eq(expected);
            });
            expect(
                win.__nx("{count} item", "{count} items", 5, { count: 5 })
            ).to.eq("5 экземпляров");

            // Context
            expect(win.__p("Verb", "Hold")).to.eq("Зарезервировать");
            expect(win.__p("Other", "Hold")).to.eq("Hold");
            expect(win.__np("Noun", "{count} hold", "{count} holds", 3)).to.eq(
                "{count} резервирования"
            );

            // Untranslated plural strings, with empty translations or not in
            // the locale data, use the English plural forms
            [1, 5, 21].forEach(count => {
                const plural = count != 1;
                expect(
                    win.__n("{count} empty", "{count} empties", count),
                    `count=${count}`
                ).to.eq(plural ? "{count} empties" : "{count} empty");
                expect(
                    win.__n("{count} unknown", "{count} unknowns", count),
                    `count=${count}`
                ).to.eq(plural ? "{count} unknowns" : "{count} unknown");
            });
        });
    });

    it("Accepts a count given as a string", () => {
        // Plural rule with a strict-equality sensitive comparison
        const de_locale_data = {
            Koha: {
                "": {
                    Language: " de-DE",
                    "Plural-Forms": " nplurals=2; plural=(n != 1);",
                },
                "{count} item": [
                    "{count} items",
                    "{count} Exemplar",
                    "{count} Exemplare",
                ],
            },
        };
        cy.visit("/cgi-bin/koha/mainpage.pl", {
            onBeforeLoad(win) {
                win.json_locale_data = de_locale_data;
            },
        });
        cy.window().then(win => {
            // e.g. the "X-Total-Count" header value
            ["1", 1].forEach(count => {
                expect(
                    win.__n("{count} item", "{count} items", count),
                    `count=${typeof count} ${count}`
                ).to.eq("{count} Exemplar");
            });
            ["0", "2", "21"].forEach(count => {
                expect(
                    win.__n("{count} item", "{count} items", count),
                    `count=${count}`
                ).to.eq("{count} Exemplare");
            });
            // Untranslated plural string
            expect(win.__n("{count} unknown", "{count} unknowns", "1")).to.eq(
                "{count} unknown"
            );
        });
    });

    it("Uses the English plural forms without locale data", () => {
        cy.visit("/cgi-bin/koha/mainpage.pl");
        cy.window().then(win => {
            expect(win.__("Title")).to.eq("Title");
            expect(win.__n("{count} item", "{count} items", 0)).to.eq(
                "{count} items"
            );
            expect(win.__n("{count} item", "{count} items", 1)).to.eq(
                "{count} item"
            );
            expect(win.__n("{count} item", "{count} items", 2)).to.eq(
                "{count} items"
            );
            expect(win.__p("Verb", "Hold")).to.eq("Hold");
        });
    });
});
