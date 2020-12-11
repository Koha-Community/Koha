jQuery.fn.overflowScrollReset = function() {
    $(this).scrollTop($(this).scrollTop() - $(this).offset().top);
    return this;
};

$(document).ready(function(){
    var xhrGetSuggestions, xhrGetResults;

    $('#browse-search form').submit(function(event) {
        // if there is an in progress request, abort it so we
        // don't end up with  a race condition
        if(xhrGetSuggestions && xhrGetSuggestions.readyState != 4){
            xhrGetSuggestions.abort();
        }

        var userInput = $('#browse-searchterm').val().trim();
        var userField = $('#browse-searchfield').val();
        var userFuzziness = $('input[name=browse-searchfuzziness]:checked', '#browse-searchfuzziness').val();
        var leftPaneResults = $('#browse-searchresults li').not('.loading, .no-results');
        var rightPaneResults = $('#browse-selectionsearch ol li');

        event.preventDefault();

        if(!userInput) {
            return;
        }

        // remove any error states and show the results area (except right pane)
        $('#browse-suggestionserror').addClass('d-none');
        $('#browse-searchresults .no-results').addClass('d-none');
        $('#browse-resultswrapper').removeClass('d-none');
        $('#browse-selection').addClass('d-none').text("");
        $('#browse-selectionsearch').addClass('d-none');

        // clear any results from left and right panes
        leftPaneResults.remove();
        rightPaneResults.remove();

        // show the spinner in the left pane
        $('#browse-searchresults .loading').removeClass('d-none');

        xhrGetSuggestions = $.get(window.location.pathname, {api: "GetSuggestions", field: userField, prefix: userInput, fuzziness: userFuzziness})
            .always(function() {
                // hide spinner
                $('#browse-searchresults .loading').addClass('d-none');
            })
            .done(function(data) {
                var fragment = document.createDocumentFragment();

                if (data.length === 0) {
                    $('#browse-searchresults .no-results').removeClass('d-none');

                    return;
                }

                // scroll to top of container again
                $("#browse-searchresults").overflowScrollReset();

                // store the type of search that was performed as an attrib
                $('#browse-searchresults').data('field', userField);

                $.each(data, function(index, object) {
                    // use a document fragment so we don't need to nest the elems
                    // or append during each iteration (which would be slow)
                    var elem = document.createElement("li");
                    var link = document.createElement("a");
                    link.textContent = object.text;
                    link.setAttribute("href", "#");
                    elem.appendChild(link);
                    fragment.appendChild(elem);
                });

                $('#browse-searchresults').append(fragment.cloneNode(true));
            })
            .fail(function(jqXHR) {
                //if 500 or 404 (abort is okay though)
                if (jqXHR.statusText !== "abort") {
                    $('#browse-resultswrapper').addClass('d-none');
                    $('#browse-suggestionserror').removeClass('d-none');
                }
            });
    });

    $('#browse-searchresults').on("click", 'a', function(event) {
        // if there is an in progress request, abort it so we
        // don't end up with  a race condition
        if(xhrGetResults && xhrGetResults.readyState != 4){
            xhrGetResults.abort();
        }

        var term = $(this).text();
        var field = $('#browse-searchresults').data('field');
        var rightPaneResults = $('#browse-selectionsearch ol li');

        event.preventDefault();

        // clear any current selected classes and add a new one
        $(this).parent().siblings().children().removeClass('selected');
        $(this).addClass('selected');

        // copy in the clicked text
        $('#browse-selection').removeClass('d-none').text(term);

        // show the right hand pane if it is not shown already
        $('#browse-selectionsearch').removeClass('d-none');

        // hide the no results element
        $('#browse-selectionsearch .no-results').addClass('d-none');

        // clear results
        rightPaneResults.remove();

        // turn the spinner on
        $('#browse-selectionsearch .loading').removeClass('d-none');

        // do the query for the term
        xhrGetResults = $.get(window.location.pathname, {api: "GetResults", field: field, term: term})
            .always(function() {
                // hide spinner
                $('#browse-selectionsearch .loading').addClass('d-none');
            })
            .done(function(data) {
                var fragment = document.createDocumentFragment();

                if (data.length === 0) {
                    $('#browse-selectionsearch .no-results').removeClass('d-none');

                    return;
                }

                // scroll to top of container again
                $("#browse-selectionsearch").overflowScrollReset();

                $.each(data, function(index, object) {
                    // use a document fragment so we don't need to nest the elems
                    // or append during each iteration (which would be slow)
                    var elem = document.createElement("li");
                    var title = document.createElement("h4");
                    var link = document.createElement("a");
                    var author = document.createElement("p");
                    var destination = window.location.pathname;

                    destination = destination.replace("browse", "detail");
                    destination = destination + "?biblionumber=" + object.id;

                    author.className = "author";

                    link.setAttribute("href", destination);
                    link.setAttribute("target", "_blank");
                    link.textContent = object.title;
                    title.appendChild(link);

                    author.textContent = object.author;

                    elem.appendChild(title);
                    elem.appendChild(author);
                    fragment.appendChild(elem);
                });

                $('#browse-selectionsearch ol').append(fragment.cloneNode(true));
            })
            .fail(function(jqXHR) {
                //if 500 or 404 (abort is okay though)
                if (jqXHR.statusText !== "abort") {
                    $('#browse-resultswrapper').addClass('d-none');
                    $('#browse-suggestionserror').removeClass('d-none');
                }
            });

    });

});
