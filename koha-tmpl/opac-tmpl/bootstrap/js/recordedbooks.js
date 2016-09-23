if ( typeof KOHA == "undefined" || !KOHA ) {
    var KOHA = {};
}

KOHA.RecordedBooks = new function() {
    var svc_url = '/cgi-bin/koha/svc/recordedbooks';

    var error_div = $('<div class="recordedbooks-error">');
    function display_error ( error ) {
        error_div.text(error);
    }

    var details = null;

    function is_identified() {
        return details ? details.is_identified : false;
    }

    var checkout_popup = null;
    $( document ).ready(function() {
        checkout_popup = $("#recordedbooks-checkout");
    });

    function display_account (container, data) {
        if (!data.is_identified) {
            return;
        }

        if (data.checkouts) {
            var checkouts_div = $('<div class="recordedbooks-div">').html('<h3>' + _("Checkouts") + '</h3>');
            var items = data.checkouts.items;
            var checkouts_list;
            if (items.length == 0) {
                checkouts_list = _("No checkouts");
            } else {
                checkouts_list = $('<ul class="recordedbooks-list">');
                data.checkouts.items.forEach(function(item) {
                    item_line(checkouts_list, item);
                });
            }
            checkouts_div.append(checkouts_list);
            $(container).append(checkouts_div);
        }

        if (data.holds) {
            var holds_div = $('<div class="recordedbooks-div">').html('<h3>' + _("Holds") + '</h3>');
            var items = data.holds.items;
            var holds_list;
            if (items.length == 0) {
                holds_list = _("No holds");
            } else {
                holds_list = $('<ul class="recordedbooks-list">');
                data.holds.items.forEach(function(item) {
                    item_line(holds_list, item);
                });
            }
            holds_div.append(holds_list);
            $(container).append(holds_div);
        }
    }

    function item_line(ul_el, item) {
        var line = $('<li class="recordedbooks-item">');
        if (item.images) {
            var thumb_url = item.images.small;
            if (thumb_url) {
                $('<img class="recordedbooks-item-thumbnail">')
                    .attr("src", thumb_url)
                    .appendTo(line);
            }
        }
        $('<div class="recordedbooks-item-title">')
            .text(item.title)
            .appendTo(line);
        $('<div class="recordedbooks-item-subtitle">')
            .text(item.subtitle)
            .appendTo(line);
        $('<div class="recordedbooks-item-author">')
            .text(item.author)
            .appendTo(line);
        if (item.files && item.files.length > 0) {
            downloads = $('<div class="recordedbooks-item-author">')
                .text("Downloads")
                .appendTo(line);
            render_downloads(downloads, item.files);
        }
        var actions = $('<span class="actions">');
        display_actions(actions, item.isbn);
        $('<div id="action_'+item.isbn+'" class="actions-menu">')
            .append(actions)
            .appendTo(line);

        $(ul_el).append(line);
    }

    function render_downloads(el, files) {
        if (files.length == 0) return;
        var file_spec = files.shift();
        if (/^https?:\/\/api\./.test(file_spec.url)) {
            $.ajax({
                dataType: "json",
                url: file_spec.url,
                success: function (data) {
                    append_download_link(el, data.url, data.id);
                    render_downloads(el, files);
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    display_error(errorThrown);
                }
            });
        } else {
            append_download_link(el, file_spec.url, file_spec.filename);
            render_downloads(el, files);
        }
    }
    function append_download_link(el, url, text) {
        var p = $("<p>");
        $( '<a href="' + url + '" target="recordedbooks">' )
            .text(text)
            .appendTo(p);
        el.append(p);
    }

    function svc_ajax ( method, params, success_callback, callback_for_error_too ) {
        // remove when jquery is upgraded
        for (var key in params) {
            if (params[key] === null) delete params[key];
        }
        return $.ajax({
            method: method,
            dataType: "json",
            url: svc_url,
            data: params,
            success: function (data) {
                if (data.error && !callback_for_error_too) {
                    display_error(data.error);
                }
                success_callback(data);
            },
            error: function(jqXHR, textStatus, errorThrown) {
                if (callback_for_error_too) {
                    success_callback({error: errorThrown});
                    return;
                }
                display_error(errorThrown);
            }
        });
    }

    function load_account_details ( callback ) {
        svc_ajax('get', { action: "account" }, function(data) {
            details = data;
            callback(data);
        });
    }

    function item_action (params, el) {
        var isbn = params.isbn;
        svc_ajax('post', params, function(data) {
            if (data.checkouts) {
                details.checkouts = data.checkouts;
            }
            if (data.holds) {
                details.holds = data.holds;
            }
            display_actions(el, isbn);
        });
    }

    function item_is_checked_out (isbn) {
        if ( !(details && details.checkouts) ) {
            return null;
        }
        var isbn_uc = isbn.toUpperCase();
        var items = details.checkouts.items;
        for (var i = 0; i < items.length; i++) {
            if ( items[i].isbn.toUpperCase() == isbn_uc ) {
                return items[i];
            }
        }
        return null;
    }

    function item_is_on_hold (isbn) {
        if ( !(details && details.holds) ) {
            return false;
        }
        var isbn_uc = isbn.toUpperCase();
        var items = details.holds.items;
        for (var i = 0; i < items.length; i++) {
            if ( items[i].isbn.toUpperCase() == isbn_uc ) {
                return items[i];
            }
        }
        return null;
    }

    function display_actions(el, isbn) {
        $(el).empty();
        if (is_identified()) {

            var item = item_is_checked_out(isbn);
            if (item) {
                var expires = new Date(item.expires);
                $('<span class="recordedbooks-item-status">')
                    .text(_("Checked out until") + " " + expires.toLocaleString())
                    .appendTo(el);
                $(el).append(" ");

                if (item.url) {
                    var download = $('<a href="'+item.url+'">').appendTo(el);
                    decorate_button(download, _("Download"));
                    $(el).append(" ");
                }

                $(el).append( ajax_button(_("Check in"), function() {
                    if( confirm(_("Are you sure you want to return this item?")) ) {
                        item_action({action: "return", isbn: isbn}, el);
                    }
                }) );

                return item;
            }

            item = item_is_on_hold(isbn);
            if (item) {
                $('<span class="recordedbooks-status">')
                    .text(_("On hold"))
                    .appendTo(el);
                $(el).append(" ");
            }

            if(checkout_popup) {
                $(el).append( ajax_button(_("Check out"), function() {
                    if( confirm(_("Are you sure you want to checkout this item?")) ) {
                        svc_ajax('post', {action: "checkout", isbn: isbn}, function(data) {
                            if (data.checkouts) {
                                details.checkouts = data.checkouts;
                            }
                            if (data.holds) {
                                details.holds = data.holds;
                            }
                            item = display_actions(el, isbn);
                        });
                    }
                }) );
            }
            if (!item) {
                $(el).append( ajax_button(_("Place hold"), function() {
                    item_action({action: "place_hold", isbn: isbn}, el);
                }) );
            }

            if (item) {
                $(el).append( ajax_button(_("Cancel"), function() {
                    if( confirm(_("Are you sure you want to cancel this hold?")) ) {
                        item_action({action: "remove_hold", isbn: isbn}, el);
                    }
                }) );
            }
            return item;
        }
    }

    function ajax_button(label, on_click) {
        var button = $('<a href="#">')
            .click(function(e) {
                e.preventDefault();
                on_click();
            });
        decorate_button(button, label);
        return button;
    }

    function decorate_button(button, label) {
        $(button)
            .addClass("btn btn-primary btn-mini")
            .css("color","white")
            .text(label);
    }

    this.with_account_details = function( el, callback ) {
        $(el).append(error_div);
        load_account_details( callback );
    }

    this.display_account_details = function( el ) {
        $(el).empty().append(error_div);
        load_account_details(function(data) {
            display_account(el, data);
        });
    };

    this.display_error = function( el, error ) {
        $(el).empty().append(error_div);
        display_error(error);
    };

    this.is_identified = is_identified;

    this.add_actions = function(el, isbn) {
        var actions = $('<span class="actions">');
        display_actions(actions, isbn);
        $('<div id="action_'+isbn+'" class="actions-menu">')
            .append(actions)
            .appendTo(el);
    };

    this.search = function( q, page_size, page, callback ) {
        svc_ajax('get', { action: "search", q: q, page_size: page_size, page: page }, function (data) {
            var results;
            if (data.results) {
                results = data.results;
                if (!results.total) {
                    var total = results.items.length;
                    if ( total == results.page_size ) total = total + "+";
                    results.total = total;
                }
            }
            else results = {};
            results.error = data.error;
            callback(results);
        }, true);
    };
}
