(function () {
    var table;
    var batchesProxy;

    window.addEventListener('load', onload);

    function onload() {
        // Only proceed if appropriate
        if (!document.getElementById('ill-batch-requests')) return;

        // A proxy that will give us some element of reactivity to
        // changes in our list of batches
        batchesProxy = new Proxy(
            { data: [] },
            {
                get: function (obj, prop) {
                    return obj[prop];
                },
                set: function (obj, prop, value) {
                    obj[prop] = value;
                    updateTable();
                }
            }
        );

        // Initialise the Datatable, binding it to our proxy object
        table = initTable();

        // Do the initial data population
        window.doBatchApiRequest('', {
                headers: {
                    'x-koha-embed': '+strings,requests+count,patron'
                }
            })
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {
                batchesProxy.data = data;
            });

        // Clean up any event listeners we added
        window.addEventListener('beforeunload', removeEventListeners);
    };

    // Initialise the Datatable
    // FIXME: This should be a kohaTable not KohaTable
    var initTable = function () {
        return KohaTable("ill-batch-requests", {
            data: batchesProxy.data,
            columns: [
                {
                    data: 'ill_batch_id',
                    width: '10%'
                },
                {
                    data: 'name',
                    render: createName,
                    width: '30%'
                },
                {
                    data: 'requests_count',
                    width: '10%'
                },
                {
                    data: 'status',
                    render: createStatus,
                    width: '10%'
                },
                {
                    data: 'patron',
                    render: createPatronLink,
                    width: '10%'
                },
                {
                    data: 'branch',
                    render: createBranch,
                    width: '20%'
                },
                {
                    render: createActions,
                    width: '10%',
                    orderable: false,
                    className: 'noExport'
                }
            ],
            processing: true,
            deferRender: true,
            drawCallback: addEventListeners
        });
    }

    // A render function for branch name
    var createBranch = function (x, y, data) {
        return data._strings.library_id.str;
    };

    // A render function for batch name
    var createName = function (x, y, data) {
        var a = document.createElement('a');
        a.setAttribute('href', '/cgi-bin/koha/ill/ill-requests.pl?batch_id=' + data.ill_batch_id);
        a.setAttribute('title', data.name);
        a.textContent = data.name;
        return a.outerHTML;
    };

    // A render function for batch status
    var createStatus = function (x, y, data) {
        return data._strings.status_code.str;
    };

    // A render function for our patron link
    var createPatronLink = function (data) {
        return data ? $patron_to_html(data, { display_cardnumber: true, url: true }) : '';
    };

    // A render function for our row action buttons
    var createActions = function (data, type, row) {
        var div = document.createElement('div');
        div.setAttribute('class', 'action-buttons');

        var editButton = document.createElement('button');
        editButton.setAttribute('type', 'button');
        editButton.setAttribute('class', 'editButton btn btn-xs btn-default');
        editButton.setAttribute('data-batch-id', row.ill_batch_id);
        editButton.appendChild(document.createTextNode(ill_batch_edit));

        var deleteButton = document.createElement('button');
        deleteButton.setAttribute('type', 'button');
        deleteButton.setAttribute('class', 'deleteButton btn btn-xs btn-danger');
        deleteButton.setAttribute('data-batch-id', row.ill_batch_id);
        deleteButton.appendChild(document.createTextNode(ill_batch_delete));

        div.appendChild(editButton);
        div.appendChild(deleteButton);

        return div.outerHTML;
    };

    // Add event listeners to our row action buttons
    var addEventListeners = function () {
        var del = document.querySelectorAll('.deleteButton');
        del.forEach(function (el) {
            el.addEventListener('click', handleDeleteClick);
        });

        var edit = document.querySelectorAll('.editButton');
        edit.forEach(function (elEdit) {
            elEdit.addEventListener('click', handleEditClick);
        });
    };

    // Remove all added event listeners
    var removeEventListeners = function () {
        var del = document.querySelectorAll('.deleteButton');
        del.forEach(function (el) {
            el.removeEventListener('click', handleDeleteClick);
        });
        window.removeEventListener('load', onload);
        window.removeEventListener('beforeunload', removeEventListeners);
    };

    // Handle "Delete" clicks
    var handleDeleteClick = function(e) {
        var el = e.srcElement;
        if (confirm(ill_batch_confirm_delete)) {
            deleteBatch(el);
        }
    };

    // Handle "Edit" clicks
    var handleEditClick = function(e) {
        var el = e.srcElement;
        var id = el.dataset.batchId;
        window.openBatchModal(id);
    };

    // Delete a batch
    // - Make the API call
    // - Handle errors
    // - Update our proxy data
    var deleteBatch = function (el) {
        var id = el.dataset.batchId;
        doBatchApiRequest(
            '/' + id,
            { method: 'DELETE' }
        )
        .then(function (response) {
            if (!response.ok) {
                window.handleApiError(ill_batch_delete_fail);
            } else {
                removeBatch(el.dataset.batchId);
            }
        })
        .catch(function (response) {
            window.handleApiError(ill_batch_delete_fail);
        })
    };

    // Remove a batch from our proxy data
    var removeBatch = function(id) {
        batchesProxy.data = batchesProxy.data.filter(function (batch) {
            return batch.ill_batch_id != id;
        });
    };

    // Redraw the table
    var updateTable = function () {
        table.api()
            .clear()
            .rows.add(batchesProxy.data)
            .draw();
    };

})();
