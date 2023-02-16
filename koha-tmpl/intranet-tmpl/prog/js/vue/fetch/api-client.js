import ERMAPIClient from "./erm-api-client";
import PatronAPIClient from "./patron-api-client";
import AcquisitionAPIClient from "./acquisition-api-client";
import AVAPIClient from "./authorised-values";

export const APIClient = {
    erm: new ERMAPIClient(),
    patron: new PatronAPIClient(),
    acquisition: new AcquisitionAPIClient(),
    authorised_values: new AVAPIClient(),
};
