$(document).ready(function() {
    var holdsTable;

    // Don't load holds table unless it is clicked on
    $("#holds-tab").on( "click", function(){ load_holds_table() } );

    // If the holds tab is preselected on load, we need to load the table
    if ( $("#holds-tab").parent().hasClass('ui-state-active') ) { load_holds_table() }

    function load_holds_table() {
        if ( ! holdsTable ) {
            holdsTable = $("#holds-table").dataTable({
                "bAutoWidth": false,
                "sDom": "rt",
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
                                    data += " " + UNTIL.format( oObj.suspend_until_formatted );
                                }
                                data += "</p>";
                            }

                            if ( oObj.barcode ) {
                                data += "<em>";
                                if ( oObj.found == "W" ) {
                                    data += ITEM_IS_WAITING;

                                    if ( ! oObj.waiting_here ) {
                                        data += " " + AT.format( oObj.waiting_at );
                                    }
                                } else if ( oObj.transferred ) {
                                    data += ITEM_IS_IN_TRANSIT.format( oObj.from_branch, oObj.date_sent );
                                } else if ( oObj.not_transferred ) {
                                    data += NOT_TRANSFERRED_YET.format( oObj.not_transferred_by );
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
                "sAjaxSource": '/cgi-bin/koha/svc/holds',
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
    }
});
