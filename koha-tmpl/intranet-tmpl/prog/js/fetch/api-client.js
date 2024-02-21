import ArticleRequestAPIClient from "./article-request-api-client.js";
import AVAPIClient from "./authorised-value-api-client.js";
import CirculationAPIClient from "./circulation-api-client.js";
import ClubAPIClient from "./club-api-client.js";
import CoverImageAPIClient from "./cover-image-api-client.js";
import SysprefAPIClient from "./system-preferences-api-client.js";

export const APIClient = {
    article_request: new ArticleRequestAPIClient(),
    authorised_value: new AVAPIClient(),
    circulation: new CirculationAPIClient(),
    club: new ClubAPIClient(),
    cover_image: new CoverImageAPIClient(),
    syspref: new SysprefAPIClient(),
};
