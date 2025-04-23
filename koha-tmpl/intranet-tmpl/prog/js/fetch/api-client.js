import HttpClient from "./http-client.js";

import ArticleRequestAPIClient from "./article-request-api-client.js";
import AVAPIClient from "./authorised-values-api-client.js";
import CataloguingAPIClient from "./cataloguing-api-client.js";
import CirculationAPIClient from "./circulation-api-client.js";
import ClubAPIClient from "./club-api-client.js";
import CoverImageAPIClient from "./cover-image-api-client.js";
import LocalizationAPIClient from "./localization-api-client.js";
import PatronAPIClient from "./patron-api-client.js";
import PatronListAPIClient from "./patron-list-api-client.js";
import RecallAPIClient from "./recall-api-client.js";
import SysprefAPIClient from "./system-preferences-api-client.js";
import TicketAPIClient from "./ticket-api-client.js";
import AcquisitionAPIClient from "./acquisition-api-client.js";

export const APIClient = {
    article_request: new ArticleRequestAPIClient(HttpClient),
    authorised_values: new AVAPIClient(HttpClient),
    acquisition: new AcquisitionAPIClient(HttpClient),
    cataloguing: new CataloguingAPIClient(HttpClient),
    circulation: new CirculationAPIClient(HttpClient),
    club: new ClubAPIClient(HttpClient),
    cover_image: new CoverImageAPIClient(HttpClient),
    localization: new LocalizationAPIClient(HttpClient),
    patron: new PatronAPIClient(HttpClient),
    patron_list: new PatronListAPIClient(HttpClient),
    recall: new RecallAPIClient(HttpClient),
    sysprefs: new SysprefAPIClient(HttpClient),
    ticket: new TicketAPIClient(HttpClient),
};
