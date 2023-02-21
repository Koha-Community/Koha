import ERMAPIClient from "./erm-api-client";
import PatronAPIClient from "./patron-api-client";
import AcquisitionAPIClient from "./acquisition-api-client";

export const APIClient = {
    erm: new ERMAPIClient(),
    patron: new PatronAPIClient(),
    acquisition: new AcquisitionAPIClient(),
};