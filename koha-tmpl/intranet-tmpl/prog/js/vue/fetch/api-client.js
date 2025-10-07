import HttpClient from "./http-client";

import ERMAPIClient from "@fetch/erm-api-client";
import PatronAPIClient from "@fetch/patron-api-client";
import AcquisitionAPIClient from "@fetch/acquisition-api-client";
import AdditionalFieldsAPIClient from "@fetch/additional-fields-api-client";
import AVAPIClient from "@fetch/authorised-values-api-client";
import CashAPIClient from "@fetch/cash-api-client";
import ItemAPIClient from "@fetch/item-api-client";
import RecordSourcesAPIClient from "@fetch/record-sources-api-client";
import SysprefAPIClient from "@fetch/system-preferences-api-client";
import SIP2APIClient from "@fetch/sip2-api-client";
import PreservationAPIClient from "@fetch/preservation-api-client";

export const APIClient = {
    erm: new ERMAPIClient(HttpClient),
    patron: new PatronAPIClient(HttpClient),
    acquisition: new AcquisitionAPIClient(HttpClient),
    additional_fields: new AdditionalFieldsAPIClient(HttpClient),
    authorised_values: new AVAPIClient(HttpClient),
    cash: new CashAPIClient(HttpClient),
    item: new ItemAPIClient(HttpClient),
    sysprefs: new SysprefAPIClient(HttpClient),
    sip2: new SIP2APIClient(HttpClient),
    preservation: new PreservationAPIClient(HttpClient),
    record_sources: new RecordSourcesAPIClient(HttpClient),
};

export default APIClient;
