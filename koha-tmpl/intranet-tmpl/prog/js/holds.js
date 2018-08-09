$(document).ready(function() {
    var holdsTable;

    // Don't load holds table unless it is clicked on
    $("#holds-tab").on( "click", function(){ load_holds_table() } );

    // If the holds tab is preselected on load, we need to load the table
    if ( $("#holds-tab").parent().hasClass('ui-state-active') ) { load_holds_table() }

    function load_holds_table() {
        var holds = new Array();
        if ( ! holdsTable ) {
            holdsTable = $("#holds-table").dataTable({
                "bAutoWidth": false,
                "sDom": "rt",
                "columns": [
                    {
                        "mDataProp": "reservedate_formatted"
                    },
                    {
                        "mDataProp": function ( oObj ) {
                            title = "<a href='/cgi-bin/koha/reserve/request.pl?biblionumber="
                                  + oObj.biblionumber
                                  + "'>"
                                  + oObj.title.escapeHtml();

                            $.each(oObj.subtitle, function( index, value ) {
                                      title += " " + value.subfield.escapeHtml();
                            });

                            title += "</a>";

                            if ( oObj.author ) {
                                title += " " + BY.replace( "_AUTHOR_",  oObj.author.escapeHtml() );
                            }

                            if ( oObj.itemnotes ) {
                                var span_class = "";
                                if ( $.datepicker.formatDate('yy-mm-dd', new Date(oObj.issuedate) ) == ymd ) {
                                    span_class = "circ-hlt";
                                }
                                title += " - <span class='" + span_class + "'>" + oObj.itemnotes.escapeHtml() + "</span>"
                            }

                            return title;
                        }
                    },
                    {
                        "mDataProp": function( oObj ) {
                            return oObj.itemcallnumber.escapeHtml() || "";
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

                            if ( oObj.itemtype_limit ) {
                                data += NEXT_AVAILABLE_ITYPE.format( oObj.itemtype_limit );
                            }

                            if ( oObj.barcode ) {
                                data += "<em>";
                                if ( oObj.found == "W" ) {

                                    if ( oObj.waiting_here ) {
                                        data += ITEM_IS_WAITING_HERE;
                                    } else {
                                        data += ITEM_IS_WAITING;
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
                                  + oObj.barcode.escapeHtml()
                                  + "</a>";
                            }

                            return data;
                        }
                    },
                    {
                        "mDataProp": function( oObj ) {
                            if( oObj.branches.length > 1 && oObj.found !== 'W' && oObj.found !== 'T' ){
                                var branchSelect='<select priority='+oObj.priority+' class="hold_location_select" reserve_id="'+oObj.reserve_id+'" name="pick-location">';
                                for ( var i=0; i < oObj.branches.length; i++ ){
                                    var selectedbranch;
                                    var setbranch;
                                    if( oObj.branches[i].selected ){

                                        selectedbranch = " selected='selected' ";
                                        setbranch = CURRENT;
                                    }
                                    else{
                                        selectedbranch = '';
                                        setbranch = '';
                                    }
                                    branchSelect += '<option value="'+ oObj.branches[i].branchcode.escapeHtml() +'"'+selectedbranch+'>'+oObj.branches[i].branchname.escapeHtml()+setbranch+'</option>';
                                }
                                branchSelect +='</select>';
                                return branchSelect;
                            }
                            else { return oObj.branchcode.escapeHtml() || ""; }
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
                    },
                    {
                        "bSortable": false,
                        "mDataProp": function( oObj ) {
                            holds[oObj.reserve_id] = oObj; //Store holds for later use

                            if ( oObj.found ) {
                                return "";
                            } else if ( oObj.suspend == 1 ) {
                                return "<a class='hold-resume btn btn-default btn-xs' id='resume" + oObj.reserve_id + "'>"
                                     + "<i class='fa fa-play'></i> " + RESUME + "</a>";
                            } else {
                                return "<a class='hold-suspend btn btn-default btn-xs' id='suspend" + oObj.reserve_id + "'>"
                                     + "<i class='fa fa-pause'></i> " + SUSPEND + "</a>";
                            }
                        }
                    }
                ],
                "bPaginate": false,
                "bProcessing": true,
                "bServerSide": false,
                "ajax": {
                    "url": '/cgi-bin/koha/svc/holds',
                    "data": function ( d ) {
                        d.borrowernumber = borrowernumber;
                    }
                },
            });

            $('#holds-table').on( 'draw.dt', function () {
                $(".hold-suspend").on( "click", function() {
                    var id = $(this).attr("id").replace("suspend", "");
                    var hold = holds[id];
                    $("#suspend-modal-title").html( hold.title );
                    $("#suspend-modal-reserve_id").val( hold.reserve_id );
                    $('#suspend-modal').modal('show');
                });

                $(".hold-resume").on( "click", function() {
                    var id = $(this).attr("id").replace("resume", "");
                    var hold = holds[id];
                    $.post('/cgi-bin/koha/svc/hold/resume', { "reserve_id": hold.reserve_id }, function( data ){
                      if ( data.success ) {
                          holdsTable.api().ajax.reload();
                      } else {
                        if ( data.error == "HOLD_NOT_FOUND" ) {
                            alert ( RESUME_HOLD_ERROR_NOT_FOUND );
                            holdsTable.api().ajax.reload();
                        }
                      }
                    });
                });

                $(".hold_location_select").change(function(){
                    $(this).prop("disabled",true);
                    var cur_select = $(this);
                    var res_id = $(this).attr('reserve_id');
                    $(this).after('<div id="updating_reserveno'+res_id+'" class="waiting"><img src="/intranet-tmpl/prog/img/spinner-small.gif" alt="" /><span class="waiting_msg"></span></div>');
                    var api_url = '/api/v1/holds/'+res_id;
                    var update_info = JSON.stringify({ branchcode: $(this).val(), priority: parseInt($(this).attr("priority"),10) });
                    $.ajax({
                        method: "PUT",
                        url: api_url,
                        data: update_info ,
                        success: function( data ){ holdsTable.api().ajax.reload(); },
                        error: function( jqXHR, textStatus, errorThrown) {
                            alert('There was an error:'+textStatus+" "+errorThrown);
                            cur_select.prop("disabled",false);
                            $("#updating_reserveno"+res_id).remove();
                            cur_select.val( cur_select.children('option[selected="selected"]').val() );
                        },
                    });
                });

            });

            if ( $("#holds-table").length ) {
                $("#holds-table_processing").position({
                    of: $( "#holds-table" ),
                    collision: "none"
                });
            }
        }
    }

    $("body").append("\
        <div id='suspend-modal' class='modal fade' tabindex='-1' role='dialog' aria-hidden='true'>\
            <div class='modal-dialog'>\
            <div class='modal-content'>\
            <form id='suspend-modal-form' class='form-inline'>\
                <div class='modal-header'>\
                    <button type='button' class='closebtn' data-dismiss='modal' aria-hidden='true'>×</button>\
                    <h3 id='suspend-modal-label'>" + SUSPEND_HOLD_ON + " <i><span id='suspend-modal-title'></span></i></h3>\
                </div>\
\
                <div class='modal-body'>\
                    <input type='hidden' id='suspend-modal-reserve_id' name='reserve_id' />\
\
                    <label for='suspend-modal-until'>" + SUSPEND_UNTIL + "</label>\
                    <input name='suspend_until' id='suspend-modal-until' class='suspend-until' size='10' />\
\
                    <p/><a class='btn btn-link' id='suspend-modal-clear-date' >" + CLEAR_DATE_TO_SUSPEND_INDEFINITELY + "</a></p>\
\
                </div>\
\
                <div class='modal-footer'>\
                    <button id='suspend-modal-submit' class='btn btn-primary' type='submit' name='submit'>" + SUSPEND + "</button>\
                    <a href='#' data-dismiss='modal' aria-hidden='true' class='cancel'>" + CANCEL + "</a>\
                </div>\
            </form>\
            </div>\
            </div>\
        </div>\
    ");

    $("#suspend-modal-until").datepicker({ minDate: 1 }); // Require that "until date" be in the future
    $("#suspend-modal-clear-date").on( "click", function() { $("#suspend-modal-until").val(""); } );

    $("#suspend-modal-submit").on( "click", function( e ) {
        e.preventDefault();
        $.post('/cgi-bin/koha/svc/hold/suspend', $('#suspend-modal-form').serialize(), function( data ){
          $('#suspend-modal').modal('hide');
          if ( data.success ) {
              holdsTable.api().ajax.reload();
          } else {
            if ( data.error == "INVALID_DATE" ) {
                alert( SUSPEND_HOLD_ERROR_DATE );
            }
            else if ( data.error == "HOLD_NOT_FOUND" ) {
                alert ( SUSPEND_HOLD_ERROR_NOT_FOUND );
                holdsTable.api().ajax.reload();
            }
          }
        });
    });

});
