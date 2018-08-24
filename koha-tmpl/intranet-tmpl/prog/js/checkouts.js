$(document).ready(function() {
    $.ajaxSetup ({ cache: false });

    var barcodefield = $("#barcode");

    // Handle the select all/none links for checkouts table columns
    $("#CheckAllRenewals").on("click",function(){
        $("#UncheckAllCheckins").click();
        $(".renew:visible").prop("checked", true);
        return false;
    });
    $("#UncheckAllRenewals").on("click",function(){
        $(".renew:visible").prop("checked", false);
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
                        $('.patron_note_' + data.itemnumber).html("Patron note: " + data.patronnote);
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

            var itemnumber = $(this).val();

            $(this).parent().parent().replaceWith("<img id='renew_" + itemnumber + "' src='" + interface + "/" + theme + "/img/spinner-small.gif' />");

            var params = {
                itemnumber:     itemnumber,
                borrowernumber: borrowernumber,
                branchcode:     branchcode,
                override_limit: override_limit,
                date_due:       $("#newduedate").val()
            };

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

    if ( $.cookie("issues-table-load-immediately-" + script) == "true" ) {
        LoadIssuesTable();
        $('#issues-table-load-immediately').prop('checked', true);
    }
    $('#issues-table-load-immediately').on( "change", function(){
        $.cookie("issues-table-load-immediately-" + script, $(this).is(':checked'), { expires: 365 });
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

                        if ( oObj.lost ) {
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
                        title = "<span id='title_" + oObj.itemnumber + "' class='strong'><a href='/cgi-bin/koha/catalogue/detail.pl?biblionumber="
                              + oObj.biblionumber
                              + "'>"
                              + oObj.title.escapeHtml();

                        $.each(oObj.subtitle, function( index, value ) {
                                  title += " " + value.subfield.escapeHtml();
                        });

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
                              + oObj.barcode.escapeHtml()
                              + "</a>"
                              + onsite_checkout

                        return title;
                    },
                    "sType": "anti-the"
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
                        return oObj.homebranch.escapeHtml();
                    }
                },
                { "mDataProp": "issuedate_formatted" },
                {
                    "mDataProp": function ( oObj ) {
                        return oObj.branchname.escapeHtml();
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
                        var span_style = "";
                        var span_class = "";

                        content += "<span>";
                        content += "<span style='padding: 0 1em;'>" + oObj.renewals_count + "</span>";

                        if ( oObj.can_renew ) {
                            // Do nothing
                        } else if ( oObj.can_renew_error == "on_reserve" ) {
                            content += "<span class='renewals-disabled-no-override'>"
                                    + "<a href='/cgi-bin/koha/reserve/request.pl?biblionumber=" + oObj.biblionumber + "'>" + ON_HOLD + "</a>"
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "too_many" ) {
                            content += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "restriction" ) {
                            content += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_RESTRICTION
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "overdue" ) {
                            content += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_OVERDUE
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "too_soon" ) {
                            content += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_TOO_SOON.format( oObj.can_renew_date )
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_too_soon" ) {
                            content += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_AUTO_TOO_SOON
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_too_late" ) {
                            content += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_AUTO_TOO_LATE
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_too_much_oweing" ) {
                            content += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_AUTO_TOO_MUCH_OWEING
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_account_expired" ) {
                            content += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_AUTO_ACCOUNT_EXPIRED
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "auto_renew" ) {
                            content += "<span class='renewals-disabled'>"
                                    + NOT_RENEWABLE_AUTO_RENEW
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if ( oObj.can_renew_error == "onsite_checkout" ) {
                            // Don't display something if it's an onsite checkout
                        } else {
                            content += "<span class='renewals-disabled'>"
                                    + oObj.can_renew_error
                                    + "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        }

                        var can_force_renew = ( oObj.onsite_checkout == 0 ) && ( oObj.can_renew_error != "on_reserve" );
                        var can_renew = ( oObj.renewals_remaining > 0  && !oObj.can_renew_error );
                        if ( can_renew || can_force_renew ) {
                            content += "<span class='" + span_class + "' style='" + span_style + "'>"
                                    +  "<input type='checkbox' ";
                            if ( oObj.date_due_overdue && can_renew ) {
                                content += "checked='checked' ";
                            }
                            content += "class='renew' id='renew_" + oObj.itemnumber + "' name='renew' value='" + oObj.itemnumber +"'/>"
                                    +  "</span>";

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
                    obj[row.itemtype_description] = (obj[row.itemtype_description] || 0) + 1;
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
        }, columns_settings).rowGrouping(
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
            relativesIssuesTable = $("#relatives-issues-table").dataTable({
                "bAutoWidth": false,
                "sDom": "rt",
                "aaSorting": [],
                "aoColumns": [
                    {
                        "mDataProp": "date_due",
                        "bVisible": false,
                    },
                    {
                        "iDataSort": 1, // Sort on hidden unformatted date due column
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
                            title = "<span class='strong'><a href='/cgi-bin/koha/catalogue/detail.pl?biblionumber="
                                  + oObj.biblionumber
                                  + "'>"
                                  + oObj.title.escapeHtml();

                            $.each(oObj.subtitle, function( index, value ) {
                                      title += " " + value.subfield.escapeHtml();
                            });

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
                                  + oObj.barcode.escapeHtml()
                                  + "</a>"
                                  + onsite_checkout;

                            return title;
                        },
                        "sType": "anti-the"
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
                    { "mDataProp": "issuedate_formatted" },
                    {
                        "mDataProp": function ( oObj ) {
                            return oObj.branchname.escapeHtml();
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
            });
        }
    });

    if ( $("#relatives-issues-table").length ) {
        $("#relatives-issues-table_processing").position({
            of: $( "#relatives-issues-table" ),
            collision: "none"
        });
    }

    if ( AllowRenewalLimitOverride ) {
        $( '#override_limit' ).click( function () {
            if ( this.checked ) {
                $( '.renewals-allowed' ).show(); $( '.renewals-disabled' ).hide();
            } else {
                $( '.renewals-allowed' ).hide(); $( '.renewals-disabled' ).show();
            }
        } ).prop('checked', false);
    }
 });
