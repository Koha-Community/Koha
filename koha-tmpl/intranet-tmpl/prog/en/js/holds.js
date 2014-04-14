$(document).ready(function() {
    // Don't load holds table unless it is clicked on
    var holdsTable;
    $("#holds-tab").click( function() {
        if ( ! holdsTable ) {
            holdsTable = $("#holds-table").dataTable({
                "bAutoWidth": false,
                "sDom": "<'row-fluid'<'span6'><'span6'>r>t<'row-fluid'>t",
                "aoColumns": [
                    {
                        "mDataProp": "reservedate_formatted"
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            title = "<a href='/cgi-bin/koha/reserve/request.pl?biblionumber="
                                  + oObj.biblionumber
                                  + "'>"
                                  + oObj.title;

                            $.each(oObj.subtitle, function( index, value ) {
                                      title += " " + value.subfield;
                            });

                            title += "</a>";

                            if ( oObj.author ) {
                                title += " " + BY.replace( "_AUTHOR_",  oObj.author );
                            }

                            if ( oObj.itemnotes ) {
                                var span_class = "";
                                if ( $.datepicker.formatDate('yy-mm-dd', new Date(oObj.issuedate) ) == ymd ) {
                                    span_class = "circ-hlt";
                                }
                                title += " - <span class='" + span_class + "'>" + oObj.itemnotes + "</span>"
                            }

                            return title;
                        }
                    },
                    {
                        "mDataProp": function( oObj ) {
                            return oObj.itemcallnumber || "";
                        }
                    },
                    {
                        "mDataProp": function( oObj ) {
                            var data = "";

                            if ( oObj.suspend == 1 ) {
                                data += "<p>" + HOLD_IS_SUSPENDED;
                                if ( oObj.suspend_until ) {
                                    data += " " + UNTIL.replace( "_SUSPEND_UNTIL_", oObj.suspend_until_formatted );
                                }
                                data += "</p>";
                            }

                            if ( oObj.barcode ) {
                                data += "<em>";
                                if ( oObj.found == "W" ) {
                                    data += ITEM_IS_WAITING;

                                    if ( ! oObj.waiting_here ) {
                                        data += " " + AT.replace("_WAITING_AT_BRANCH_", oObj.waiting_at );
                                    }
                                } else if ( oObj.transferred ) {
                                    data += ITEM_IS_IN_TRANSIT.replace( "_FROM_BRANCH_", oObj.from_branch );
                                } else if ( oObj.not_transferred ) {
                                    data += NOT_TRANSFERRED_YET.replace( "_FROM_BRANCH_", oObj.not_transferred_by );
                                }
                                data += "</em>";

                                data += " <a href='/cgi-bin/koha/catalogue/detail.pl?biblionumber="
                                  + oObj.biblionumber
                                  + "&itemnumber="
                                  + oObj.itemnumber
                                  + "#"
                                  + oObj.itemnumber
                                  + "'>"
                                  + oObj.barcode
                                  + "</a>";
                            }

                            return data;
                        }
                    },
                    { "mDataProp": "expirationdate_formatted" },
                    {
                        "mDataProp": function( oObj ) {
                            if ( oObj.priority && parseInt( oObj.priority ) && parseInt( oObj.priority ) > 0 ) {
                                return oObj.priority;
                            } else {
                                return "";
                            }
                        }
                    },
                    {
                        "bSortable": false,
                        "mDataProp": function( oObj ) {
                            return "<select name='rank-request'>"
                                 + "<option value='n'>" + NO + "</option>"
                                 + "<option value='del'>" + YES  + "</option>"
                                 + "</select>"
                                 + "<input type='hidden' name='biblionumber' value='" + oObj.biblionumber + "'>"
                                 + "<input type='hidden' name='borrowernumber' value='" + borrowernumber + "'>"
                                 + "<input type='hidden' name='reserve_id' value='" + oObj.reserve_id + "'>";
                        }
                    }
                ],
                "bPaginate": false,
                "bProcessing": true,
                "bServerSide": false,
                "sAjaxSource": '/cgi-bin/koha/svc/holds.pl',
                "fnServerData": function ( sSource, aoData, fnCallback ) {
                    aoData.push( { "name": "borrowernumber", "value": borrowernumber } );

                    $.getJSON( sSource, aoData, function (json) {
                        fnCallback(json)
                    } );
                },
            });

            if ( $("#holds-table").length ) {
                $("#holds-table_processing").position({
                    of: $( "#holds-table" ),
                    collision: "none"
                });
            }
        }
    });

});
