import ArticleRequestAPIClient from "./article-request-api-client.js";
import AVAPIClient from "./authorised-value-api-client.js";

export const APIClient = {
    article_request: new ArticleRequestAPIClient(),
    authorised_value: new AVAPIClient(),
};
