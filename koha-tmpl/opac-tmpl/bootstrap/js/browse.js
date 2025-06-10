jQuery.fn.overflowScrollReset = function () {
    $(this).scrollTop($(this).scrollTop() - $(this).offset().top);
    return this;
};

$(document).ready(function () {
    var xhrGetSuggestions, xhrGetResults;

    $("#browse-search form").submit(function (event) {
        // if there is an in progress request, abort it so we
        // don't end up with  a race condition
        if (xhrGetSuggestions && xhrGetSuggestions.readyState != 4) {
            xhrGetSuggestions.abort();
        }

        var userInput = $("#browse-searchterm").val().trim();
        var userField = $("#browse-searchfield").val();
        var userFuzziness = $(
            "input[name=browse-searchfuzziness]:checked",
            "#browse-searchfuzziness"
        ).val();
        var card_template = $("#card_template");

        event.preventDefault();

        if (!userInput) {
            return;
        }

        /* return the browsing results to empty state in case previous results have been loaded */
        $("#browse-searchresults").empty().append(card_template);

        // remove any error states and show the results area
        $("#browse-suggestionserror").addClass("d-none");
        $(".no-results").addClass("d-none");
        $("#browse-resultswrapper").removeClass("d-none");
        /* Reset results browser to default state */

        // show the spinner
        $(".loading").removeClass("d-none");

        xhrGetSuggestions = $.get(window.location.pathname, {
            api: "GetSuggestions",
            field: userField,
            prefix: userInput,
            fuzziness: userFuzziness,
        })
            .always(function () {
                // hide spinner
                $(".loading").addClass("d-none");
            })
            .done(function (data) {
                var fragment = document.createDocumentFragment();

                if (data.length === 0) {
                    $(".no-results").removeClass("d-none");
                    return;
                }

                // store the type of search that was performed as an attrib
                $("#browse-searchresults").data("field", userField);

                $.each(data, function (index, object) {
                    // use a document fragment so we don't need to nest the elems
                    // or append during each iteration (which would be slow)
                    var card = card_template.clone().removeAttr("id");
                    // change card-header id
                    card.find(".card-header")
                        .attr("id", "heading" + index)
                        .find("a")
                        .attr("data-bs-target", "#collapse" + index)
                        .attr("aria-controls", "collapse" + index)
                        .text(object.text);
                    card.find(".collapse")
                        .attr("id", "collapse" + index)
                        .attr("aria-labelledby", "heading" + index);
                    $(fragment).append(card);
                });

                $("#browse-searchresults").append(fragment.cloneNode(true));
            })
            .fail(function (jqXHR) {
                //if 500 or 404 (abort is okay though)
                if (jqXHR.statusText !== "abort") {
                    $("#browse-resultswrapper").addClass("d-none");
                    $("#browse-suggestionserror").removeClass("d-none");
                }
            });
    });

    $("#browse-searchresults").on("click", "a.expand-result", function (event) {
        // if there is an in progress request, abort it so we
        // don't end up with  a race condition
        if (xhrGetResults && xhrGetResults.readyState != 4) {
            xhrGetResults.abort();
        }

        var link = $(this);
        var target = link.data("bs-target");
        var term = link.text();

        var field = $("#browse-searchresults").data("field");

        event.preventDefault();

        /* Don't load data via AJAX if it has already been loaded */
        if ($(target).find(".result-title").length == 0) {
            // do the query for the term
            xhrGetResults = $.get(window.location.pathname, {
                api: "GetResults",
                field: field,
                term: term,
            })
                .done(function (data) {
                    var fragment = document.createDocumentFragment();

                    if (data.length === 0) {
                        $("#browse-selectionsearch .no-results").removeClass(
                            "d-none"
                        );
                        return;
                    }

                    $.each(data, function (index, object) {
                        // use a document fragment so we don't need to nest the elems
                        // or append during each iteration (which would be slow)
                        var elem = document.createElement("div");
                        elem.className = "result-title";

                        var destination = window.location.pathname;
                        destination = destination.replace("browse", "detail");
                        destination =
                            destination + "?biblionumber=" + object.id;

                        var link = document.createElement("a");
                        link.setAttribute("href", destination);
                        link.setAttribute("target", "_blank");
                        link.textContent = object.title;
                        if (object.subtitle) {
                            link.textContent += " " + object.subtitle;
                        }
                        elem.appendChild(link);

                        if (object.author) {
                            var author = document.createElement("span");
                            author.className = "author";
                            author.textContent = " " + object.author;
                            elem.appendChild(author);
                        }
                        fragment.appendChild(elem);
                    });

                    $(target)
                        .find(".card-body")
                        .append(fragment.cloneNode(true));
                })
                .fail(function (jqXHR) {
                    //if 500 or 404 (abort is okay though)
                    if (jqXHR.statusText !== "abort") {
                        $("#browse-resultswrapper").addClass("d-none");
                        $("#browse-suggestionserror").removeClass("d-none");
                    }
                });
        }
    });
});
