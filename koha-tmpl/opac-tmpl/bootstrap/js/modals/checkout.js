$(document).ready(function() {

    let checkouts_count = 0;
    let current_item;

    function addResult(type, code, data) {
        let result = '';
        if (type == 'danger') {
            result += '<div class="alert alert-danger">';
        } else if (type == 'warning') {
            result += '<div class="alert alert-warning">';
        } else if (type == 'info') {
            result += '<div class="alert alert-info">';
        } else {
            result += '<div class="alert alert-success">';
        }

        if (code == 'NOT_FOUND') {
            result += _("Item '%s' not found").format(data);
        } else if (code == 'RENEW_ISSUE') {
            result += _("Item will be renewed").format(data);
        } else if (code == 'OTHER_CHARGES') {
            result += _("Your account currently has outstanding charges of '%s'").format(data);
        } else if (code == 'DEBT') {
            result += _("Your account is currently in debt by '%s'").format(data);
        } else if (code == 'ISSUED_TO_ANOTHER') {
            result += _("This item appears to be checked out to another patron, please return it to the desk");
        } else if (code == 'RESERVED' || code == 'RESERVED_WAITING') {
            result += _("This item appears to be reserved for another patron, please return it to the desk");
        } else if (code == 'TOO_MANY') {
            result += _("You have reached the maximum number of checkouts allowed on your account");
        } else if (code == 'AGE_RESTRICTION') {
            result += _("This item is age restricted");
        } else if (code == 'NO_MORE_RENEWALS') {
            result += _("Maximum renewals reached for this item");
        } else if (code == 'NOT_FOR_LOAN') {
            result += _("This item is not normally for loan, please select another or ask at the desk");
        } else if (code == 'WTHDRAWN') {
            result += _("This item is marked withdrawn, please select another or ask at the desk");
        } else if (code == 'EMPTY') {
            result += _("Please enter the barcode for the item you wish to checkout");
        } else {
            result += _("Message code '%s' with data '%s'").format(code, data);
        }

        result += '</div>';
        $('#availabilityResult').append(result);
    };

    function addCheckout(checkout) {
        // Alert that checkout was successful
        $('#checkoutResults').replaceWith('<div id="checkoutResults" class="alert alert-success">' + _("Item '%s' was checked out").format(current_item.external_id) + '</div>');
        // Cleanup input and unset readonly
        $('#checkout_barcode').val("").prop("readonly", false).focus();
        // Display checkouts table if not already visible
        $('#checkoutsTable').show();
        // Add checkout to checkouts table
        $('#checkoutsTable > tbody').append('<tr><td>' + current_item.external_id +'</td><td>'+ $date(checkout.due_date) +'</td></tr>');
        $('#checkoutsCount').html(++checkouts_count);
        // Reset to submission
        $('#checkoutConfirm').replaceWith('<button type="submit" id="checkoutSubmit" class="btn btn-primary">Submit</button>');
    };

    // Before modal show, check login
    $('#checkoutModal').on('show.bs.modal', function(e) {
       // Redirect to login modal if not logged in
       if (logged_in_user_id === "") {
           let url = new URL(window.location.href);
           url.searchParams.append('modal','checkout');
           $('#modalAuth').append('<input type="hidden" name="return" value="' + url.href +'" />');
           $('#loginModal').modal('show');
           return false;
       }
    });

    // Detect that we were redirected here after login and re-open modal
    let urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('modal')) {
        let modal = urlParams.get('modal');
        history.replaceState && history.replaceState(
            null, '', location.pathname + location.search.replace(/[\?&]modal=[^&]+/, '').replace(/^&/, '?')
        );
        if (modal == 'checkout') {
            $("#checkoutModal").modal('show');
        }
    }

    // On modal show, clear any prior results and set focus
    $('#checkoutModal').on('shown.bs.modal', function(e) {
        $('#checkoutResults').replaceWith('<div id="checkoutResults"></div>');
        $('#availabilityResult').replaceWith('<div id="availabilityResult"></div>');
        $('#checkoutsTable').hide();
        $('#checkout_barcode').val("").focus();
    });

    // On modal submit
    $('#checkoutModal').on('click', '#checkoutSubmit', function(e) {

        // Get item from barcode
        let external_id = $('#checkout_barcode').val();
        if ( external_id === '' ) {
            addResult('warning', 'EMPTY');
            return;
        }

        let item_id;
        let items = $.ajax({
            url: '/api/v1/public/items?external_id=' + external_id,
            dataType: 'json',
            type: 'GET'
        });

        $('#availabilityResult').replaceWith('<div id="availabilityResult"></div>');

        // Get availability of the item
        let availability = items.then(
            function(data, textStatus, jqXHR) {
                if (data.length == 1) {
                    current_item = data[0];
                    item_id = current_item.item_id;
                    return $.ajax({
                        url: '/api/v1/public/checkouts/availability?item_id=' + item_id + '&patron_id=' + logged_in_user_id,
                        type: 'GET',
                        contentType: "json"
                    });
                } else {
                    addResult('danger', 'NOT_FOUND', external_id);
                }
            },
            function(data, textStatus, jqXHR) {
                addResult('danger', 'NOT_FOUND', external_id);
                console.log('Items request failed with: ' + textStatus);
            }
        );

        let checkout = availability.then(
            function(data, textStatus, jqXHR) {
                let result;
                // blocked
                if (Object.keys(data.blockers).length >= 1) {
                    for (const key in data.blockers) {
                        if (data.blockers.hasOwnProperty(key)) {
                            addResult('danger', `${key}`, `${data.blockers[key]}`);
                            console.log(`${key}: ${data.blockers[key]}`);
                            $('#checkout_barcode').val("").prop("readonly", false).focus();
                        }
                    }
                }
                // requires confirmation
                else if (Object.keys(data.confirms).length >= 1) {
                    for (const key in data.confirms) {
                        if (data.confirms.hasOwnProperty(key)) {
                            addResult('warning', `${key}`, `${data.confirms[key]}`);
                        }
                    }
                    $('#checkout_barcode').prop("readonly", true);
                    $('#checkoutSubmit').replaceWith('<input type="hidden" id="item_id" value="' + item_id + '"><input type="hidden" id="confirm_token" value="' + data.confirmation_token + '"><button type="submit" id="checkoutConfirm" class="btn btn-warning">Confirm</button>');
                }
                // straight checkout
                else {
                    let params = {
                        "checkout_id": undefined,
                        "patron_id": logged_in_user_id,
                        "item_id": item_id,
                        "due_date": undefined,
                        "library_id": undefined,
                        "issuer_id": undefined,
                        "checkin_date": undefined,
                        "last_renewed_date": undefined,
                        "renewals_count": undefined,
                        "unseen_renewals": undefined,
                        "auto_renew": undefined,
                        "auto_renew_error": undefined,
                        "timestamp": undefined,
                        "checkout_date": undefined,
                        "onsite_checkout": false,
                        "note": undefined,
                        "note_date": undefined,
                        "note_seen": undefined,
                    };
                    result = $.ajax({
                        url: '/api/v1/public/patrons/'+logged_in_user_id+'/checkouts',
                        type: 'POST',
                        data: JSON.stringify(params),
                        contentType: "json"
                    });
                }

                // warnings to display
                if (Object.keys(data.warnings).length >= 1) {
                    for (const key in data.warnings) {
                        if (data.warnings.hasOwnProperty(key)) {
                            addResult('info', `${key}`, `${data.warnings[key]}`);
                        }
                    }
                }

                // return a rejected promise if we've reached here
                return result ? result : $.Deferred().reject('Checkout halted');
            },
            function(data, textStatus, jqXHR) {
                console.log('Items request failed with: ' + textStatus);
                console.log(data);
            }
        );

        checkout.then(
            function(data, textStatus, jqXHR) {
                addCheckout(data);
                // data retrieved from url2 as provided by the first request
            },
            function(data, textStatus, jqXHR) {
                console.log("checkout.then failed");
            }
        );

    });

    $('#checkoutModal').on('click', '#checkoutConfirm', function(e) {
        let external_id = $('#checkout_barcode').val();
        let item_id = $('#item_id').val();
        let token = $('#confirm_token').val();
        let params = {
            "checkout_id": undefined,
            "patron_id": logged_in_user_id,
            "item_id": item_id,
            "due_date": undefined,
            "library_id": undefined,
            "issuer_id": undefined,
            "checkin_date": undefined,
            "last_renewed_date": undefined,
            "renewals_count": undefined,
            "unseen_renewals": undefined,
            "auto_renew": undefined,
            "auto_renew_error": undefined,
            "timestamp": undefined,
            "checkout_date": undefined,
            "onsite_checkout": false,
            "note": undefined,
            "note_date": undefined,
            "note_seen": undefined,
        };
        let checkout = $.ajax({
            url: '/api/v1/public/patrons/'
                 + logged_in_user_id
                 + '/checkouts?confirmation='
                 + token,
            type: 'POST',
            data: JSON.stringify(params),
            contentType: "json"
        });

        checkout.then(
            function(data, textStatus, jqXHR) {
                $('#item_id').remove;
                $('#confirm_token').remove;
                $('#availabilityResult').replaceWith('<div id="availabilityResult"></div>');
                addCheckout(data);
                // data retrieved from url2 as provided by the first request
            },
            function(data, textStatus, jqXHR) {
                console.log("checkout.then failed");
            }
        );
    });

    $('#checkoutModal').on('hidden.bs.modal', function (e) {
        let pageName = $(location).attr("pathname");
        if ( pageName == '/cgi-bin/koha/opac-user.pl' ) {
            location.reload();
        }
    })
});
