/* global __ */
$.fn.select2.defaults.set("allowClear", true);
$.fn.select2.defaults.set("placeholder", "");
$.fn.select2.defaults.set("width", "element");

// Internationalization
$.fn.select2.defaults.set("language", {
    errorLoading: function () {
        return __("The results could not be loaded");
    },
    inputTooLong: function (args) {
        var n = args.input.length - args.maximum;
        return __("Please delete %s character(s)").format(n);
    },
    inputTooShort: function (args) {
        var n = args.minimum - args.input.length;
        return __("Please enter %s or more characters").format(n);
    },
    formatResult: function (item) {
        return $("<div>", { title: item.element[0].title }).text(item.text);
    },
    loadingMore: function () {
        return __("Loading more results…");
    },
    maximumSelected: function (args) {
        return __("You can only select %s item(s)").format(args.maximum);
    },
    noResults: function () {
        return __("No results found");
    },
    searching: function () {
        return __("Searching…");
    },
    removeAllItems: function () {
        return __("Clear selections");
    },
    removeItem: function () {
        return __("Clear selection");
    },
});

$(document).ready(function () {
    $(".select2").select2();
    $(".select2").on("select2:clear", function () {
        $(this).on("select2:opening.cancelOpen", function (evt) {
            evt.preventDefault();

            $(this).off("select2:opening.cancelOpen");
        });
    });

    $(document).on("select2:open", function () {
        document
            .querySelector(".select2-container--open .select2-search__field")
            .focus();
    });
});

(function ($) {
    /**
     * Create a new Select2 instance that uses the Koha RESTful API response headers to
     * read pagination information
     * @param  {Object}  config  Please see the Select2 documentation for further details
     * @return {Object}          The Select2 instance
     */

    $.fn.kohaSelect = function (config) {
        if (config.hasOwnProperty("ajax")) {
            config.ajax.transport = function (params, success, failure) {
                var read_headers = function (data, textStatus, jqXHR) {
                    var more = false;
                    var link = jqXHR.getResponseHeader("Link") || "";
                    if (
                        link.search(
                            /<([^>]+)>;\s*rel\s*=\s*['"]?next['"]?\s*(,|$)/i
                        ) > -1
                    ) {
                        more = true;
                    }

                    return {
                        results: data,
                        pagination: {
                            more: more,
                        },
                    };
                };
                var $request = $.ajax(params);
                $request.then(read_headers).then(success);
                $request.fail(failure);
            };
        }

        $(this).select2(config);
    };
})(jQuery);
