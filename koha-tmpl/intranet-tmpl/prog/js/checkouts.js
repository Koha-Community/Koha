/* global PATRON_NOTE */

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

            $.post( "/cgi-bin/koha/svc/checkin", params, function( data ) {
                id = "#checkin_" + data.itemnumber;

                content = "";
                if ( data.returned ) {
                    content = CIRCULATION_RETURNED;
                    $(id).parent().parent().addClass('ok');
                    $('#date_due_' + data.itemnumber).html(CIRCULATION_RETURNED);
                    if ( data.patronnote != null ) {
                        $('.patron_note_' + data.itemnumber).html( PATRON_NOTE + ": " + data.patronnote);
                    }
                } else {
                    content = CIRCULATION_NOT_RETURNED;
                    $(id).parent().parent().addClass('warn');
                }

                $(id).replaceWith( content );
            }, "json")
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
                override_limit:  override_limit,
            };

            // Determine which due date we need to use
            var dueDate = isOnReserve ?
                $("#newonholdduedate input").val() :
                $("#newduedate").val();

            if (dueDate && dueDate.length > 0) {
                params.date_due = dueDate
            }

            $.post( "/cgi-bin/koha/svc/renew", params, function( data ) {
                var id = "#renew_" + data.itemnumber;

                var content = "";
                if ( data.renew_okay ) {
                    content = CIRCULATION_RENEWED_DUE + " " + data.date_due;
                    $('#date_due_' + data.itemnumber).replaceWith( data.date_due );
                } else {
                    content = CIRCULATION_RENEW_FAILED + " ";
                    if ( data.error == "no_checkout" ) {
                        content += NOT_CHECKED_OUT;
                    } else if ( data.error == "too_many" ) {
                        content += TOO_MANY_RENEWALS;
                    } else if ( data.error == "on_reserve" ) {
                        content += ON_RESERVE;
                    } else if ( data.error == "restriction" ) {
                        content += NOT_RENEWABLE_RESTRICTION;
                    } else if ( data.error == "overdue" ) {
                        content += NOT_RENEWABLE_OVERDUE;
                    } else if ( data.error ) {
                        content += data.error;
                    } else {
                        content += REASON_UNKNOWN;
                    }
                }

                $(id).replaceWith( content );
            }, "json")
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

    var ymd = $.datepicker.formatDate('yy-mm-dd', new Date());

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

    if ( Cookies.get("issues-table-load-immediately-" + script) == "true" ) {
        LoadIssuesTable();
        $('#issues-table-load-immediately').prop('checked', true);
    }
    $('#issues-table-load-immediately').on( "change", function(){
        Cookies.set("issues-table-load-immediately-" + script, $(this).is(':checked'), { expires: 365 });
    });

    function LoadIssuesTable() {
        $('#issues-table-loading-message').hide();
        $('#issues-table').show();
        $('#issues-table-actions').show();

        issuesTable = KohaTable("issues-table", {
            "oLanguage": {
                "sEmptyTable" : MSG_DT_LOADING_RECORDS,
                "sProcessing": MSG_DT_LOADING_RECORDS,
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
                            return "<strong>" + TODAYS_CHECKOUTS + "</strong>";
                        } else {
                            return "<strong>" + PREVIOUS_CHECKOUTS + "</strong>";
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
                            title += " (" + oObj.enumchron.escapeHtml() + ")";
                        }

                        title += "</a></span>";

                        if ( oObj.author ) {
                            title += " " + BY.replace( "_AUTHOR_",  " " + oObj.author.escapeHtml() );
                        }

                        if ( oObj.itemnotes ) {
                            var span_class = "text-muted";
                            if ( $.datepicker.formatDate('yy-mm-dd', new Date(oObj.issuedate) ) == ymd ) {
                                span_class = "circ-hlt";
                            }
                            title += " - <span class='" + span_class + " item-note-public'>" + oObj.itemnotes.escapeHtml() + "</span>";
                        }

                        if ( oObj.itemnotes_nonpublic ) {
                            var span_class = "text-danger";
                            if ( $.datepicker.formatDate('yy-mm-dd', new Date(oObj.issuedate) ) == ymd ) {
                                span_class = "circ-hlt";
                            }
                            title += " - <span class='" + span_class + " item-note-nonpublic'>" + oObj.itemnotes_nonpublic.escapeHtml() + "</span>";
                        }

                        var onsite_checkout = '';
                        if ( oObj.onsite_checkout == 1 ) {
                            onsite_checkout += " <span class='onsite_checkout'>(" + INHOUSE_USE + ")</span>";
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
                        } else if ( oObj.can_renew_error == "on_reserve" ) {
                            msg += "<span>"
                                    + "<a href='/cgi-bin/koha/reserve/request.pl?biblionumber=" + oObj.biblionumber + "'>" + ON_HOLD + "</a>"
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed-on_reserve";
                        } else if ( oObj.can_renew_error == "too_many" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "restriction" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_RESTRICTION
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "overdue" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_OVERDUE
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "too_soon" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_TOO_SOON.format( oObj.can_renew_date )
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_too_soon" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_AUTO_TOO_SOON
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_too_late" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_AUTO_TOO_LATE
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_too_much_oweing" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_AUTO_TOO_MUCH_OWEING
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_account_expired" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_AUTO_ACCOUNT_EXPIRED
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_renew" ) {
                            msg += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_AUTO_RENEW
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "onsite_checkout" ) {
                            // Don't display something if it's an onsite checkout
                        } else if ( oObj.can_renew_error == "item_denied_renewal" ) {
                            content += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_DENIED
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
                        var can_renew = ( oObj.renewals_remaining > 0  && !oObj.can_renew_error );
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
                            content += "<span class='renewals'>("
                                    + RENEWALS_REMAINING.format( oObj.renewals_remaining, oObj.renewals_allowed )
                                    + ")</span>";
                        }

                        content += "</span>";

                        return content;
                    }
                },
                {
                    "bSortable": false,
                    "bVisible": AllowCirculate ? true : false,
                    "mDataProp": function ( oObj ) {
                        if ( oObj.can_renew_error == "on_reserve" ) {
                            return "<a href='/cgi-bin/koha/reserve/request.pl?biblionumber=" + oObj.biblionumber + "'>" + ON_HOLD + "</a>";
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
                        } else {
                          content = '<a class="btn btn-default btn-xs claim-returned-btn" data-itemnumber="' + oObj.itemnumber + '"><i class="fa fa-exclamation-circle"></i>' + RETURN_CLAIMED_MAKE + '</a>';
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
            "fnInitComplete": function(oSettings, json) {
                // Disable rowGrouping plugin after first use
                // so any sorting on the table doesn't use it
                var oSettings = issuesTable.fnSettings();

                for (f = 0; f < oSettings.aoDrawCallback.length; f++) {
                    if (oSettings.aoDrawCallback[f].sName == 'fnRowGrouping') {
                        oSettings.aoDrawCallback.splice(f, 1);
                        break;
                    }
                }

                oSettings.aaSortingFixed = null;

                // Build a summary of checkouts grouped by itemtype
                var checkoutsByItype = json.aaData.reduce(function (obj, row) {
                    obj[row.type_for_stat] = (obj[row.type_for_stat] || 0) + 1;
                    return obj;
                }, {});
                var ul = $('<ul>');
                Object.keys(checkoutsByItype).sort().forEach(function (itype) {
                    var li = $('<li>')
                        .append($('<strong>').html(itype || MSG_NO_ITEMTYPE))
                        .append(': ' + checkoutsByItype[itype]);
                    ul.append(li);
                })
                $('<details>')
                    .addClass('checkouts-by-itemtype')
                    .append($('<summary>').html(MSG_CHECKOUTS_BY_ITEMTYPE))
                    .append(ul)
                    .insertBefore(oSettings.nTableWrapper)
            },
        }, columns_settings_issues_table).rowGrouping(
            {
                iGroupingColumnIndex: 1,
                iGroupingOrderByColumnIndex: 0,
                sGroupingColumnSortDirection: "asc"
            }
        );

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
                                title += " " + BY.replace( "_AUTHOR_", " " + oObj.author.escapeHtml() );
                            }

                            if ( oObj.itemnotes ) {
                                var span_class = "";
                                if ( $.datepicker.formatDate('yy-mm-dd', new Date(oObj.issuedate) ) == ymd ) {
                                    span_class = "circ-hlt";
                                }
                                title += " - <span class='" + span_class + "'>" + oObj.itemnotes.escapeHtml() + "</span>"
                            }

                            if ( oObj.itemnotes_nonpublic ) {
                                var span_class = "";
                                if ( $.datepicker.formatDate('yy-mm-dd', new Date(oObj.issuedate) ) == ymd ) {
                                    span_class = "circ-hlt";
                                }
                                title += " - <span class='" + span_class + "'>" + oObj.itemnotes_nonpublic.escapeHtml() + "</span>"
                            }

                            var onsite_checkout = '';
                            if ( oObj.onsite_checkout == 1 ) {
                                onsite_checkout += " <span class='onsite_checkout'>(" + INHOUSE_USE + ")</span>";
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
                                + oObj.borrower.firstname.escapeHtml()
                                + " " +
                                oObj.borrower.surname.escapeHtml()
                                + " (" + oObj.borrower.cardnumber.escapeHtml() + ")</a>"
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
                content = RETURN_CLAIMED_FAILURE;
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
                "aoColumns": [
                    {
                        "mDataProp": "id",
                        "bVisible": false,
                    },
                    {
                        "mDataProp": function ( oObj ) {
                              let title = '<a class="return-claim-title strong" href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=' + oObj.biblionumber + '">'
                                  + oObj.title
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
                            return '<span id="return-claim-notes-static-' + oObj.id + '" class="return-claim-notes" data-return-claim-id="' + oObj.id + '">' + oObj.notes + '</span>'
                                + '<i style="float:right" class="fa fa-pencil-square-o" title="' + __("Double click to edit") + '"></i>';
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
                                ? '<li><a href="#" class="return-claim-tools-resolve" data-return-claim-id="' + oObj.id + '"><i class="fa fa-check-square"></i> ' + __("Resolve") + '</a></li>'
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

                        $('#return-claims-count-resolved').text(resolved);
                        $('#return-claims-count-unresolved').text(unresolved);

                        fnCallback(json)
                    } );
                },
            });
        }
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
        let confirmed = confirm(CONFIRM_DELETE_RETURN_CLAIM);
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

    // Handle return claim resolution
    $('body').on('click', '.return-claim-tools-resolve', function() {
        let id = $(this).data('return-claim-id');

        $('#claims-returned-resolved-modal-id').val(id);
        $('#claims-returned-resolved-modal').modal()
    });

    $(document).on('click', '#claims-returned-resolved-modal-btn-submit', function(e) {
        let resolution = $('#claims-returned-resolved-modal-resolved-code').val();
        let id = $('#claims-returned-resolved-modal-id').val();

        $('#claims-returned-resolved-modal-btn-submit-spinner').show();
        $('#claims-returned-resolved-modal-btn-submit-icon').hide();

        params = {
          resolution: resolution,
          updated_by: logged_in_user_borrowernumber
        };

        $.ajax({
            url: '/api/v1/return_claims/' + id + '/resolve',
            type: 'PUT',
            data: JSON.stringify(params),
            success: function( data ) {
                $('#claims-returned-resolved-modal-btn-submit-spinner').hide();
                $('#claims-returned-resolved-modal-btn-submit-icon').show();
                $('#claims-returned-resolved-modal').modal('hide')

                refreshReturnClaimsTable();
            },
            contentType: "json"
        });

    });

 });
