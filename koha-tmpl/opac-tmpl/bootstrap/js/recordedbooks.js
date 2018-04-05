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
            var checkouts_div = $('<div class="recordedbooks-div">').html('<h3>' + MSG_CHECKOUTS + '</h3>');
            var items = data.checkouts.items;
            var checkouts_list;
            if (items.length == 0) {
                checkouts_list = MSG_NO_CHECKOUTS;
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
            var holds_div = $('<div class="recordedbooks-div">').html('<h3>' + MSG_HOLDS + '</h3>');
            var items = data.holds.items;
            var holds_list;
            if (items.length == 0) {
                holds_list = MSG_NO_HOLDS;
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
        $('<span id="waiting_'+item.isbn+'" style="display:none;"><img class="throbber" src="/opac-tmpl/lib/jquery/plugins/themes/classic/throbber.gif" /></span>').appendTo(line);
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
        $("#action_"+isbn).hide();
        $("#waiting_"+isbn).show();
        svc_ajax('post', params, function(data) {
            if (data.checkouts) {
                details.checkouts = data.checkouts;
            }
            if (data.holds) {
                details.holds = data.holds;
            }
            display_actions(el, isbn);
              $("#action_"+isbn).show();
              $("#waiting_"+isbn).hide();
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
                    .text(MSG_CHECKED_OUT_UNTIL.format(expires.toLocaleString()))
                    .appendTo(el);
                $(el).append(" ");

                if (item.url) {
                    var download = $('<a href="'+item.url+'">').appendTo(el);
                    decorate_button(download, MSG_DOWNLOAD);
                    $(el).append(" ");
                }

                $(el).append( ajax_button(MSG_CHECK_IN, function() {
                    if( confirm(MSG_CHECK_IN_CONFIRM) ) {
                        item_action({action: "return", isbn: isbn}, el);
                    }
                }) );

                return item;
            }

            item = item_is_on_hold(isbn);
            if (item) {
                $('<span class="recordedbooks-status">')
                    .text(MSG_ON_HOLD)
                    .appendTo(el);
                $(el).append(" ");
            }

            if(checkout_popup) {
                $(el).append( ajax_button(MSG_CHECK_OUT, function() {
                    if( confirm(MSG_CHECK_OUT_CONFIRM) ) {
                       $("#action_"+isbn).hide();
                       $("#waiting_"+isbn).show();
                        svc_ajax('post', {action: "checkout", isbn: isbn}, function(data) {
                            if (data.checkouts) {
                                details.checkouts = data.checkouts;
                            }
                            if (data.holds) {
                                details.holds = data.holds;
                            }
                            item = display_actions(el, isbn);
                            $("#action_"+isbn).show();
                            $("#waiting_"+isbn).hide();
                        });
                    }
                }) );
            }
            if (!item) {
                $(el).append( ajax_button(MSG_PLACE_HOLD, function() {
                    item_action({action: "place_hold", isbn: isbn}, el);
                }) );
            }

            if (item) {
                $(el).append( ajax_button(MSG_CANCEL_HOLD, function() {
                    if( confirm(MSG_CANCEL_HOLD_CONFIRM) ) {
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
        $("#action_"+isbn).before('<span id="waiting_'+isbn+'" style="display:none;"><img class="throbber" src="/opac-tmpl/lib/jquery/plugins/themes/classic/throbber.gif" /></span>');
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
