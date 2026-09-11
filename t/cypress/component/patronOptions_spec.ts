import {
    formatPatronName,
    patronToOption,
    resolvePatronOption,
} from "@koha-vue/utils/patron-options.js";
import { APIClient } from "@koha-vue/fetch/api-client.js";

describe("formatPatronName", () => {
    it("joins preferred name and surname in the default order", () => {
        expect(
            formatPatronName({ preferred_name: "Jane", surname: "Doe" })
        ).to.equal("Jane Doe");
    });

    it("inverts to 'Surname, Preferred' when invertName is set", () => {
        expect(
            formatPatronName(
                { preferred_name: "Jane", surname: "Doe" },
                { invertName: true }
            )
        ).to.equal("Doe, Jane");
    });

    it("appends the middle name to the preferred name", () => {
        expect(
            formatPatronName({
                preferred_name: "Jane",
                middle_name: "Q",
                surname: "Doe",
            })
        ).to.equal("Jane Q Doe");
    });

    it("appends the other name in parentheses", () => {
        expect(
            formatPatronName({
                preferred_name: "Jane",
                other_name: "JD",
                surname: "Doe",
            })
        ).to.equal("Jane (JD) Doe");
    });

    it("appends the legal firstname in brackets when it differs and showDiffFirstname is set", () => {
        expect(
            formatPatronName(
                {
                    preferred_name: "Jane",
                    firstname: "Janet",
                    surname: "Doe",
                },
                { showDiffFirstname: true }
            )
        ).to.equal("Jane [Janet] Doe");
    });

    it("does not append a bracketed firstname when it matches the preferred name", () => {
        expect(
            formatPatronName(
                {
                    preferred_name: "Jane",
                    firstname: "Jane",
                    surname: "Doe",
                },
                { showDiffFirstname: true }
            )
        ).to.equal("Jane Doe");
    });

    it("falls back to a library-attributed placeholder when there is no name", () => {
        expect(
            formatPatronName({ library: { name: "Main Library" } })
        ).to.equal("A patron from Main Library");
    });

    it("falls back to a generic placeholder when there is no name or library", () => {
        expect(formatPatronName({})).to.equal("A patron from another library");
    });

    it("hides the name when hidePatronName is set", () => {
        expect(
            formatPatronName(
                { preferred_name: "Jane", surname: "Doe" },
                { hidePatronName: true }
            )
        ).to.equal("");
    });

    it("appends the cardnumber when displayCardnumber is set", () => {
        expect(
            formatPatronName(
                {
                    preferred_name: "Jane",
                    surname: "Doe",
                    cardnumber: "12345",
                },
                { displayCardnumber: true }
            )
        ).to.equal("Jane Doe (12345)");
    });

    it("shows only the cardnumber when the name is hidden and displayCardnumber is set", () => {
        expect(
            formatPatronName(
                {
                    preferred_name: "Jane",
                    surname: "Doe",
                    cardnumber: "12345",
                },
                { hidePatronName: true, displayCardnumber: true }
            )
        ).to.equal("12345");
    });

    it("does not apply hidePatronName or displayCardnumber to the no-name fallback", () => {
        expect(
            formatPatronName(
                { library: { name: "Main Library" }, cardnumber: "12345" },
                { hidePatronName: true, displayCardnumber: true }
            )
        ).to.equal("A patron from Main Library");
    });
});

describe("patronToOption", () => {
    it("returns null for a null patron", () => {
        expect(patronToOption(null)).to.equal(null);
    });

    it("builds a label and preserves the raw patron fields", () => {
        const option = patronToOption({
            patron_id: 42,
            preferred_name: "Jane",
            surname: "Doe",
        });
        expect(option.label).to.equal("Jane Doe");
        expect(option.patron_id).to.equal(42);
    });

    it("computes age from date_of_birth", () => {
        const today = new Date();
        const dob = new Date(
            today.getFullYear() - 7,
            today.getMonth(),
            today.getDate()
        );
        const option = patronToOption({
            surname: "Doe",
            date_of_birth: dob.toISOString().slice(0, 10),
        });
        expect(option._age).to.equal(7);
    });

    it("sets age to null when there is no date_of_birth", () => {
        const option = patronToOption({ surname: "Doe" });
        expect(option._age).to.equal(null);
    });

    it("extracts the embedded library name", () => {
        const option = patronToOption({
            surname: "Doe",
            library: { name: "Main Library" },
        });
        expect(option._libraryName).to.equal("Main Library");
    });

    it("surfaces expired and restricted flags", () => {
        const option = patronToOption({
            surname: "Doe",
            expired: true,
            restricted: true,
        });
        expect(option._expired).to.equal(true);
        expect(option._restricted).to.equal(true);
    });

    it("flags the option as the current library when loggedInLibraryId matches", () => {
        const option = patronToOption(
            { surname: "Doe", library_id: "CPL" },
            { loggedInLibraryId: "CPL" }
        );
        expect(option._isCurrentLibrary).to.equal(true);
    });

    it("does not flag the current library when loggedInLibraryId is not supplied", () => {
        const option = patronToOption({ surname: "Doe", library_id: "CPL" });
        expect(option._isCurrentLibrary).to.equal(false);
    });

    it("extracts city and country", () => {
        const option = patronToOption({
            surname: "Doe",
            city: "Springfield",
            country: "USA",
        });
        expect(option._city).to.equal("Springfield");
        expect(option._country).to.equal("USA");
    });
});

describe("resolvePatronOption", () => {
    it("returns null when given a nullish id", async () => {
        expect(await resolvePatronOption(null)).to.equal(null);
    });

    it("maps an already-fetched patron object without calling the API", async () => {
        cy.stub(APIClient.patron.httpClient, "get").as("get");
        const option = await resolvePatronOption({
            patron_id: 42,
            surname: "Doe",
        });
        expect(option.label).to.equal("Doe");
        cy.get("@get").should("not.have.been.called");
    });

    it("fetches and maps the patron when given a bare id", async () => {
        cy.stub(APIClient.patron.httpClient, "get")
            .resolves({ patron_id: 42, surname: "Doe" })
            .as("get");
        const option = await resolvePatronOption(42);
        expect(option.label).to.equal("Doe");
        cy.get("@get").should("have.been.calledWith", {
            endpoint: "patrons/42",
            headers: undefined,
            config: undefined,
        });
    });
});
