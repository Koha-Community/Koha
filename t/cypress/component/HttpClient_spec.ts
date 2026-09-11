import HttpClient from "@fetch/http-client";

function jsonResponse(body, status = 200) {
    const text = JSON.stringify(body);
    return {
        ok: status >= 200 && status < 300,
        status,
        statusText: "",
        headers: {
            get: name =>
                name.toLowerCase() === "content-type"
                    ? "application/json"
                    : null,
        },
        json: async () => body,
        text: async () => text,
    };
}

describe("HttpClient", () => {
    let consoleErrorStub;
    let fetchStub;

    beforeEach(() => {
        document.body.innerHTML = '<div id="messages"></div>';
        consoleErrorStub = cy.stub(console, "error");
        fetchStub = cy.stub(window, "fetch");
    });

    it("returns successful JSON responses", async () => {
        fetchStub.resolves(jsonResponse({ result: "ok" }));
        const client = new HttpClient({ baseURL: "/api/v1/" });

        const result = await client.get({ endpoint: "test" });

        expect(result).to.deep.equal({ result: "ok" });
        expect(fetchStub.calledOnce).to.equal(true);
        expect(consoleErrorStub.called).to.equal(false);
    });

    it("preserves structured API failure details", async () => {
        fetchStub.resolves(
            jsonResponse(
                {
                    errors: [{ message: "First" }, { message: "Second" }],
                    error_code: "invalid_input",
                },
                422
            )
        );
        const client = new HttpClient();

        const error = await client
            .get({
                endpoint: "/test",
                config: { suppressDefaultErrorDialog: true },
            })
            .catch(caught => caught);

        expect(error).to.be.an.instanceOf(Error);
        expect(error.message).to.equal("First\nSecond");
        expect(error.status).to.equal(422);
        expect(error.code).to.equal("invalid_input");
    });

    it("rethrows the original network Error", async () => {
        const originalError = new Error("Network unavailable");
        fetchStub.callsFake(() => Promise.reject(originalError));
        const client = new HttpClient();

        const error = await client
            .get({
                endpoint: "/test",
                config: { suppressDefaultErrorDialog: true },
            })
            .catch(caught => caught);

        expect(error).to.equal(originalError);
    });

    it("shows the default error dialog", async () => {
        fetchStub.resolves(jsonResponse({ error: "Request failed" }, 500));
        const client = new HttpClient();

        await client.get({ endpoint: "/test" }).catch(() => undefined);

        expect(
            document.querySelector("#messages .alert-warning")?.textContent
        ).to.contain("Request failed");
    });

    it("suppresses the default error dialog when requested", async () => {
        fetchStub.resolves(jsonResponse({ error: "Request failed" }, 500));
        const client = new HttpClient();

        await client
            .get({
                endpoint: "/test",
                config: { suppressDefaultErrorDialog: true },
            })
            .catch(() => undefined);

        expect(document.querySelector("#messages .alert-warning")).to.equal(
            null
        );
    });
});
