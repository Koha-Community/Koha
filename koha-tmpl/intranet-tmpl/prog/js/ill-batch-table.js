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
        window.doBatchApiRequest()
            .then(function (response) {
                return response.json();
            })
            .then(function (data) {
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
                    data: 'id',
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
                    orderable: false
                }
            ],
            processing: true,
            deferRender: true,
            drawCallback: addEventListeners
        });
    }

    // A render function for branch name
    var createBranch = function (data) {
        return data.branchname;
    };

    // A render function for batch name
    var createName = function (x, y, data) {
        var a = document.createElement('a');
        a.setAttribute('href', '/cgi-bin/koha/ill/ill-requests.pl?batch_id=' + data.id);
        a.setAttribute('title', data.name);
        a.textContent = data.name;
        return a.outerHTML;
    };

    // A render function for batch status
    var createStatus = function (x, y, data) {
        return data.status.name;
    };

    // A render function for our patron link
    var createPatronLink = function (data) {
        var link = document.createElement('a');
        link.setAttribute('title', ill_batch_borrower_details);
        link.setAttribute('href', '/cgi-bin/koha/members/moremember.pl?borrowernumber=' + data.borrowernumber);
        var displayText = [data.firstname, data.surname].join(' ') + ' ( ' + data.cardnumber + ' )';
        link.appendChild(document.createTextNode(displayText));

        return link.outerHTML;
    };

    // A render function for our row action buttons
    var createActions = function (data, type, row) {
        var div = document.createElement('div');
        div.setAttribute('class', 'action-buttons');

        var editButton = document.createElement('button');
        editButton.setAttribute('type', 'button');
        editButton.setAttribute('class', 'editButton btn btn-xs btn-default');
        editButton.setAttribute('data-batch-id', row.id);
        editButton.appendChild(document.createTextNode(ill_batch_edit));

        var deleteButton = document.createElement('button');
        deleteButton.setAttribute('type', 'button');
        deleteButton.setAttribute('class', 'deleteButton btn btn-xs btn-danger');
        deleteButton.setAttribute('data-batch-id', row.id);
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
            return batch.id != id;
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
