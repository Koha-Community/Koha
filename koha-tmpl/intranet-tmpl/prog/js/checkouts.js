/* global __ */

$(document).ready(function() {
    $.ajaxSetup ({ cache: false });

    var barcodefield = $("#barcode");

    var onHoldDueDateSet = false;

    var onHoldChecked = function() {
        var isChecked = false;
        $('input[data-on-reserve]').each(function() {
            if ($(this).is(':checked')) {
                isChecked=true;
            }
        });
        return isChecked;
    };

    var showHideOnHoldRenewal = function() {
        // Display the date input
        if (onHoldChecked()) {
            $('#newonholdduedate').show()
        } else {
            $('#newonholdduedate').hide();
        }
    };

    // Handle the select all/none links for checkouts table columns
    $("#CheckAllRenewals").on("click",function(){
        $("#UncheckAllCheckins").click();
        $(".renew:visible").prop("checked", true);
        showHideOnHoldRenewal();
        return false;
    });
    $("#UncheckAllRenewals").on("click",function(){
        $(".renew:visible").prop("checked", false);
        showHideOnHoldRenewal();
        return false;
    });

    $("#CheckAllCheckins").on("click",function(){
        $("#UncheckAllRenewals").click();
        $(".checkin:visible").prop("checked", true);
        return false;
    });
    $("#UncheckAllCheckins").on("click",function(){
        $(".checkin:visible").prop("checked", false);
        return false;
    });

    $("#newduedate").on("change", function() {
        if (!onHoldDueDateSet) {
            $('#newonholdduedate input').val($('#newduedate').val());
        }
    });

    $("#newonholdduedate").on("change", function() {
        onHoldDueDateSet = true;
    });

    // Don't allow both return and renew checkboxes to be checked
    $(document).on("change", '.renew', function(){
        if ( $(this).is(":checked") ) {
            $( "#checkin_" + $(this).val() ).prop("checked", false);
        }
    });
    $(document).on("change", '.checkin', function(){
        if ( $(this).is(":checked") ) {
            $( "#renew_" + $(this).val() ).prop("checked", false);
        }
    });

    // Display on hold due dates input when an on hold item is
    // selected
    $(document).on('change', '.renew', function(){
        showHideOnHoldRenewal();
    });

    $("#output_format > option:first-child").attr("selected", "selected");
    $("select[name='csv_profile_id']").hide();
    $(document).on("change", '#issues-table-output-format', function(){
        if ( $(this).val() == 'csv' ) {
            $("select[name='csv_profile_id']").show();
        } else {
            $("select[name='csv_profile_id']").hide();
        }
    });

    // Clicking the table cell checks the checkbox inside it
    $(document).on("click", 'td', function(e){
        if(e.target.tagName.toLowerCase() == 'td'){
          $(this).find("input:checkbox:visible").each( function() {
            $(this).click();
          });
        }
    });

    // Handle renewals and returns
    $("#RenewCheckinChecked").on("click",function(){
        $(".checkin:checked:visible").each(function() {
            itemnumber = $(this).val();

            $(this).replaceWith("<img id='checkin_" + itemnumber + "' src='" + interface + "/" + theme + "/img/spinner-small.gif' />");

            params = {
                itemnumber:     itemnumber,
                borrowernumber: borrowernumber,
                branchcode:     branchcode,
                exempt_fine:    $("#exemptfine").is(':checked')
            };

            $.post({
                url: "/cgi-bin/koha/svc/checkin",
                data: params,
                success: function( data ) {
                    id = "#checkin_" + data.itemnumber;

                    content = "";
                    if ( data.returned ) {
                        content = __("Checked in");
                        $(id).parent().parent().addClass('ok');
                        $('#date_due_' + data.itemnumber).html( __("Checked in") );
                        if ( data.patronnote != null ) {
                            $('.patron_note_' + data.itemnumber).html( __("Patron note") + ": " + data.patronnote);
                        }
                    } else {
                        content = __("Unable to check in");
                        $(id).parent().parent().addClass('warn');
                    }

                    $(id).replaceWith( content );
                },
                dataType: "json",
                async: false,
            });
        });

        $(".confirm:checked:visible").each(function() {
            itemnumber = $(this).val();
            id = "#checkin_" + itemnumber;
            materials = $(this).data('materials');

            $(this).replaceWith("<span class='confirm' id='checkin_" + itemnumber + "'>" + __("Confirm") + " (<span>" + materials + "</span>): <input type='checkbox' class='checkin' name='checkin' value='" + itemnumber +"'></input></span>");
            $(id).parent().parent().addClass('warn');
        });

        $(".renew:checked:visible").each(function() {
            var override_limit = $("#override_limit").is(':checked') ? 1 : 0;

            var isOnReserve = $(this).data().hasOwnProperty('onReserve');

            var itemnumber = $(this).val();

            $(this).parent().parent().replaceWith("<img id='renew_" + itemnumber + "' src='" + interface + "/" + theme + "/img/spinner-small.gif' />");

            var params = {
                itemnumber:      itemnumber,
                borrowernumber:  borrowernumber,
                branchcode:      branchcode,
                override_limit:  override_limit
            };

            if (UnseenRenewals) {
                var ren = $("#renew_as_unseen_checkbox");
                var renew_unseen = ren.length > 0 && ren.is(':checked') ? 1 : 0;
                params.seen = renew_unseen === 1 ? 0 : 1;
            }

            // Determine which due date we need to use
            var dueDate = isOnReserve ?
                $("#newonholdduedate input").val() :
                $("#newduedate").val();

            if (dueDate && dueDate.length > 0) {
                params.date_due = dueDate
            }

            $.post({
                url: "/cgi-bin/koha/svc/renew",
                data: params,
                success: function( data ) {
                    var id = "#renew_" + data.itemnumber;

                    var content = "";
                    if ( data.renew_okay ) {
                        content = __("Renewed, due:") + " " + data.date_due;
                        $('#date_due_' + data.itemnumber).replaceWith( data.date_due );
                    } else {
                        content = __("Renew failed:") + " ";
                        if ( data.error == "no_checkout" ) {
                            content += __("not checked out");
                        } else if ( data.error == "too_many" ) {
                            content += __("too many renewals");
                        } else if ( data.error == "too_unseen" ) {
                            content += __("too many consecutive renewals without being seen by the library");
                        } else if ( data.error == "on_reserve" ) {
                            content += __("on hold");
                        } else if ( data.error == "restriction" ) {
                            content += __("Not allowed: patron restricted");
                        } else if ( data.error == "overdue" ) {
                            content += __("Not allowed: overdue");
                        } else if ( data.error ) {
                            content += data.error;
                        } else {
                            content += __("reason unknown");
                        }
                    }

                    $(id).replaceWith( content );
            },
            dataType: "json",
            async: false,
            });
        });

        // Refocus on barcode field if it exists
        if ( $("#barcode").length ) {
            $("#barcode").focus();
        }

        // Prevent form submit
        return false;
    });

    $("#RenewAll").on("click",function(){
        $("#CheckAllRenewals").click();
        $("#UncheckAllCheckins").click();
        showHideOnHoldRenewal();
        $("#RenewCheckinChecked").click();

        // Prevent form submit
        return false;
    });

    var ymd = flatpickr.formatDate(new Date(), "Y-m-d");

    $('#issues-table').hide();
    $('#issues-table-actions').hide();
    $('#issues-table-load-immediately').change(function(){
        if ( this.checked && typeof issuesTable === 'undefined') {
            $('#issues-table-load-now-button').click();
        }
        barcodefield.focus();
    });
    $('#issues-table-load-now-button').click(function(){
        LoadIssuesTable();
        barcodefield.focus();
        return false;
    });

    $('#RenewCheckinChecked').on('click', function(){
        RefreshIssuesTable();
    });

    if ( Cookies.get("issues-table-load-immediately-" + script) == "true" ) {
        LoadIssuesTable();
        $('#issues-table-load-immediately').prop('checked', true);
    }
    $('#issues-table-load-immediately').on( "change", function(){
        Cookies.set("issues-table-load-immediately-" + script, $(this).is(':checked'), { expires: 365, sameSite: 'Lax'  });
    });

    function RefreshIssuesTable() {
        var table = $('#issues-table').DataTable();
        table.ajax.reload();
    }

    function LoadIssuesTable() {
        $('#issues-table-loading-message').hide();
        $('#issues-table').show();
        $('#issues-table-actions').show();

        var msg_loading = __('Loading... you may continue scanning.');
        issuesTable = KohaTable("issues-table", {
            "oLanguage": {
                "sEmptyTable" : msg_loading,
                "sProcessing": msg_loading,
            },
            "bAutoWidth": false,
            "dom": 'B<"clearfix">rt',
            "aoColumns": [
                {
                    "mDataProp": function( oObj ) {
                        return oObj.sort_order;
                    }
                },
                {
                    "mDataProp": function( oObj ) {
                        if ( oObj.issued_today ) {
                            return "<strong>" + __("Today's checkouts") + "</strong>";
                        } else {
                            return "<strong>" + __("Previous checkouts") + "</strong>";
                        }
                    }
                },
                {
                    "mDataProp": "date_due",
                    "bVisible": false,
                },
                {
                    "iDataSort": 2, // Sort on hidden unformatted date due column
                    "mDataProp": function( oObj ) {
                        var due = oObj.date_due_formatted;
                        if ( oObj.date_due_overdue ) {
                            due = "<span class='overdue'>" + due + "</span>";
                        }

                        due = "<span id='date_due_" + oObj.itemnumber + "' class='date_due'>" + due + "</span>";

                        if ( oObj.lost && oObj.claims_returned ) {
                            due += "<span class='lost claims_returned'>" + oObj.lost.escapeHtml() + "</span>";
                        } else if ( oObj.lost ) {
                            due += "<span class='lost'>" + oObj.lost.escapeHtml() + "</span>";
                        }

                        if ( oObj.damaged ) {
                            due += "<span class='dmg'>" + oObj.damaged.escapeHtml() + "</span>";
                        }

                        var patron_note = " <span class='patron_note_" + oObj.itemnumber + "'></span>";
                        due +="<br>" + patron_note;

                        return due;
                    }
                },
                {
                    "mDataProp": function ( oObj ) {
                        let title = "<span id='title_" + oObj.itemnumber + "' class='strong'><a href='/cgi-bin/koha/catalogue/detail.pl?biblionumber="
                              + oObj.biblionumber
                              + "'>"
                              + (oObj.title ? oObj.title.escapeHtml() : '' );

                        $.each(oObj.subtitle, function( index, value ) {
                                  title += " " + value.escapeHtml();
                        });

                        title += " " + oObj.part_number + " " + oObj.part_name;

                        if ( oObj.enumchron ) {
                            title += " <span class='item_enumeration'>(" + oObj.enumchron.escapeHtml() + ")</span>";
                        }

                        title += "</a></span>";

                        if ( oObj.author ) {
                            title += " " + __("by _AUTHOR_").replace( "_AUTHOR_",  " " + oObj.author.escapeHtml() );
                        }

                        if ( oObj.itemnotes ) {
                            var span_class = "text-muted";
                            if ( flatpickr.formatDate( new Date(oObj.issuedate), "Y-m-d" ) == ymd ){
                                span_class = "circ-hlt";
                            }
                            title += " - <span class='" + span_class + " item-note-public'>" + oObj.itemnotes.escapeHtml() + "</span>";
                        }

                        if ( oObj.itemnotes_nonpublic ) {
                            var span_class = "text-danger";
                            if ( flatpickr.formatDate( new Date(oObj.issuedate), "Y-m-d" ) == ymd ){
                                span_class = "circ-hlt";
                            }
                            title += " - <span class='" + span_class + " item-note-nonpublic'>" + oObj.itemnotes_nonpublic.escapeHtml() + "</span>";
                        }

                        var onsite_checkout = '';
                        if ( oObj.onsite_checkout == 1 ) {
                            onsite_checkout += " <span class='onsite_checkout'>(" + __("On-site checkout") + ")</span>";
                        }

                        if ( oObj.recalled == 1 ) {
                             title += " - <span class='circ-hlt item-recalled'>" +  __("This item has been recalled and the due date updated") + ".</span>";
                        }

                        title += " "
                              + "<a href='/cgi-bin/koha/catalogue/moredetail.pl?biblionumber="
                              + oObj.biblionumber
                              + "&itemnumber="
                              + oObj.itemnumber
                              + "#"
                              + oObj.itemnumber
                              + "'>"
                              + (oObj.barcode ? oObj.barcode.escapeHtml() : "")
                              + "</a>"
                              + onsite_checkout

                        return title;
                    },
                    "sType": "anti-the"
                },
                {
                    "mDataProp": function ( oObj ) {
                        return oObj.recordtype_description.escapeHtml();
                    }
                },
                {
                    "mDataProp": function ( oObj ) {
                        return oObj.itemtype_description.escapeHtml();
                    }
                },
                {
                    "mDataProp": function ( oObj ) {
                        return ( oObj.collection ? oObj.collection.escapeHtml() : '' );
                    }
                },
                {
                    "mDataProp": function ( oObj ) {
                        return ( oObj.location ? oObj.location.escapeHtml() : '' );
                    }
                },
                {
                    "mDataProp": function ( oObj ) {
                        return (oObj.homebranch ? oObj.homebranch.escapeHtml() : '' );
                    }
                },
                {
                    "mDataProp": "issuedate",
                    "bVisible": false,
                },
                {
                    "iDataSort": 10, // Sort on hidden unformatted issuedate column
                    "mDataProp": "issuedate_formatted",
                },
                {
                    "mDataProp": function ( oObj ) {
                        return (oObj.branchname ? oObj.branchname.escapeHtml() : '' );
                    }
                },
                {
                    "mDataProp": function ( oObj ) {
                        return ( oObj.itemcallnumber ? oObj.itemcallnumber.escapeHtml() : '' );
                    }
                },
                {
                    "mDataProp": function ( oObj ) {
                        return ( oObj.copynumber ? oObj.copynumber.escapeHtml() : '' );
                    }
                },
                {
                    "mDataProp": function ( oObj ) {
                        if ( ! oObj.charge ) oObj.charge = 0;
                        return '<span style="text-align: right; display: block;">' + parseFloat(oObj.charge).toFixed(2) + '<span>';
                    }
                },
                {
                    "mDataProp": function ( oObj ) {
                        if ( ! oObj.fine ) oObj.fine = 0;
                        return '<span style="text-align: right; display: block;">' + parseFloat(oObj.fine).toFixed(2)  + '<span>';
                    }
                },
                {
                    "mDataProp": function ( oObj ) {
                        if ( ! oObj.price ) oObj.price = 0;
                        return '<span style="text-align: right; display: block;">' + parseFloat(oObj.price).toFixed(2) + '<span>';
                    }
                },
                {
                    "bSortable": false,
                    "bVisible": AllowCirculate ? true : false,
                    "mDataProp": function ( oObj ) {
                        var content = "";
                        var msg = "";
                        var span_style = "";
                        var span_class = "";

                        if ( oObj.can_renew ) {
                            // Do nothing
                        } else if ( oObj.can_renew_error == "recalled" ) {
                            msg += "<span>"
                                    + "<a href='/cgi-bin/koha/recalls/request.pl?biblionumber=" + oObj.biblionumber + "'>" + __("Recalled") + "</a>"
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed-recalled";
                        } else if ( oObj.can_renew_error == "on_reserve" ) {
                            msg += "<span>"
                                    +"<a href='/cgi-bin/koha/reserve/request.pl?biblionumber=" + oObj.biblionumber + "'>" + __("On hold") + "</a>"
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed-on_reserve";
                        } else if ( oObj.can_renew_error == "too_many" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + __("Not renewable")
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "too_unseen" ) {
                            msg += "<span>"
                                    + __("Must be renewed at the library")
                                    + "</span>";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "restriction" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + __("Not allowed: patron restricted")
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "overdue" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + __("Not allowed: overdue")
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "too_soon" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + __("No renewal before %s").format(oObj.can_renew_date)
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_too_soon" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + __("Scheduled for automatic renewal")
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_too_late" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + __("Can no longer be auto-renewed - number of checkout days exceeded")
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_too_much_oweing" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + __("Automatic renewal failed, patron has unpaid fines")
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_account_expired" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + __("Automatic renewal failed, account expired")
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_renew" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + __("Scheduled for automatic renewal")
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "onsite_checkout" ) {
                            // Don't display something if it's an onsite checkout
                        } else if ( oObj.can_renew_error == "item_denied_renewal" ) {
                            content += "<span class='renewals-disabled'>"
                                    + __("Renewal denied by syspref")
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else {
                            msg += "<span class='renewals-disabled'>"
                                    + oObj.can_renew_error
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        }

                        var can_force_renew = ( oObj.onsite_checkout == 0 ) &&
                            ( oObj.can_renew_error != "on_reserve" || (oObj.can_renew_error == "on_reserve" && AllowRenewalOnHoldOverride))
                            ? true : false;
                        var can_renew = ( oObj.renewals_remaining > 0 && ( !oObj.can_renew_error || oObj.can_renew_error == "too_unseen" ));
                        content += "<span>";
                        if ( can_renew || can_force_renew ) {
                            content += "<span style='padding: 0 1em;'>" + oObj.renewals_count + "</span>";
                            content += "<span class='" + span_class + "' style='" + span_style + "'>"
                                    +  "<input type='checkbox' ";
                            if ( oObj.date_due_overdue && can_renew ) {
                                content += "checked='checked' ";
                            }
                            if (oObj.can_renew_error == "on_reserve") {
                                content += "data-on-reserve ";
                            }
                            content += "class='renew' id='renew_" + oObj.itemnumber + "' name='renew' value='" + oObj.itemnumber +"'/>"
                                    +  "</span>";
                        }
                        content += msg;
                        if ( can_renew || can_force_renew ) {
                            content += "<span class='renewals'>(";
                            content += __("%s of %s renewals remaining").format(oObj.renewals_remaining, oObj.renewals_allowed);
                            if (UnseenRenewals && oObj.unseen_allowed) {
                                content += __(" and %s of %s unseen renewals remaining").format(oObj.unseen_remaining, oObj.unseen_allowed);
                            }
                            content += ")</span>";
                        }

                        return content;
                    }
                },
                {
                    "bSortable": false,
                    "bVisible": AllowCirculate ? true : false,
                    "mDataProp": function ( oObj ) {
                        if ( oObj.can_renew_error == "recalled" ) {
                            return "<a href='/cgi-bin/koha/recalls/request.pl?biblionumber=" + oObj.biblionumber + "'>" + __("Recalled") + "</a>";
                        } else if ( oObj.can_renew_error == "on_reserve" ) {
                            return "<a href='/cgi-bin/koha/reserve/request.pl?biblionumber=" + oObj.biblionumber + "'>" + __("On hold") + "</a>";
                        } else if ( oObj.materials ) {
                            return "<input type='checkbox' class='confirm' id='confirm_" + oObj.itemnumber + "' name='confirm' value='" + oObj.itemnumber + "' data-materials='" + oObj.materials.escapeHtml() + "'></input>";
                        } else {
                            return "<input type='checkbox' class='checkin' id='checkin_" + oObj.itemnumber + "' name='checkin' value='" + oObj.itemnumber +"'></input>";
                        }
                    }
                },
                {
                    "bVisible": ClaimReturnedLostValue ? true : false,
                    "bSortable": false,
                    "mDataProp": function ( oObj ) {
                        let content = "";

                        if ( oObj.return_claim_id ) {
                          content = '<span class="badge">' + oObj.return_claim_created_on_formatted + '</span>';
                        } else if ( ClaimReturnedLostValue ) {
                          content = '<a class="btn btn-default btn-xs claim-returned-btn" data-itemnumber="' + oObj.itemnumber + '"><i class="fa fa-exclamation-circle"></i> ' + __("Claim returned") + '</a>';
                        } else {
                          content = '<a class="btn btn-default btn-xs" disabled="disabled" title="ClaimReturnedLostValue is not set, this feature is disabled"><i class="fa fa-exclamation-circle"></i> ' + __("Claim returned") + '</a>';
                        }
                        return content;
                    }
                },
                {
                    "bVisible": exports_enabled == 1 ? true : false,
                    "bSortable": false,
                    "mDataProp": function ( oObj ) {
                        var s = "<input type='checkbox' name='itemnumbers' value='" + oObj.itemnumber + "' style='visibility:hidden;' />";

                        s += "<input type='checkbox' class='export' id='export_" + oObj.biblionumber + "' name='biblionumbers' value='" + oObj.biblionumber + "' />";
                        return s;
                    }
                }
            ],
            "fnFooterCallback": function ( nRow, aaData, iStart, iEnd, aiDisplay ) {
                var total_charge = 0;
                var total_fine  = 0;
                var total_price = 0;
                for ( var i=0; i < aaData.length; i++ ) {
                    total_charge += aaData[i]['charge'] * 1;
                    total_fine += aaData[i]['fine'] * 1;
                    total_price  += aaData[i]['price'] * 1;
                }
                $("#totaldue").html(total_charge.toFixed(2));
                $("#totalfine").html(total_fine.toFixed(2));
                $("#totalprice").html(total_price.toFixed(2));
            },
            "bPaginate": false,
            "bProcessing": true,
            "bServerSide": false,
            "sAjaxSource": '/cgi-bin/koha/svc/checkouts',
            "fnServerData": function ( sSource, aoData, fnCallback ) {
                aoData.push( { "name": "borrowernumber", "value": borrowernumber } );

                $.getJSON( sSource, aoData, function (json) {
                    fnCallback(json)
                } );
            },
            "rowGroup":{
                "dataSrc": "issued_today",
                "startRender": function ( rows, group ) {
                    if ( group ) {
                        return __("Today's checkouts");
                    } else {
                        return __("Previous checkouts");
                    }
                }
            },
            "fnInitComplete": function(oSettings, json) {
                // Build a summary of checkouts grouped by itemtype
                var checkoutsByItype = json.aaData.reduce(function (obj, row) {
                    obj[row.type_for_stat] = (obj[row.type_for_stat] || 0) + 1;
                    return obj;
                }, {});
                var ul = $('<ul>');
                Object.keys(checkoutsByItype).sort().forEach(function (itype) {
                    var li = $('<li>')
                        .append($('<strong>').html(itype || __("No itemtype")))
                        .append(': ' + checkoutsByItype[itype]);
                    ul.append(li);
                })
                $('<details>')
                    .addClass('checkouts-by-itemtype')
                    .append($('<summary>').html( __("Number of checkouts by item type") ))
                    .append(ul)
                    .insertBefore(oSettings.nTableWrapper)
            },
        }, table_settings_issues_table);

        if ( $("#issues-table").length ) {
            $("#issues-table_processing").position({
                of: $( "#issues-table" ),
                collision: "none"
            });
        }
    }

    // Don't load relatives' issues table unless it is clicked on
    var relativesIssuesTable;
    $("#relatives-issues-tab").click( function() {
        if ( ! relativesIssuesTable ) {
            relativesIssuesTable = $("#relatives-issues-table").dataTable($.extend(true, {}, dataTablesDefaults, {
                "bAutoWidth": false,
                "sDom": "rt",
                "aaSorting": [],
                "aoColumns": [
                    {
                        "mDataProp": "date_due",
                        "bVisible": false,
                    },
                    {
                        "iDataSort": 0, // Sort on hidden unformatted date due column
                        "mDataProp": function( oObj ) {
                            var today = new Date();
                            var due = new Date( oObj.date_due );
                            if ( today > due ) {
                                return "<span class='overdue'>" + oObj.date_due_formatted + "</span>";
                            } else {
                                return oObj.date_due_formatted;
                            }
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            let title = "<span class='strong'><a href='/cgi-bin/koha/catalogue/detail.pl?biblionumber="
                                  + oObj.biblionumber
                                  + "'>"
                                  + (oObj.title ? oObj.title.escapeHtml() : '' );

                            $.each(oObj.subtitle, function( index, value ) {
                                      title += " " + value.escapeHtml();
                            });

                            title += " " + oObj.part_number + " " + oObj.part_name;

                            if ( oObj.enumchron ) {
                                title += " (" + oObj.enumchron.escapeHtml() + ")";
                            }

                            title += "</a></span>";

                            if ( oObj.author ) {
                                title += " " + __("by _AUTHOR_").replace( "_AUTHOR_", " " + oObj.author.escapeHtml() );
                            }

                            if ( oObj.itemnotes ) {
                                var span_class = "";
                                if ( flatpickr.formatDate( new Date(oObj.issuedate), "Y-m-d" ) == ymd ){
                                    span_class = "circ-hlt";
                                }
                                title += " - <span class='" + span_class + "'>" + oObj.itemnotes.escapeHtml() + "</span>"
                            }

                            if ( oObj.itemnotes_nonpublic ) {
                                var span_class = "";
                                if ( flatpickr.formatDate( new Date(oObj.issuedate), "Y-m-d" ) == ymd ){
                                    span_class = "circ-hlt";
                                }
                                title += " - <span class='" + span_class + "'>" + oObj.itemnotes_nonpublic.escapeHtml() + "</span>"
                            }

                            var onsite_checkout = '';
                            if ( oObj.onsite_checkout == 1 ) {
                                onsite_checkout += " <span class='onsite_checkout'>(" + __("On-site checkout") + ")</span>";
                            }

                            title += " "
                                  + "<a href='/cgi-bin/koha/catalogue/moredetail.pl?biblionumber="
                                  + oObj.biblionumber
                                  + "&itemnumber="
                                  + oObj.itemnumber
                                  + "#"
                                  + oObj.itemnumber
                                  + "'>"
                                  + (oObj.barcode ? oObj.barcode.escapeHtml() : "")
                                  + "</a>"
                                  + onsite_checkout;

                            return title;
                        },
                        "sType": "anti-the"
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            return oObj.recordtype_description.escapeHtml();
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            return oObj.itemtype_description.escapeHtml();
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            return ( oObj.collection ? oObj.collection.escapeHtml() : '' );
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            return ( oObj.location ? oObj.location.escapeHtml() : '' );
                        }
                    },
                    {
                        "mDataProp": "issuedate",
                        "bVisible": false,
                    },
                    {
                        "iDataSort": 7, // Sort on hidden unformatted issuedate column
                        "mDataProp": "issuedate_formatted",
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            return ( oObj.branchname ? oObj.branchname.escapeHtml() : '' );
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            return ( oObj.itemcallnumber ? oObj.itemcallnumber.escapeHtml() : '' );
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            return ( oObj.copynumber ? oObj.copynumber.escapeHtml() : '' );
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            if ( ! oObj.charge ) oObj.charge = 0;
                            return parseFloat(oObj.charge).toFixed(2);
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            if ( ! oObj.fine ) oObj.fine = 0;
                            return parseFloat(oObj.fine).toFixed(2);
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            if ( ! oObj.price ) oObj.price = 0;
                            return parseFloat(oObj.price).toFixed(2);
                        }
                    },
                    {
                        "mDataProp": function( oObj ) {
                            return "<a href='/cgi-bin/koha/members/moremember.pl?borrowernumber=" + oObj.borrowernumber + "'>"
                                + ( oObj.borrower.firstname ? oObj.borrower.firstname.escapeHtml() : "" )
                                + " " +
                                ( oObj.borrower.surname ? oObj.borrower.surname.escapeHtml() : "" )
                                + " (" + ( oObj.borrower.cardnumber ? oObj.borrower.cardnumber.escapeHtml() : "" ) + ")</a>"
                        }
                    },
                ],
                "bPaginate": false,
                "bProcessing": true,
                "bServerSide": false,
                "sAjaxSource": '/cgi-bin/koha/svc/checkouts',
                "fnServerData": function ( sSource, aoData, fnCallback ) {
                    $.each(relatives_borrowernumbers, function( index, value ) {
                        aoData.push( { "name": "borrowernumber", "value": value } );
                    });

                    $.getJSON( sSource, aoData, function (json) {
                        fnCallback(json)
                    } );
                },
            }));
        }
    });

    if ( $("#relatives-issues-table").length ) {
        $("#relatives-issues-table_processing").position({
            of: $( "#relatives-issues-table" ),
            collision: "none"
        });
    }

    if ( AllowRenewalLimitOverride || AllowRenewalOnHoldOverride ) {
        $( '#override_limit' ).click( function () {
            if ( this.checked ) {
                if ( AllowRenewalLimitOverride ) {
                    $( '.renewals-allowed' ).show();
                    $( '.renewals-disabled' ).hide();
                }
                if ( AllowRenewalOnHoldOverride ) {
                    $( '.renewals-allowed-on_reserve' ).show();
                }
            } else {
                $( '.renewals-allowed' ).hide();
                $( '.renewals-allowed-on_reserve' ).hide();
                $( '.renewals-disabled' ).show();
            }
        } ).prop('checked', false);
    }

    // Handle return claims
    $(document).on("click", '.claim-returned-btn', function(e){
        e.preventDefault();
        itemnumber = $(this).data('itemnumber');

        $('#claims-returned-itemnumber').val(itemnumber);
        $('#claims-returned-notes').val("");
        $('#claims-returned-charge-lost-fee').attr('checked', false)
        $('#claims-returned-modal').modal()
    });
    $(document).on("click", '#claims-returned-modal-btn-submit', function(e){
        let itemnumber = $('#claims-returned-itemnumber').val();
        let notes = $('#claims-returned-notes').val();
        let fee = $('#claims-returned-charge-lost-fee').attr('checked') ? true : false;

        $('#claims-returned-modal').modal('hide')

        $('.claim-returned-btn[data-itemnumber="' + itemnumber + '"]').replaceWith('<img id="return_claim_spinner_' + itemnumber + ' src=' + interface + '/' + theme + '/img/spinner-small.gif />');

        params = {
            item_id: itemnumber,
            notes: notes,
            charge_lost_fee: fee,
            created_by: logged_in_user_borrowernumber,
        };

        $.post( '/api/v1/return_claims', JSON.stringify(params), function( data ) {

            id = "#return_claim_spinner_" + data.item_id;

            let created_on = new Date(data.created_on);

            let content = "";
            if ( data.claim_id ) {
                content = '<span class="badge">' + created_on.toLocaleDateString() + '</span>';
                $(id).parent().parent().addClass('ok');
            } else {
                content = __("Unable to claim as returned");
                $(id).parent().parent().addClass('warn');
            }

            $(id).replaceWith( content );

            refreshReturnClaimsTable();
            issuesTable.api().ajax.reload();
        }, "json")

    });


    // Don't load return claims table unless it is clicked on
    var returnClaimsTable;
    $("#return-claims-tab").click( function() {
        refreshReturnClaimsTable();
    });

    function refreshReturnClaimsTable(){
        loadReturnClaimsTable();
        $("#return-claims-table").DataTable().ajax.reload();
    }
    function loadReturnClaimsTable() {
        if ( ! returnClaimsTable ) {
            returnClaimsTable = $("#return-claims-table").dataTable({
                "bAutoWidth": false,
                "sDom": "rt",
                "aaSorting": [],
                "aoColumnDefs": [
                    { "bSortable": false, "bSearchable": false, 'aTargets': ['NoSort'] },
                    { "sType": "anti-the", "aTargets": ["anti-the"] },
                ],
                "aoColumns": [
                    {
                        "mDataProp": "id",
                        "bVisible": false,
                    },
                    {
                        "mDataProp": function (oObj) {
                            if (oObj.resolution) {
                                return "is_resolved";
                            } else {
                                return "is_unresolved";
                            }
                        },
                        "bVisible": false,
                    },
                    {
                        "mDataProp": function ( oObj ) {
                              let title = '<a class="return-claim-title strong" href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=' + oObj.biblionumber + '">'
                                  + oObj.title
                                  + ( oObj.subtitle ? " " + oObj.subtitle : "" )
                                  + ( oObj.enumchron || "" )
                              + '</a>';
                              if ( oObj.author ) {
                                title += ' by ' + oObj.author;
                              }
                              title += ' <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber='
                                    + oObj.biblionumber
                                    + '&itemnumber='
                                    + oObj.itemnumber
                                    + '">'
                                    + (oObj.barcode ? oObj.barcode.escapeHtml() : "")
                                    + '</a>';

                              return title;
                        }
                    },
                    {
                        "sClass": "return-claim-notes-td",
                        "mDataProp": function ( oObj ) {
                            let notes =  '<span id="return-claim-notes-static-' + oObj.id + '" class="return-claim-notes" data-return-claim-id="' + oObj.id + '">';
                            if ( oObj.notes ) {
                                notes += oObj.notes;
                            }
                            notes += '</span>';
                            notes += '<i style="float:right" class="fa fa-pencil-square-o" title="' + __("Double click to edit") + '"></i>';
                            return notes;
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            let created_on = new Date( oObj.created_on );
                            return created_on.toLocaleDateString();
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            if ( oObj.updated_on ) {
                                let updated_on = new Date( oObj.updated_on );
                                return updated_on.toLocaleDateString();
                            } else {
                                return "";
                            }
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            if ( ! oObj.resolution ) return "";

                            let desc = '<strong>' + oObj.resolution_data.lib + '</strong> <i>(';
                            if (oObj.resolved_by_data) desc += '<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=' + oObj.resolved_by_data.borrowernumber + '">' + ( oObj.resolved_by_data.firstname || "" ) + " " + ( oObj.resolved_by_data.surname || "" ) + '</a>';
                            desc += ', ' + oObj.resolved_on + ')</i>';
                            return desc;
                        }
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            let delete_html = oObj.resolved_on
                                ? '<li><a href="#" class="return-claim-tools-delete" data-return-claim-id="' + oObj.id + '"><i class="fa fa-trash"></i> ' + __("Delete") + '</a></li>'
                                : "";
                            let resolve_html = ! oObj.resolution
                                ? '<li><a href="#" class="return-claim-tools-resolve" data-return-claim-id="' + oObj.id + '" data-current-lost-status="' + escape_str(oObj.itemlost) + '"><i class="fa fa-check-square"></i> ' + __("Resolve") + '</a></li>'
                                : "";

                            return  '<div class="btn-group">'
                                  + ' <button type="button" class="btn btn-default btn-xs dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">'
                                  + __("Actions") + ' <span class="caret"></span>'
                                  + ' </button>'
                                  + ' <ul class="dropdown-menu">'
                                  + '  <li><a href="#" class="return-claim-tools-editnotes" data-return-claim-id="' + oObj.id + '"><i class="fa fa-edit"></i> ' + __("Edit notes") + '</a></li>'
                                  + resolve_html
                                  + delete_html
                                  + ' </ul>'
                                  + ' </div>';
                        }
                    },
                ],
                "bPaginate": false,
                "bProcessing": true,
                "bServerSide": false,
                "sAjaxSource": '/cgi-bin/koha/svc/return_claims',
                "fnServerData": function ( sSource, aoData, fnCallback ) {
                    aoData.push( { "name": "borrowernumber", "value": borrowernumber } );

                    $.getJSON( sSource, aoData, function (json) {
                        let resolved = json.resolved;
                        let unresolved = json.unresolved;

                        if ( resolved > 0 ) {
                            $('#return-claims-count-resolved').text(resolved)
                                                              .removeClass('label-default')
                                                              .addClass('label-success');
                        } else {
                            $('#return-claims-count-resolved').text(resolved)
                                                              .removeClass('label-success')
                                                              .addClass('label-default');
                        }
                        if ( unresolved > 0 ) {
                            $('#return-claims-count-unresolved').text(unresolved)
                                                                .removeClass('label-default')
                                                                .addClass('label-warning');
                        } else {
                            $('#return-claims-count-unresolved').text(unresolved)
                                                                .removeClass('label-warning')
                                                                .addClass('label-default');
                        }

                        fnCallback(json)
                    } );
                },
                "search": { "search": "is_unresolved" },
                "footerCallback": function (row, data, start, end, display) {
                    var api = this.api();
                    // Total over all pages
                    var colData = api.column(1).data();
                    var is_unresolved = 0;
                    var is_resolved = 0;
                    colData.each(function( index, value ){
                        if( index == "is_unresolved" ){ is_unresolved++; }
                        if (index == "is_resolved") { is_resolved++; }
                    });
                    // Update footer
                    $("#return-claims-controls").html( showClaimFilter( is_unresolved, is_resolved ) )
                }
            });
        }
    }

    function showClaimFilter( is_unresolved, is_resolved ){
        var showAll, showUnresolved;
        var total = Number( is_unresolved ) + Number( is_resolved );
        if( total > 0 ){
            showAll = __nx("Show 1 claim", "Show all {count} claims", total, { count: total });
        } else {
            showAll = "";
        }
        if( is_unresolved > 0 ){
            showUnresolved = __nx("Show 1 unresolved claim", "Show {count} unresolved claims", is_unresolved, { count: is_unresolved })
        } else {
            showUnresolved = "";
        }
        $("#show_all_claims").html( showAll );
        $("#show_unresolved_claims").html( showUnresolved );
    }

    $('body').on('click', '.return-claim-tools-editnotes', function() {
        let id = $(this).data('return-claim-id');
        $('#return-claim-notes-static-' + id).parent().dblclick();
    });
    $('body').on('dblclick', '.return-claim-notes-td', function() {
        let elt = $(this).children('.return-claim-notes');
        let id = elt.data('return-claim-id');
        if ( $('#return-claim-notes-editor-textarea-' + id).length == 0 ) {
            let note = elt.text();
            let editor =
                '  <span id="return-claim-notes-editor-' + id + '">'
                + ' <textarea id="return-claim-notes-editor-textarea-' + id + '">' + note + '</textarea>'
                + ' <br/>'
                + ' <a class="btn btn-default btn-xs claim-returned-notes-editor-submit" data-return-claim-id="' + id + '"><i class="fa fa-save"></i> ' + __("Update") + '</a>'
                + ' <a class="claim-returned-notes-editor-cancel" data-return-claim-id="' + id + '" href="#">' + __("Cancel") + '</a>'
                + '</span>';
            elt.hide();
            $(editor).insertAfter( elt );
        }
    });

    $('body').on('click', '.claim-returned-notes-editor-submit', function(){
        let id = $(this).data('return-claim-id');
        let notes = $('#return-claim-notes-editor-textarea-' + id).val();

        let params = {
            notes: notes,
            updated_by: logged_in_user_borrowernumber
        };

        $(this).parent().remove();

        $.ajax({
            url: '/api/v1/return_claims/' + id + '/notes',
            type: 'PUT',
            data: JSON.stringify(params),
            success: function( data ) {
                let notes = $('#return-claim-notes-static-' + id);
                notes.text(data.notes);
                notes.show();
            },
            contentType: "json"
        });
    });

    $('body').on('click', '.claim-returned-notes-editor-cancel', function(){
        let id = $(this).data('return-claim-id');
        $(this).parent().remove();
        $('#return-claim-notes-static-' + id).show();
    });

    // Hanld return claim deletion
    $('body').on('click', '.return-claim-tools-delete', function() {
        let confirmed = confirm(__("Are you sure you want to delete this return claim?"));
        if ( confirmed ) {
            let id = $(this).data('return-claim-id');

            $.ajax({
                url: '/api/v1/return_claims/' + id,
                type: 'DELETE',
                success: function( data ) {
                    refreshReturnClaimsTable();
                    issuesTable.api().ajax.reload();
                }
            });
        }
    });

    $("#show_all_claims").on("click", function(e){
        e.preventDefault();
        $(".ctrl_link").removeClass("disabled");
        $(this).addClass("disabled");
        $("#return-claims-table").DataTable().search("").draw();
    });

    $("#show_unresolved_claims").on("click", function (e) {
        e.preventDefault();
        $(".ctrl_link").removeClass("disabled");
        $(this).addClass("disabled");
        $("#return-claims-table").DataTable().search("is_unresolved").draw();
    });

 });
