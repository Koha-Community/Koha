import AdditionalFieldsAPIClient from "@fetch/additional-fields-api-client";
import HttpClient from "@fetch/http-client";

describe("AdditionalFieldsAPIClientWrapper", () => {
    it("Correctly loads the wrapper when called", () => {
        const client = new AdditionalFieldsAPIClient(HttpClient);
        expect(client).to.have.property("clients");
    });
    it("Can correctly pick a module based on a resource type", () => {
        const client = new AdditionalFieldsAPIClient(HttpClient);
        const getModuleName = client.getModuleName;
        expect(getModuleName("agreement")).to.eq("erm");
        expect(getModuleName("license")).to.eq("erm");
        expect(getModuleName("package")).to.eq("erm");
        expect(getModuleName()).to.eq("admin");
        expect(getModuleName("dummyModule")).to.eq("admin");
    });
    it("Can correctly call the endpoint for that module", async () => {
        const client = new AdditionalFieldsAPIClient(HttpClient);

        const ermResult = await client.additional_fields.getAll("agreement");
        expect(ermResult.url).to.include("v1/erm/extended");

        const adminResult = await client.additional_fields.getAll();
        expect(adminResult.url).to.include("v1/extended");
    });
});
