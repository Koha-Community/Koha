//Package Patrons
if (typeof Borrowers == "undefined") {
    this.Borrowers = {}; //Set the global package
}
var log = log;
if (!log) {
    log = log4javascript.getDefaultLogger();
}

/**
 * Performs a search against the Koha API looking for Borrowers with the given
 * parameters
 * @param {Object} params, search parameters -object, valid attributes
 *                 'borrowernumber',
 *                 'userid',
 *                 'cardnumber'
 *                 Always performs an OR-search, OR:ing all search parameters.
 * @param {Function} callback, this is called when the result succeeds or fails
 *                   function is forwarded the following parameters from the jQuery.ajax's
 *                   response handlers
 *                       'jqXHR',
 *                       'textStatus',
 *                       'errorThrown',
 *                       'httpStatusCode'
 */
Borrowers.getBorrowers = function (params, callback) {
    //Expose arguments for closures.
    params = (params ? params : {});
    callback = (callback ? callback : null);
    if (!params.borrowernumber && !params.cardnumber) {
        log.error("Borrowers.getBorrowers():> No borrowernumber or cardnumber!");
        return;
    }

    //Cast the request parameters
    var request = {};
    if (params.borrowernumber) {
        request.borrowernumber = parseInt(params.borrowernumber);
    }
    if (params.cardnumber) {
        request.cardnumber = params.cardnumber;
    }

    $.ajax("/api/v1/patrons",
        { "method": "GET",
          "accepts": "application/json",
//          "contentType": "application/json; charset=utf8",
//          "processData": false,
          "data": request,
          "success": function (jqXHR, textStatus, errorThrown) {
            if (callback) {
                callback(jqXHR, textStatus, errorThrown);
            }
            else {
                log.warning("Borrowers.getBorrowers():> Succesfully received Borrowers but don't know what to do with them?");
            }
          },
          "error": function (jqXHR, textStatus, errorThrown) {
            if (callback) {
                callback(jqXHR, textStatus, errorThrown);
            }
            else {
                var responseObject = JSON.parse(jqXHR.responseText);
                log.warning("Borrowers.getBorrowers():> Failed receiving Borrowers with error '"+textStatus+" "+(responseObject ? responseObject.error : errorThrown)+"'but don't know what to do?");
            }
          },
        }
    );
}
