import HttpClient from "./http-client";

import ERMAPIClient from "@fetch/erm-api-client";
import PatronAPIClient from "@fetch/patron-api-client";
import AcquisitionAPIClient from "@fetch/acquisition-api-client";
import AdditionalFieldsAPIClient from "@fetch/additional-fields-api-client";
import AVAPIClient from "@fetch/authorised-values-api-client";
import ItemAPIClient from "@fetch/item-api-client";
import RecordSourcesAPIClient from "@fetch/record-sources-api-client";
import SysprefAPIClient from "@fetch/system-preferences-api-client";
import PreservationAPIClient from "@fetch/preservation-api-client";

export const APIClient = {
    erm: new ERMAPIClient(HttpClient),
    patron: new PatronAPIClient(HttpClient),
    acquisition: new AcquisitionAPIClient(HttpClient),
    additional_fields: new AdditionalFieldsAPIClient(HttpClient),
    authorised_values: new AVAPIClient(HttpClient),
    item: new ItemAPIClient(HttpClient),
    sysprefs: new SysprefAPIClient(HttpClient),
    preservation: new PreservationAPIClient(HttpClient),
    record_sources: new RecordSourcesAPIClient(HttpClient),
};
