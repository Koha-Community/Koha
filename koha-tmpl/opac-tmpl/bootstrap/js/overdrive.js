if ( typeof KOHA == "undefined" || !KOHA ) {
    var KOHA = {};
}

KOHA.OverDrive = ( function() {
    var proxy_base_url = '/cgi-bin/koha/svc/overdrive_proxy';
    var library_base_url = 'http://api.overdrive.com/v1/libraries/';
    return {
        Get: function( url, params, callback ) {
            $.ajax( {
                type: 'GET',
                url: url.replace( /https?:\/\/api.overdrive.com\/v1/, proxy_base_url ),
                dataType: 'json',
                data: params,
                error: function( xhr, error ) {
                    try {
                        callback( JSON.parse( xhr.responseText ));
                    } catch ( e ) {
                        callback( {error: xhr.responseText || true} );
                    }
                },
                success: callback
            } );
        },
        GetCollectionURL: function( library_id, callback ) {
            if ( KOHA.OverDrive.collection_url ) {
                callback( KOHA.OverDrive.collection_url );
                return;
            }

            KOHA.OverDrive.Get(
                library_base_url + library_id,
                {},
                function ( data ) {
                    if ( data.error ) {
                        callback( data );
                        return;
                    }

                    KOHA.OverDrive.collection_url = data.links.products.href;

                    callback( data.links.products.href );
                }
            );
        },
        Search: function( library_id, q, limit, offset, callback ) {
            KOHA.OverDrive.GetCollectionURL( library_id, function( data ) {
                if ( data.error ) {
                    callback( data );
                    return;
                }

                KOHA.OverDrive.Get(
                    data,
                    {q: q, limit: limit, offset: offset},
                    callback
                );
            } );
        }
    };
} )();

KOHA.OverDriveCirculation = new function() {
    var svc_url = '/cgi-bin/koha/svc/overdrive';

    var error_div = $('<div class="overdrive-error">');
    function display_error ( error ) {
        error_div.text(error);
    }

    var login_link = $('<a href="#">')
        .click(function(e) {
            e.preventDefault();
            var passwd = OD_password_required ? prompt("Please enter your password") : "";
            login(passwd);
        })
        .text(_("Login to OverDrive account"));
    var login_div = $('<div class="overdrive-login">').append(login_link);

    var details = null;

    function is_logged_in() {
        return details ? details.is_logged_in : false;
    }

    var checkout_popup = null;
    $( document ).ready(function() {
        var p = window.opener;
        if (p) {
            try { cb = p.refresh_overdrive_account_details;}
            catch(err){ return; } //Catch error if opener is not accessible
            if (cb) {
                cb();
            } else {
                p.location.reload();
            }
            window.close();
        }
        checkout_popup = $("#overdrive-checkout");
    });

    function display_account (container, data) {
        if (!data.is_logged_in) {
            $(container).append(login_div);
            return;
        }

        var overdrive_link = $('<a href="https://www.overdrive.com/account/" target="overdrive-account" class="overdrive-link" style="float:right">')
            .text("OverDrive Account Page");
        $(container).append(overdrive_link);

        var logout_link = $('<a href="#logout" class="overdrive-logout" style="float:left">')
            .click(function(e) {
                e.preventDefault();
                $(container).empty().append(error_div);
                logout(function(data) {
                    display_account(container, data);
                });
            }).text(_("Logout from OverDrive account"));
        $(container).append(logout_link);
        $(container).append('<br style="clear:both;"/>');

        if (data.checkouts) {
            var checkouts_div = $('<div class="overdrive-div">').html('<h3>' + _("Checkouts") + '</h3>');
            var checkouts_list = $('<ul class="overdrive-list">');
            data.checkouts.items.forEach(function(item) {
                item_line(checkouts_list, item);
            });
            checkouts_div.append(checkouts_list);
            $(container).append(checkouts_div);
        }

        if (data.holds) {
            var holds_div = $('<div class="overdrive-div">').html('<h3>' + _("Holds") + '</h3>');
            var holds_list = $('<ul class="overdrive-list">');
            data.holds.items.forEach(function(item) {
                item_line(holds_list, item);
            });
            holds_div.append(holds_list);
            $(container).append(holds_div);
        }
    }

    function item_line(ul_el, item) {
        var line = $('<li class="overdrive-item">');
        if (item.images) {
            var thumb_url = item.images.thumbnail;
            if (thumb_url) {
                $('<img class="overdrive-item-thumbnail">')
                    .attr("src", thumb_url)
                    .appendTo(line);
            }
        }
        $('<div class="overdrive-item-title">')
            .text(item.title)
            .appendTo(line);
        $('<div class="overdrive-item-subtitle">')
            .html(item.subtitle)
            .appendTo(line);
        $('<div class="overdrive-item-author">')
            .text(item.author)
            .appendTo(line);
        var actions = $('<span class="actions">');
        display_actions(actions, item.id);
        $('<div id="action_'+item.id+'" class="actions-menu">')
            .append(actions)
            .appendTo(line);

        $(ul_el).append(line);
    }

    function svc_ajax ( method, params, success_callback ) {
        return $.ajax({
            method: method,
            dataType: "json",
            url: svc_url,
            data: params,
            success: function (data) {
                if (data.error) {
                    display_error(data.error);
                }
                success_callback(data);
            },
            error: function(jqXHR, textStatus, errorThrown) {
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

    function login(p) {
        svc_ajax('get', { action: "login", password: p }, function(data) {
            details = null;
            if( data.login_success ){
                $(login_div).detach();
                if( $("#overdrive-results-page").length > 0 ){
                    location.reload();
                } else {
                KOHA.OverDriveCirculation.display_account_details( $("#opac-user-overdrive") );
                }
            }
        });
    }

    function logout (callback) {
        svc_ajax('post', { action: "logout" }, function(data) {
            details = null;
            callback(data);
        });
    }

    function item_action (params, el, copies_available) {
        var id = params.id;
        svc_ajax('post', params, function(data) {
            if (data.checkouts) {
                details.checkouts = data.checkouts;
            }
            if (data.holds) {
                details.holds = data.holds;
            }
            display_actions(el, id, copies_available);
        });
    }

    function item_is_checked_out (id) {
        if ( !(details && details.checkouts) ) {
            return null;
        }
        var id_uc = id.toUpperCase();
        var items = details.checkouts.items;
        for (var i = 0; i < items.length; i++) {
            if ( items[i].id.toUpperCase() == id_uc ) {
                return items[i];
            }
        }
        return null;
    }

    function item_is_on_hold (id) {
        if ( !(details && details.holds) ) {
            return false;
        }
        var id_uc = id.toUpperCase();
        var items = details.holds.items;
        for (var i = 0; i < items.length; i++) {
            if ( items[i].id.toUpperCase() == id_uc ) {
                return items[i];
            }
        }
        return null;
    }

    function display_actions(el, id, copies_available) {
        $(el).empty();
        if (is_logged_in()) {

            var item = item_is_checked_out(id);
            if (item) {
                var expires = new Date(item.expires);
                $('<span class="overdrive-item-status">')
                    .text(_("Checked out until") + " " + expires.toLocaleString())
                    .appendTo(el);
                $(el).append(" ");

                if (item.format) {
                    var download = $('<a href="#">').appendTo(el);
                    decorate_button(download, _("Download") + " " + item.format);
                    svc_ajax('get', {action: "download-url", id: id, format: item.format}, function(data) {
                        download.attr("href", data.action);
                    });
                    $(el).append(" ");
                }

                if (item.formats) {
                    var lockable_formats = [];
                    for (var f in item.formats) {
                        if (f == item.format) continue;

                        if (item.formats[f]) {
                            var access = $('<a target="_blank">').appendTo(el);
                            decorate_button(access, _("Access online") + " " + f);
                            svc_ajax('get', {action: "download-url", id: id, format: f}, function(data) {
                                access.attr("href", data.action);
                            });
                            $(el).append(" ");
                        }
                        else {
                            lockable_formats.push(f);
                        }
                    }
                    if (lockable_formats.length > 0 && checkout_popup) {
                        $(el).append( ajax_button(_("Download as"), function() {
                            checkout_format(el, id, lockable_formats, copies_available);
                        }) ).append(" ");
                    }
                }

                if (item.format) return item;

                $(el).append( ajax_button(_("Check in"), function() {
                    if( confirm(_("Are you sure you want to return this item?")) ) {
                        item_action({action: "return", id: id}, el, copies_available + 1);
                    }
                }) );

                return item;
            }

            item = item_is_on_hold(id);
            if (item) {
                $('<span class="overdrive-status">')
                    .text(_("On hold"))
                    .appendTo(el);
                $(el).append(" ");
            }

            if(copies_available && checkout_popup) {
                $(el).append( ajax_button(_("Check out"), function() {
                    if( confirm(_("Are you sure you want to checkout this item?")) ) {
                        svc_ajax('post', {action: "checkout", id: id}, function(data) {
                            if (data.checkouts) {
                                details.checkouts = data.checkouts;
                            }
                            if (data.holds) {
                                details.holds = data.holds;
                            }
                            item = display_actions(el, id, copies_available - 1);
                            if (item && item.formats && !item.format) {
                                var has_available_formats = false;
                                var lockable_formats = [];
                                for (var f in item.formats) {
                                    if (item.formats[f]) {
                                        has_available_formats = true;
                                        break;
                                    }
                                    lockable_formats.push(f);
                                }

                                if (!has_available_formats) {
                                    checkout_format(el, id, lockable_formats, copies_available - 1);
                                }
                            }
                        });
                    }
                }) );
            }
            else if (!item) {
                $(el).append( ajax_button(_("Place hold"), function() {
                    item_action({action: "place-hold", id: id}, el, copies_available);
                }) );
            }

            if (item) {
                $(el).append( ajax_button(_("Cancel"), function() {
                    if( confirm(_("Are you sure you want to cancel this hold?")) ) {
                        item_action({action: "remove-hold", id: id}, el, copies_available);
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

    function checkout_format(el, id, formats, copies_available) {
        if (formats.length == 0) {
            alert(_("Item cannot be checked out - no available formats"));
            return false;
        }

        var checkout_format_list = checkout_popup.find("ul.overdrive-format-list").empty();
        formats.forEach(function (item) {
            var li = $('<li>').appendTo(checkout_format_list);
            $('<input name="checkout-format" type="radio">')
                .val(item)
                .appendTo(li);
            li.append(item);
        });
        checkout_popup.modal("show");
        checkout_popup.find(".overdrive-checkout-submit").click(function(e) {
            e.preventDefault();
            var format = checkout_format_list.find("input[type='radio'][name='checkout-format']:checked").val();
            item_action({action: "checkout-format", id: id, format: format}, el, copies_available);
            $(this).unbind( e );
            checkout_popup.modal("hide");
        });
    }

    this.with_account_details = function( el, callback ) {
        $(el).append(error_div);
        load_account_details(function(data) {
            if (!data.is_logged_in) {
                $(el).append(login_div);
            }
            callback(data);
        });
    }

    this.display_account_details = function( el ) {
        window.refresh_overdrive_account_details = function () {
            KOHA.OverDriveCirculation.display_account_details( el );
        }
        $(el).empty().append(error_div);
        load_account_details(function(data) {
            display_account(el, data);
        });
    };

    this.display_error = function( el, error ) {
        $(el).empty().append(error_div);
        display_error(error);
    };

    this.is_logged_in = is_logged_in;

    this.add_actions = function(el, id, copies_available) {
        var actions = $('<span class="actions">');
        display_actions(actions, id, copies_available);
        $('<div id="action_'+id+'" class="actions-menu">')
            .append(actions)
            .appendTo(el);
    };
}
