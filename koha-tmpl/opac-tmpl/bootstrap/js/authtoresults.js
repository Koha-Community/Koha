if (window.location.href.indexOf("opac-search.pl") > -1) {

    // extract search params
    var searchUrl = location.href;
    var searchParams = searchUrl.substring(searchUrl.indexOf("?")+1);

    // store search params in loginModal to pass back on redirect
    var query = document.getElementById("has-search-query");
    query.value = searchParams;
}