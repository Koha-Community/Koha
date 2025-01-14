import ArticleRequestAPIClient from "./article-request-api-client.js";
import AVAPIClient from "./authorised-value-api-client.js";
import CataloguingAPIClient from "./cataloguing-api-client.js";
import CirculationAPIClient from "./circulation-api-client.js";
import ClubAPIClient from "./club-api-client.js";
import CoverImageAPIClient from "./cover-image-api-client.js";
import LocalizationAPIClient from "./localization-api-client.js";
import PatronAPIClient from "./patron-api-client.js";
import RecallAPIClient from "./recall-api-client.js";
import SysprefAPIClient from "./system-preferences-api-client.js";
import TicketAPIClient from "./ticket-api-client.js";

export const APIClient = {
    article_request: new ArticleRequestAPIClient(),
    authorised_value: new AVAPIClient(),
    cataloguing: new CataloguingAPIClient(),
    circulation: new CirculationAPIClient(),
    club: new ClubAPIClient(),
    cover_image: new CoverImageAPIClient(),
    localization: new LocalizationAPIClient(),
    patron: new PatronAPIClient(),
    recall: new RecallAPIClient(),
    syspref: new SysprefAPIClient(),
    ticket: new TicketAPIClient(),
};
