$(document).ready(function() {

    // Illview Datatable setup

    var table;

    // Filters that are active
    var activeFilters = {};

    // Get any prefilters
    var prefilters = $('table#ill-requests').data('prefilters');

    // Fields we need to expand (flatten)
    var expand = [
        'metadata',
        'patron',
        'library'
    ];

    // Expanded fields
    // This is auto populated
    var expanded = {};

    // Filterable columns
    var filterable = {
        status: {
            prep: function(tableData, oData) {
                var uniques = {};
                tableData.forEach(function(row) {
                    var resolvedName;
                    if (row.status_alias) {
                        resolvedName = row.status_alias.lib;
                    } else {
                        resolvedName = getStatusName(
                            row.capabilities[row.status].name,
                            row
                        );
                    }
                    uniques[resolvedName] = 1
                });
                Object.keys(uniques).sort().forEach(function(unique) {
                    $('#illfilter_status').append(
                        '<option value="' + unique  +
                        '">' + unique +  '</option>'
                    );
                });
            },
            listener: function() {
                var me = 'status';
                $('#illfilter_status').change(function() {
                    var sel = $('#illfilter_status option:selected').val();
                    if (sel && sel.length > 0) {
                        activeFilters[me] = function() {
                            table.api().column(13).search(sel);
                        }
                    } else {
                        if (activeFilters.hasOwnProperty(me)) {
                            delete activeFilters[me];
                        }
                    }
                });
            },
            clear: function() {
                $('#illfilter_status').val('');
            }
        },
        pickupBranch: {
            prep: function(tableData, oData) {
                var uniques = {};
                tableData.forEach(function(row) {
                    uniques[row.library_branchname] = 1
                });
                Object.keys(uniques).sort().forEach(function(unique) {
                    $('#illfilter_branchname').append(
                        '<option value="' + unique  +
                        '">' + unique +  '</option>'
                    );
                });
            },
            listener: function() {
                var me = 'pickupBranch';
                $('#illfilter_branchname').change(function() {
                    var sel = $('#illfilter_branchname option:selected').val();
                    if (sel && sel.length > 0) {
                        activeFilters[me] = function() {
                            table.api().column(12).search(sel);
                        }
                    } else {
                        if (activeFilters.hasOwnProperty(me)) {
                            delete activeFilters[me];
                        }
                    }
                });
            },
            clear: function() {
                $('#illfilter_branchname').val('');
            }
        },
        patron: {
            listener: function() {
                var me = 'patron';
                $('#illfilter_patron').change(function() {
                    var val = $('#illfilter_patron').val();
                    if (val && val.length > 0) {
                        activeFilters[me] = function() {
                            table.api().column(10).search(val);
                        }
                    } else {
                        if (activeFilters.hasOwnProperty(me)) {
                            delete activeFilters[me];
                        }
                    }
                });
            },
            clear: function() {
                $('#illfilter_patron').val('');
            }
        },
        keyword: {
            listener: function () {
                var me = 'keyword';
                $('#illfilter_keyword').change(function () {
                    var val = $('#illfilter_keyword').val();
                    if (val && val.length > 0) {
                        activeFilters[me] = function () {
                            table.api().search(val);
                        }
                    } else {
                        if (activeFilters.hasOwnProperty(me)) {
                            delete activeFilters[me];
                        }
                    }
                });
            },
            clear: function () {
                $('#illfilter_keyword').val('');
            }
        },
        dateModified: {
            clear: function() {
                $('#illfilter_datemodified_start, #illfilter_datemodified_end').val('');
            }
        },
        datePlaced: {
            clear: function() {
                $('#illfilter_dateplaced_start, #illfilter_dateplaced_end').val('');
            }
        }
    }; //END Filterable columns

    // Expand any fields we're expanding
    var expandExpand = function(row) {
        expand.forEach(function(thisExpand) {
            if (row.hasOwnProperty(thisExpand)) {
                if (!expanded.hasOwnProperty(thisExpand)) {
                    expanded[thisExpand] = [];
                }
                var expandObj = row[thisExpand];
                Object.keys(expandObj).forEach(
                    function(thisExpandCol) {
                        var expColName = thisExpand + '_' + thisExpandCol.replace(/\s/g,'_');
                        // Keep a list of fields that have been expanded
                        // so we can create toggle links for them
                        if (expanded[thisExpand].indexOf(expColName) == -1) {
                            expanded[thisExpand].push(expColName);
                        }
                        expandObj[expColName] =
                            expandObj[thisExpandCol];
                        delete expandObj[thisExpandCol];
                    }
                );
                $.extend(true, row, expandObj);
                delete row[thisExpand];
            }
        });
    };
    //END Expand

    // Strip the expand prefix if it exists, we do this for display
    var stripPrefix = function(value) {
        expand.forEach(function(thisExpand) {
            var regex = new RegExp(thisExpand + '_', 'g');
            value = value.replace(regex, '');
        });
        return value;
    };

    // Our 'render' function for borrowerlink
    var createPatronLink = function(data, type, row) {
        var patronLink = '<a title="' + ill_borrower_details + '" ' +
            'href="/cgi-bin/koha/members/moremember.pl?' +
            'borrowernumber='+row.borrowernumber+'">';
        if ( row.patron_firstname ) {
            patronLink = patronLink + row.patron_firstname + ' ';
        }
        patronLink = patronLink + row.patron_surname +
            ' (' + row.patron_cardnumber + ')' + '</a>';
        return patronLink;
    };

    // Our 'render' function for biblio_id
    var createBiblioLink = function(data, type, row) {
        return (row.biblio_id) ?
            '<a title="' + ill_biblio_details + '" ' +
            'href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=' +
            row.biblio_id + '">' +
            row.biblio_id +
            '</a>' : '';
    };

    // Our 'render' function for title
    var createTitle = function(data, type, row) {
        return (
            row.hasOwnProperty('metadata_container_title') &&
            row.metadata_container_title
        ) ? row.metadata_container_title : row.metadata_title;
    };

    // Render function for request ID
    var createRequestId = function(data, type, row) {
        return row.id_prefix + row.illrequest_id;
    };

    // Render function for type
    var createType = function(data, type, row) {
        if (!row.hasOwnProperty('metadata_Type') || !row.metadata_Type) {
            if (row.hasOwnProperty('medium') && row.medium) {
                row.metadata_Type = row.medium;
            } else {
                row.metadata_Type = null;
            }
        }
        return row.metadata_Type;
    };

    // Render function for request status
    var createStatus = function(data, type, row, meta) {
        if (row.status_alias) {
            return row.status_alias.lib
                ? row.status_alias.lib
                : row.status_alias.authorised_value;
        } else {
            var status_name = row.capabilities[row.status].name;
            return getStatusName(status_name, row);
        }
    };

    var getStatusName = function(origName, row) {
        switch( origName ) {
            case "New request":
                return ill_statuses.new;
            case "Requested":
                return ill_statuses.req;
            case "Requested from partners":
                var statStr = ill_statuses.genreq;
                if (
                    row.hasOwnProperty('requested_partners') &&
                    row.requested_partners &&
                    row.requested_partners.length > 0
                ) {
                    statStr += ' (' + row.requested_partners + ')';
                }
                return statStr;
            case "Request reverted":
                return ill_statuses.rev;
            case "Queued request":
                return ill_statuses.que;
            case "Cancellation requested":
                return ill_statuses.canc;
            case "Completed":
                return ill_statuses.comp;
            case "Delete request":
                return ill_statuses.del;
            default:
                return origName;
        }
    };

    // Render function for creating a row's action link
    var createActionLink = function(data, type, row) {
        return '<a class="btn btn-default btn-sm" ' +
            'href="/cgi-bin/koha/ill/ill-requests.pl?' +
            'method=illview&amp;illrequest_id=' +
            row.illrequest_id +
            '">' + ill_manage + '</a>';
    };

    // Columns that require special treatment
    var specialCols = {
        action: {
            func: createActionLink,
            skipSanitize: true
        },
        illrequest_id: {
            func: createRequestId
        },
        status: {
            func: createStatus
        },
        biblio_id: {
            name: ill_columns.biblio_id,
            func: createBiblioLink,
            skipSanitize: true
        },
        metadata_title: {
            func: createTitle
        },
        metadata_Type: {
            func: createType
        },
        updated: {
            name: ill_columns.updated
        },
        patron: {
            skipSanitize: true,
            func: createPatronLink
        }
    };

    // Display the modal containing request supplier metadata
    $('#ill-request-display-log').on('click', function(e) {
        e.preventDefault();
        $('#requestLog').modal({show:true});
    });

    // Toggle request attributes in Illview
    $('#toggle_requestattributes').on('click', function(e) {
        e.preventDefault();
        $('#requestattributes').toggleClass('content_hidden');
    });

    // Toggle new comment form in Illview
    $('#toggle_addcomment').on('click', function(e) {
        e.preventDefault();
        $('#addcomment').toggleClass('content_hidden');
    });

    // Filter partner list
    // Record the list of all options
    var ill_partner_options = $('#partners > option');
    $('#partner_filter').keyup(function() {
        var needle = $('#partner_filter').val();
        var regex = new RegExp(needle, 'i');
        var filtered = [];
        ill_partner_options.each(function() {
            if (
                needle.length == 0 ||
                $(this).is(':selected') ||
                $(this).text().match(regex)
            ) {
                filtered.push($(this));
            }
        });
        $('#partners').empty().append(filtered);
    });

    // Display the modal containing request supplier metadata
    $('#ill-request-display-metadata').on('click', function(e) {
        e.preventDefault();
        $('#dataPreview').modal({show:true});
    });

    // Allow us to chain Datatable render helpers together, so we
    // can use our custom functions and render.text(), which
    // provides us with data sanitization
    $.fn.dataTable.render.multi = function(renderArray) {
        return function(d, type, row, meta) {
            for(var r = 0; r < renderArray.length; r++) {
                var toCall = renderArray[r].hasOwnProperty('display') ?
                    renderArray[r].display :
                    renderArray[r];
                d = toCall(d, type, row, meta);
            }
            return d;
        }
    }

    // Get our data from the API and process it prior to passing
    // it to datatables
    var filterParam = prefilters ? '&' + prefilters : '';
    // Only fire the request if we're on an appropriate page
    if (
        (
            // ILL list requests page
            window.location.href.match(/ill\/ill-requests\.pl/) &&
            window.location.search.length == 0
        ) ||
        // Patron profile page
        window.location.href.match(/members\/ill-requests\.pl/)
    ) {
        var ajax = $.ajax(
            '/api/v1/illrequests?embed=metadata,patron,capabilities,library,status_alias,comments,requested_partners'
            + filterParam
        ).done(function() {
            var data = JSON.parse(ajax.responseText);
            // Make a copy, we'll be removing columns next and need
            // to be able to refer to data that has been removed
            var dataCopy = $.extend(true, [], data);
            // Expand columns that need it and create an array
            // of all column names
            $.each(dataCopy, function(k, row) {
                expandExpand(row);
            });

            // Assemble an array of column definitions for passing
            // to datatables
            var colData = [];
            columns_settings.forEach(function(thisCol) {
                var colName = thisCol.columnname;
                // Create the base column object
                var colObj = $.extend({}, thisCol);
                colObj.name = colName;
                colObj.className = colName;
                colObj.defaultContent = '';

                // We may need to process the data going in this
                // column, so do it if necessary
                if (
                    specialCols.hasOwnProperty(colName) &&
                    specialCols[colName].hasOwnProperty('func')
                ) {
                    var renderArray = [
                        specialCols[colName].func
                    ];
                    if (!specialCols[colName].skipSanitize) {
                        renderArray.push(
                            $.fn.dataTable.render.text()
                        );
                    }

                    colObj.render = $.fn.dataTable.render.multi(
                        renderArray
                    );
                } else {
                    colObj.data = colName;
                    colObj.render = $.fn.dataTable.render.text()
                }
                // Make sure properties that aren't present in the API
                // response are populated with null to avoid Datatables
                // choking on their absence
                dataCopy.forEach(function(thisData) {
                    if (!thisData.hasOwnProperty(colName)) {
                        thisData[colName] = null;
                    }
                });
                colData.push(colObj);
            });

            // Initialise the datatable
            table = KohaTable("ill-requests", {
                'aoColumnDefs': [
                    { // Last column shouldn't be sortable or searchable
                        'aTargets': [ 'actions' ],
                        'bSortable': false,
                        'bSearchable': false
                    },
                    { // When sorting 'placed', we want to use the
                        // unformatted column
                        'aTargets': [ 'placed_formatted'],
                        'iDataSort': 14
                    },
                    { // When sorting 'updated', we want to use the
                        // unformatted column
                        'aTargets': [ 'updated_formatted'],
                        'iDataSort': 16
                    },
                    { // When sorting 'completed', we want to use the
                        // unformatted column
                        'aTargets': [ 'completed_formatted'],
                        'iDataSort': 19
                    }
                ],
                'aaSorting': [[ 16, 'desc' ]], // Default sort, updated descending
                'processing': true, // Display a message when manipulating
                'sPaginationType': "full_numbers", // Pagination display
                'deferRender': true, // Improve performance on big datasets
                'data': dataCopy,
                "dom": '<"top pager"<"table_entries"ilp><"table_controls"B>>tr<"bottom pager"ip>',
                'columns': colData,
                'originalData': data, // Enable render functions to access
                                        // our original data
                'initComplete': function() {

                    // Prepare any filter elements that need it
                    for (var el in filterable) {
                        if (filterable.hasOwnProperty(el)) {
                            if (filterable[el].hasOwnProperty('prep')) {
                                filterable[el].prep(dataCopy, data);
                            }
                            if (filterable[el].hasOwnProperty('listener')) {
                                filterable[el].listener();
                            }
                        }
                    }

                }
            }, columns_settings);

            // Custom date range filtering
            $.fn.dataTable.ext.search.push(function(settings, data, dataIndex) {
                var placedStart = $('#illfilter_dateplaced_start').get(0)._flatpickr.selectedDates[0];
                var placedEnd = $('#illfilter_dateplaced_end').get(0)._flatpickr.selectedDates[0];
                var modifiedStart = $('#illfilter_datemodified_start').get(0)._flatpickr.selectedDates[0];
                var modifiedEnd = $('#illfilter_datemodified_end').get(0)._flatpickr.selectedDates[0];
                var rowPlaced = data[14] ? new Date(data[14]) : null;
                var rowModified = data[16] ? new Date(data[16]) : null;
                var placedPassed = true;
                var modifiedPassed = true;
                if (placedStart && rowPlaced && rowPlaced < placedStart) {
                    placedPassed = false
                };
                if (placedEnd && rowPlaced && rowPlaced > placedEnd) {
                    placedPassed = false;
                }
                if (modifiedStart && rowModified && rowModified < modifiedStart) {
                    modifiedPassed = false
                };
                if (modifiedEnd && rowModified && rowModified > modifiedEnd) {
                    modifiedPassed = false;
                }

                return placedPassed && modifiedPassed;

            });

        });
    } //END if window.location.search.length == 0

    var clearSearch = function() {
        table.api().search('').columns().search('');
        activeFilters = {};
        for (var filter in filterable) {
            if (
                filterable.hasOwnProperty(filter) &&
                filterable[filter].hasOwnProperty('clear')
            ) {
                filterable[filter].clear();
            }
        }
        table.api().draw();
    };

    // Apply any search filters, or clear any previous
    // ones
    $('#illfilter_form').submit(function(event) {
        event.preventDefault();
        table.api().search('').columns().search('');
        for (var active in activeFilters) {
            if (activeFilters.hasOwnProperty(active)) {
                activeFilters[active]();
            }
        }
        table.api().draw();
    });

    // Clear all filters
    $('#clear_search').click(function() {
        clearSearch();
    });

});
