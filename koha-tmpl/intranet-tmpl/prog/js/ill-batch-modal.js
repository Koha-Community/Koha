(function () {
    // Bail if there aren't any metadata enrichment plugins installed
    if (typeof metadata_enrichment_services === 'undefined') {
        console.log('No metadata enrichment plugins found.')
        return;
    }

    window.addEventListener('load', onload);

    // Delay between API requests
    var debounceDelay = 1000;

    // Elements we work frequently with
    var textarea = document.getElementById("identifiers_input");
    var nameInput = document.getElementById("name");
    var cardnumberInput = document.getElementById("batchcardnumber");
    var branchcodeSelect = document.getElementById("branchcode");
    var processButton = document.getElementById("process_button");
    var createButton = document.getElementById("button_create_batch");
    var finishButton = document.getElementById("button_finish");
    var batchItemsDisplay = document.getElementById("add_batch_items");
    var createProgressTotal = document.getElementById("processed_total");
    var createProgressCount = document.getElementById("processed_count");
    var createProgressFailed = document.getElementById("processed_failed");
    var createProgressBar = document.getElementById("processed_progress_bar");
    var identifierTable = document.getElementById('identifier-table');
    var createRequestsButton = document.getElementById('create-requests-button');
    var statusesSelect = document.getElementById('status_code');
    var cancelButton = document.getElementById('lhs').querySelector('button');
    var cancelButtonOriginalText = cancelButton.innerHTML;

    // We need a data structure keyed on identifier type, which tells us how to parse that
    // identifier type and what services can get its metadata. We receive an array of
    // available services
    var supportedIdentifiers = {};
    metadata_enrichment_services.forEach(function (service) {
        // Iterate the identifiers that this service supports
        Object.keys(service.identifiers_supported).forEach(function (idType) {
            if (!supportedIdentifiers[idType]) {
                supportedIdentifiers[idType] = [];
            }
            supportedIdentifiers[idType].push(service);
        });
    });

    // An object for when we're creating a new batch
    var emptyBatch = {
        name: '',
        backend: null,
        cardnumber: '',
        branchcode: '',
        status_code: 'NEW'
    };

    // The object that holds the batch we're working with
    // It's a proxy so we can update portions of the UI
    // upon changes
    var batch = new Proxy(
        { data: {} },
        {
            get: function (obj, prop) {
                return obj[prop];
            },
            set: function (obj, prop, value) {
                obj[prop] = value;
                manageBatchItemsDisplay();
                updateBatchInputs();
                disableCardnumberInput();
                displayPatronName();
                updateStatusesSelect();
            }
        }
    );

    // The object that holds the contents of the table
    // It's a proxy so we can make it automatically redraw the
    // table upon changes
    var tableContent = new Proxy(
        { data: [] },
        {
            get: function (obj, prop) {
                return obj[prop];
            },
            set: function (obj, prop, value) {
                obj[prop] = value;
                updateTable();
                updateRowCount();
                updateProcessTotals();
                checkAvailability();
            }
        }
    );

    // The object that holds the contents of the table
    // It's a proxy so we can update portions of the UI
    // upon changes
    var statuses = new Proxy(
        { data: [] },
        {
            get: function (obj, prop) {
                return obj[prop];
            },
            set: function (obj, prop, value) {
                obj[prop] = value;
                updateStatusesSelect();
            }
        }
    );

    var progressTotals = new Proxy(
        {
            data: {}
        },
        {
            get: function (obj, prop) {
                return obj[prop];
            },
            set: function (obj, prop, value) {
                obj[prop] = value;
                showCreateRequestsButton();
            }
        }
    );

    // Keep track of submission API calls that are in progress
    // so we don't duplicate them
    var submissionSent = {};

    // Keep track of availability API calls that are in progress
    // so we don't duplicate them
    var availabilitySent = {};

    // Are we updating an existing batch
    var isUpdate = false;

    // The datatable
    var table;
    var tableEl = document.getElementById('identifier-table');

    // The element that potentially holds the ID of the batch
    // we're working with
    var idEl = document.getElementById('ill-batch-details');
    var batchId = null;
    var backend = null;

    function onload() {
        $('#ill-batch-modal').on('shown.bs.modal', function () {
            init();
            patronAutocomplete();
            batchInputsEventListeners();
            createButtonEventListener();
            createRequestsButtonEventListener();
            moreLessEventListener();
            removeRowEventListener();
        });
        $('#ill-batch-modal').on('hidden.bs.modal', function () {
            // Reset our state when we close the modal
            // TODO: need to also reset progress bar and already processed identifiers
            delete idEl.dataset.batchId;
            delete idEl.dataset.backend;
            batchId = null;
            tableEl.style.display = 'none';
            tableContent.data = [];
            progressTotals.data = {
                total: 0,
                count: 0,
                failed: 0
            };
            textarea.value = '';
            batch.data = {};
            cancelButton.innerHTML = cancelButtonOriginalText;
            // Remove event listeners we created
            removeEventListeners();
        });
    };

    function init() {
        batchId = idEl.dataset.batchId;
        backend = idEl.dataset.backend;
        emptyBatch.backend = backend;
        progressTotals.data = {
            total: 0,
            count: 0,
            failed: 0
        };
        if (batchId) {
            fetchBatch();
            isUpdate = true;
            setModalHeading();
        } else {
            batch.data = emptyBatch;
            setModalHeading();
        }
        fetchStatuses();
        finishButtonEventListener();
        processButtonEventListener();
        identifierTextareaEventListener();
        displaySupportedIdentifiers();
        createButtonEventListener();
        updateRowCount();
    };

    function initPostCreate() {
        disableCreateButton();
        cancelButton.innerHTML = ill_batch_create_cancel_button;
    };

    function setFinishButton() {
        if (batch.data.patron) {
            finishButton.removeAttribute('disabled');
        }
    };

    function setModalHeading() {
        var heading = document.getElementById('ill-batch-modal-label');
        heading.textContent = isUpdate ? ill_batch_update : ill_batch_add;
    }

    // Identify items that have metadata and therefore can have a local request
    // created, and do so
    function requestRequestable() {
        createRequestsButton.setAttribute('disabled', true);
        createRequestsButton.setAttribute('aria-disabled', true);
        setFinishButton();
        var toCheck = tableContent.data;
        toCheck.forEach(function (row) {
            if (
                !row.requestId &&
                Object.keys(row.metadata).length > 0 &&
                !submissionSent[row.value]
            ) {
                submissionSent[row.value] = 1;
                makeLocalSubmission(row.value, row.metadata);
            }
        });
    };

    // Identify items that can have their availability checked, and do it
    function checkAvailability() {
        // Only proceed if we've got services that can check availability
        if (!batch_availability_services || batch_availability_services.length === 0) return;
        var toCheck = tableContent.data;
        toCheck.forEach(function (row) {
            if (
                !row.url &&
                Object.keys(row.metadata).length > 0 &&
                !availabilitySent[row.value]
            ) {
                availabilitySent[row.value] = 1;
                getAvailability(row.value, row.metadata);
            }
        });
    };

    // Check availability services for immediate availability, if found,
    // create a link in the table linking to the item
    function getAvailability(identifier, metadata) {
        // Prep the metadata for passing to the availability plugins
        let availability_object = {};
        if (metadata.issn) availability_object['issn'] = metadata.issn;
        if (metadata.doi) availability_object['doi'] = metadata.doi;
        if (metadata.pubmedid) availability_object['pubmedid'] = metadata.pubmedid;
        var prepped = encodeURIComponent(base64EncodeUnicode(JSON.stringify(availability_object)));
        for (i = 0; i < batch_availability_services.length; i++) {
            var service = batch_availability_services[i];
            window.doApiRequest(
                service.endpoint + prepped
            )
                .then(function (response) {
                    return response.json();
                })
                .then(function (data) {
                    if (data.results.search_results && data.results.search_results.length > 0) {
                        var result = data.results.search_results[0];
                        tableContent.data = tableContent.data.map(function (row) {
                            if (row.value === identifier) {
                                row.url = result.url;
                                row.availabilitySupplier = service.name;
                            }
                            return row;
                        });
                    }
                });
        }
    };

    // Help btoa with > 8 bit strings
    // Shamelessly grabbed from: https://www.base64encoder.io/javascript/
    function base64EncodeUnicode(str) {
        // First we escape the string using encodeURIComponent to get the UTF-8 encoding of the characters,
        // then we convert the percent encodings into raw bytes, and finally feed it to btoa() function.
        utf8Bytes = encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, function(match, p1) {
                return String.fromCharCode('0x' + p1);
        });

        return btoa(utf8Bytes);
    };

    // Create a local submission and update our local state
    // upon success
    function makeLocalSubmission(identifier, metadata) {

        // Prepare extended_attributes in array format for POST
        var extended_attributes = [];
        for (const [key, value] of Object.entries(metadata)) {
            extended_attributes.push({"type":key, "value":value});
        }

        var payload = {
            ill_batch_id: batchId,
            ill_backend_id: batch.data.backend,
            patron_id: batch.data.patron.patron_id,
            library_id: batch.data.library_id,
            extended_attributes: extended_attributes
        };
        window.doCreateSubmission(payload)
            .then(function (response) {
                return response.json();
            })
            .then(function (data) {
                tableContent.data = tableContent.data.map(function (row) {
                    if (row.value === identifier) {
                        row.requestId = data.ill_request_id;
                        row.requestStatus = data.status;
                    }
                    return row;
                });
            })
            .catch(function () {
                window.handleApiError(ill_batch_api_request_fail);
            });
    };

    function updateProcessTotals() {
        var init = {
            total: 0,
            count: 0,
            failed: 0
        };
        progressTotals.data = init;
        var toUpdate = progressTotals.data;
        tableContent.data.forEach(function (row) {
            toUpdate.total++;
            if (Object.keys(row.metadata).length > 0 || row.failed.length > 0) {
                toUpdate.count++;
            }
            if (Object.keys(row.failed).length > 0) {
                toUpdate.failed++;
            }
        });
        createProgressTotal.innerHTML = toUpdate.total;
        createProgressCount.innerHTML = toUpdate.count;
        createProgressFailed.innerHTML = toUpdate.failed;
        var percentDone = Math.ceil((toUpdate.count / toUpdate.total) * 100);
        createProgressBar.setAttribute('aria-valuenow', percentDone);
        createProgressBar.innerHTML = percentDone + '%';
        createProgressBar.style.width = percentDone + '%';
        progressTotals.data = toUpdate;
    };

    function displayPatronName() {
        var span = document.getElementById('patron_link');
        if (batch.data.patron) {
            var link = createPatronLink();
            span.appendChild(link);
        } else {
            if (span.children.length > 0) {
                span.removeChild(span.firstChild);
            }
        }
    };

    function updateStatusesSelect() {
        while (statusesSelect.options.length > 0) {
            statusesSelect.remove(0);
        }
        statuses.data.forEach(function (status) {
            var option = document.createElement('option')
            option.value = status.code;
            option.text = status.name;
            if (batch.data.ill_batch_id && batch.data.status_code === status.code) {
                option.selected = true;
            }
            statusesSelect.add(option);
        });
        if (isUpdate) {
            statusesSelect.parentElement.style.display = 'block';
        }
    };

    function removeEventListeners() {
        textarea.removeEventListener('paste', processButtonState);
        textarea.removeEventListener('keyup', processButtonState);
        processButton.removeEventListener('click', processIdentifiers);
        nameInput.removeEventListener('keyup', createButtonState);
        cardnumberInput.removeEventListener('keyup', createButtonState);
        branchcodeSelect.removeEventListener('change', createButtonState);
        createButton.removeEventListener('click', createBatch);
        identifierTable.removeEventListener('click', toggleMetadata);
        identifierTable.removeEventListener('click', removeRow);
        createRequestsButton.remove('click', requestRequestable);
    };

    function finishButtonEventListener() {
        finishButton.addEventListener('click', doFinish);
    };

    function identifierTextareaEventListener() {
        textarea.addEventListener('paste', textareaUpdate);
        textarea.addEventListener('keyup', textareaUpdate);
    };

    function processButtonEventListener() {
        processButton.addEventListener('click', processIdentifiers);
    };

    function createRequestsButtonEventListener() {
        createRequestsButton.addEventListener('click', requestRequestable);
    };

    function createButtonEventListener() {
        createButton.addEventListener('click', createBatch);
    };

    function batchInputsEventListeners() {
        nameInput.addEventListener('keyup', createButtonState);
        cardnumberInput.addEventListener('keyup', createButtonState);
        branchcodeSelect.addEventListener('change', createButtonState);
    };

    function moreLessEventListener() {
        identifierTable.addEventListener('click', toggleMetadata);
    };

    function removeRowEventListener() {
        identifierTable.addEventListener('click', removeRow);
    };

    function textareaUpdate() {
        processButtonState();
        updateRowCount();
    };

    function processButtonState() {
        if (textarea.value.length > 0) {
            processButton.removeAttribute('disabled');
            processButton.removeAttribute('aria-disabled');
        } else {
            processButton.setAttribute('disabled', true);
            processButton.setAttribute('aria-disabled', true);
        }
    };

    function disableCardnumberInput() {
        if (batch.data.patron) {
            cardnumberInput.setAttribute('disabled', true);
            cardnumberInput.setAttribute('aria-disabled', true);
        } else {
            cardnumberInput.removeAttribute('disabled');
            cardnumberInput.removeAttribute('aria-disabled');
        }
    };

    function createButtonState() {
        if (
            nameInput.value.length > 0 &&
            cardnumberInput.value.length > 0 &&
            branchcodeSelect.selectedOptions.length === 1
        ) {
            createButton.removeAttribute('disabled');
            createButton.setAttribute('display', 'inline-block');
        } else {
            createButton.setAttribute('disabled', 1);
            createButton.setAttribute('display', 'none');
        }
    };

    function doFinish() {
        updateBatch()
            .then(function () {
                $('#ill-batch-modal').modal({ show: false });
                location.href = '/cgi-bin/koha/ill/ill-requests.pl?batch_id=' + batch.data.ill_batch_id;
            });
    };

    // Get all batch statuses
    function fetchStatuses() {
        window.doApiRequest('/api/v1/ill/batchstatuses')
            .then(function (response) {
                return response.json();
            })
            .then(function (jsoned) {
                statuses.data = jsoned;
            })
            .catch(function (e) {
                window.handleApiError(ill_batch_statuses_api_fail);
            });
    };

    // Get the batch
    function fetchBatch() {
        window.doBatchApiRequest("/" + batchId, {
                headers: {
                    'x-koha-embed': 'patron'
                }
            })
            .then(function (response) {
                return response.json();
            })
            .then(function (jsoned) {
                batch.data = {
                    ill_batch_id: jsoned.ill_batch_id,
                    name: jsoned.name,
                    backend: jsoned.backend,
                    cardnumber: jsoned.cardnumber,
                    library_id: jsoned.library_id,
                    status_code: jsoned.status_code
                }
                return jsoned;
            })
            .then(function (data) {
                batch.data = data;
            })
            .catch(function () {
                window.handleApiError(ill_batch_api_fail);
            });
    };

    function createBatch() {
        var selectedBranchcode = branchcodeSelect.selectedOptions[0].value;
        var selectedStatuscode = statusesSelect.selectedOptions[0].value;
        return doBatchApiRequest('', {
            method: 'POST',
            headers: {
                'Content-type': 'application/json',
                'x-koha-embed': 'patron'
            },
            body: JSON.stringify({
                name: nameInput.value,
                backend: backend,
                cardnumber: cardnumberInput.value,
                library_id: selectedBranchcode,
                status_code: selectedStatuscode
            })
        })
            .then(function (response) {
                if ( response.ok ) {
                    return response.json();
                }
                return Promise.reject(response);
            })
            .then(function (body) {
                batchId = body.ill_batch_id;
                batch.data = {
                    ill_batch_id: body.ill_batch_id,
                    name: body.name,
                    backend: body.backend,
                    cardnumber: body.patron.cardnumber,
                    library_id: body.library_id,
                    status_code: body.status_code,
                    patron: body.patron,
                    status: body.status
                };
                initPostCreate();
            })
            .catch(function (response) {
                response.json().then((json) => {
                    if( json.error ) {
                        handleApiError(json.error);
                    } else {
                        handleApiError(ill_batch_create_api_fail);
                    }
                })
            });
    };

    function updateBatch() {
        var selectedBranchcode = branchcodeSelect.selectedOptions[0].value;
        var selectedStatuscode = statusesSelect.selectedOptions[0].value;

        return doBatchApiRequest('/' + batch.data.ill_batch_id, {
            method: 'PUT',
            headers: {
                'Content-type': 'application/json'
            },
            body: JSON.stringify({
                name: nameInput.value,
                backend: batch.data.backend,
                cardnumber: batch.data.patron.cardnumber,
                library_id: selectedBranchcode,
                status_code: selectedStatuscode
            })
        })
            .catch(function () {
                handleApiError(ill_batch_update_api_fail);
            });
    };

    function displaySupportedIdentifiers() {
        var names = Object.keys(supportedIdentifiers).map(function (identifier) {
            return window['ill_batch_' + identifier];
        });
        var displayEl = document.getElementById('supported_identifiers');
        displayEl.textContent = names.length > 0 ? names.join(', ') : ill_batch_none;
    }

    function updateRowCount() {
        var textEl = document.getElementById('row_count_value');
        var val = textarea.value.trim();
        var cnt = 0;
        if (val.length > 0) {
            cnt = val.split(/\n/).length;
        }
        textEl.textContent = cnt;
    }

    function showProgress() {
        var el = document.getElementById('create-progress');
        el.style.display = 'block';
    }

    function showCreateRequestsButton() {
        var data = progressTotals.data;
        var el = document.getElementById('create-requests');
        el.style.display = (data.total > 0 && data.count === data.total) ? 'flex' : 'none';
    }

    async function processIdentifiers() {
        var content = textarea.value;
        hideErrors();
        if (content.length === 0) return;

        disableProcessButton();
        var label = document.getElementById('progress-label').firstChild;
        label.innerHTML = ill_batch_retrieving_metadata;
        showProgress();

        // Errors encountered when processing
        var processErrors = {};

        // Prepare the content, including trimming each row
        var contentArr = content.split(/\n/);
        var trimmed = contentArr.map(function (row) {
            return row.trim();
        });

        var parsed = [];

        trimmed.forEach(function (identifier) {
            var match = identifyIdentifier(identifier);
            // If this identifier is not identifiable or
            // looks like more than one type, we can't be sure
            // what it is
            if (match.length != 1) {
                parsed.push({
                    type: 'unknown',
                    value: identifier
                });
            } else {
                parsed.push(match[0]);
            }
        });

        var unknownIdentifiers = parsed
            .filter(function (parse) {
                if (parse.type == 'unknown') {
                    return parse;
                }
            })
            .map(function (filtered) {
                return filtered.value;
            });

        if (unknownIdentifiers.length > 0) {
            processErrors.badidentifiers = {
                element: 'badids',
                values: unknownIdentifiers.join(', ')
            };
        };

        // Deduping
        var deduped = [];
        var dupes = {};
        parsed.forEach(function (row) {
            var value = row.value;
            var alreadyInDeduped = deduped.filter(function (d) {
                return d.value === value;
            });
            if (alreadyInDeduped.length > 0 && !dupes[value]) {
                dupes[value] = 1;
            } else if (alreadyInDeduped.length === 0) {
                row.metadata = {};
                row.failed = {};
                row.requestId = null;
                deduped.push(row);
            }
        });
        // Update duplicate error if dupes were found
        if (Object.keys(dupes).length > 0) {
            processErrors.duplicates = {
                element: 'dupelist',
                values: Object.keys(dupes).join(', ')
            };
        }

        // Display any errors
        displayErrors(processErrors);

        // Now build and display the table
        if (!table) {
            buildTable();
        }

        // We may be appending new values to an existing table,
        // in which case, ensure we don't create duplicates
        var tabIdentifiers = tableContent.data.map(function (tabId) {
            return tabId.value;
        });
        var notInTable = deduped.filter(function (ded) {
            if (!tabIdentifiers.includes(ded.value)) {
                return ded;
           }
        });
        if (notInTable.length > 0) {
            tableContent.data = tableContent.data.concat(notInTable);
        }

        // Populate metadata for those records that need it
        var newData = tableContent.data;
        for (var i = 0; i < tableContent.data.length; i++) {
            var row = tableContent.data[i];
            // Skip rows that don't need populating
            if (
                Object.keys(tableContent.data[i].metadata).length > 0 ||
                Object.keys(tableContent.data[i].failed).length > 0
            ) continue;
            var identifier = { type: row.type, value: row.value };
            try {
                var populated = await populateMetadata(identifier);
                row.metadata = populated.results.result || {};
            } catch (e) {
                row.failed = ill_populate_failed;
            }
            newData[i] = row;
            tableContent.data = newData;
        }
    }

    function disableProcessButton() {
        processButton.setAttribute('disabled', true);
        processButton.setAttribute('aria-disabled', true);
    }

    function disableCreateButton() {
        createButton.setAttribute('disabled', true);
        createButton.setAttribute('aria-disabled', true);
    }

    async function populateMetadata(identifier) {
        // All services that support this identifier type
        var services = supportedIdentifiers[identifier.type];
        // Check each service and use the first results we get, if any
        for (var i = 0; i < services.length; i++) {
            var service = services[i];
            var endpoint = '/api/v1/contrib/' + service.api_namespace + service.search_endpoint + '?' + identifier.type + '=' + identifier.value;
            var metadata = await getMetadata(endpoint);
            if (metadata.errors.length === 0) {
                var parsed = await parseMetadata(metadata, service);
                if (parsed.errors.length > 0) {
                    throw Error(metadata.errors.map(function (error) {
                        return error.message;
                    }).join(', '));
                }
                return parsed;
            }
        }
    };

    async function getMetadata(endpoint) {
        var response = await debounce(doApiRequest)(endpoint);
        return response.json();
    };

    async function parseMetadata(metadata, service) {
        var endpoint = '/api/v1/contrib/' + service.api_namespace + service.ill_parse_endpoint;
        var response = await doApiRequest(endpoint, {
            method: 'POST',
            headers: {
                'Content-type': 'application/json'
            },
            body: JSON.stringify(metadata)
        });
        return response.json();
    }

    // A render function for identifier type
    function createIdentifierType(data) {
        return window['ill_batch_' + data];
    };

    // Get an item's title
    function getTitle(meta) {
        if (meta.article_title && meta.article_title.length > 0) {
            return 'article_title';
            return {
                prop: 'article_title',
                value: meta.article_title
            };
        } else if (meta.title && meta.title.length > 0) {
            return 'title';
            return {
                prop: 'title',
                value: meta.title
            };
        }
    };

    // Create a metadata row
    function createMetadataRow(data, meta, prop) {
        if (!meta[prop]) return;

        var div = document.createElement('div');
        div.classList.add('metadata-row');
        var label = document.createElement('span');
        label.classList.add('metadata-label');
        label.innerText = ill_batch_metadata[prop] + ': ';

        // Add a link to the availability URL if appropriate
        var value;
        if (!data.url) {
            value = document.createElement('span');
        } else {
            value = document.createElement('a');
            value.setAttribute('href', data.url);
            value.setAttribute('target', '_blank');
            value.setAttribute('title', ill_batch_available_via + ' ' + data.availabilitySupplier);
        }
        value.classList.add('metadata-value');
        value.innerText = meta[prop];
        div.appendChild(label);
        div.appendChild(value);

        return div;
    }

    // A render function for displaying metadata
    function createMetadata(x, y, data) {
        // If the fetch failed
        if (data.failed.length > 0) {
            return data.failed;
        }

        // If we've not yet got any metadata back
        if (Object.keys(data.metadata).length === 0) {
            return ill_populate_waiting;
        }

        var core = ['doi', 'pmid', 'issn', 'title', 'year', 'issue', 'pages', 'publisher', 'article_title', 'article_author', 'volume'];
        var meta = data.metadata;

        var container = document.createElement('div');
        container.classList.add('metadata-container');

        // Create the title row
        var title = getTitle(meta);
        if (title) {
            // Remove the title element from the props
            // we're about to iterate
            core = core.filter(function (i) {
                return i !== title;
            });
            var titleRow = createMetadataRow(data, meta, title);
            container.appendChild(titleRow);
        }

        var remainder = document.createElement('div');
        remainder.classList.add('metadata-remainder');
        remainder.style.display = 'none';
        // Create the remaining rows
        core.sort().forEach(function (prop) {
            var div = createMetadataRow(data, meta, prop);
            if (div) {
                remainder.appendChild(div);
            }
        });
        container.appendChild(remainder);

        // Add a more/less toggle
        var firstField = container.firstChild;
        var moreLess = document.createElement('div');
        moreLess.classList.add('more-less');
        var moreLessLink = document.createElement('a');
        moreLessLink.setAttribute('href', '#');
        moreLessLink.classList.add('more-less-link');
        moreLessLink.innerText = ' [' + ill_batch_metadata_more + ']';
        moreLess.appendChild(moreLessLink);
        firstField.appendChild(moreLess);

        return container.outerHTML;
    };

    function removeRow(ev) {
        if (ev.target.className.includes('remove-row')) {
            if (!confirm(ill_batch_item_remove)) return;
            // Find the parent row
            var ancestor = ev.target.closest('tr');
            var identifier = ancestor.querySelector('.identifier').innerText;
            tableContent.data = tableContent.data.filter(function (row) {
                return row.value !== identifier;
            });
        }
    }

    function toggleMetadata(ev) {
        if (ev.target.className === 'more-less-link') {
            // Find the element we need to show
            var ancestor = ev.target.closest('.metadata-container');
            var meta = ancestor.querySelector('.metadata-remainder');

            // Display or hide based on its current state
            var display = window.getComputedStyle(meta).display;

            meta.style.display = display === 'block' ? 'none' : 'block';

            // Update the More / Less text
            ev.target.innerText = ' [ ' + (display === 'none' ? ill_batch_metadata_less : ill_batch_metadata_more) + ' ]';
        }
    }

    // A render function for the link to a request ID
    function createRequestId(x, y, data) {
        return data.requestId || '-';
    }

    function createRequestStatus(x, y, data) {
        return data.requestStatus || '-';
    }

    function buildTable(identifiers) {
        table = KohaTable('identifier-table', {
            processing: true,
            deferRender: true,
            ordering: false,
            paging: false,
            searching: false,
            autoWidth: false,
            columns: [
                {
                    data: 'type',
                    width: '13%',
                    render: createIdentifierType
                },
                {
                    data: 'value',
                    width: '25%',
                    className: 'identifier'
                },
                {
                    data: 'metadata',
                    render: createMetadata
                },
                {
                    data: 'requestId',
                    width: '6.5%',
                    render: createRequestId
                },
                {
                    data: 'requestStatus',
                    width: '6.5%',
                    render: createRequestStatus
                },
                {
                    width: '18%',
                    render: createActions,
                    className: 'action-column noExport'
                }
            ],
            createdRow: function (row, data) {
                if (data.failed.length > 0) {
                    row.classList.add('fetch-failed');
                }
            }
        });
    }

    function createActions(x, y, data) {
        return '<button type="button" aria-label='+ ill_button_remove + (data.requestId ? ' disabled aria-disabled="true"' : '') + ' class="btn btn-xs btn-danger remove-row">' + ill_button_remove + '</button>';
    }

    // Redraw the table
    function updateTable() {
        if (!table) return;
        tableEl.style.display = tableContent.data.length > 0 ? 'table' : 'none';
        tableEl.style.width = '100%';
        table.api()
            .clear()
            .rows.add(tableContent.data)
            .draw();
    };

    function identifyIdentifier(identifier) {
        var matches = [];

        // Iterate our available services to see if any can identify this identifier
        Object.keys(supportedIdentifiers).forEach(function (identifierType) {
            // Since all the services supporting this identifier type should use the same
            // regex to identify it, we can just use the first
            var service = supportedIdentifiers[identifierType][0];
            var regex = new RegExp(service.identifiers_supported[identifierType].regex);
            var match = identifier.match(regex);
            if (match && match.groups && match.groups.identifier) {
                matches.push({
                    type: identifierType,
                    value: match.groups.identifier
                });
            }
        });
        return matches;
    }

    function displayErrors(errors) {
        var keys = Object.keys(errors);
        if (keys.length > 0) {
            keys.forEach(function (key) {
                var el = document.getElementById(errors[key].element);
                el.textContent = errors[key].values;
                el.style.display = 'inline';
                var container = document.getElementById(key);
                container.style.display = 'block';
            });
            var el = document.getElementById('textarea-errors');
            el.style.display = 'flex';
        }
    }

    function hideErrors() {
        var dupelist = document.getElementById('dupelist');
        var badids = document.getElementById('badids');
        dupelist.textContent = '';
        dupelist.parentElement.style.display = 'none';
        badids.textContent = '';
        badids.parentElement.style.display = 'none';
        var tae = document.getElementById('textarea-errors');
        tae.style.display = 'none';
    }

    function manageBatchItemsDisplay() {
        batchItemsDisplay.style.display = batch.data.ill_batch_id ? 'block' : 'none'
    };

    function updateBatchInputs() {
        nameInput.value = batch.data.name || '';
        cardnumberInput.value = batch.data.cardnumber || '';
        branchcodeSelect.value = batch.data.library_id || '';
    }

    function debounce(func) {
        var timeout;
        return function (...args) {
            return new Promise(function (resolve) {
                if (timeout) {
                    clearTimeout(timeout);
                }
                timeout = setTimeout(function () {
                    return resolve(func(...args));
                }, debounceDelay);
            });
        }
    }

    function patronAutocomplete() {
        patron_autocomplete(
            $('#batch-form #batchcardnumber'),
            {
              'on-select-callback': function( event, ui ) {
                $("#batch-form #batchcardnumber").val( ui.item.cardnumber );
                return false;
              }
            }
          );
    };

    function createPatronLink() {
        if (!batch.data.patron) return;
        var patron = batch.data.patron;
        var a = document.createElement('a');
        var href = '/cgi-bin/koha/members/moremember.pl?borrowernumber=' + patron.borrowernumber;
        var text = patron.surname + ' (' + patron.cardnumber + ')';
        a.setAttribute('title', ill_borrower_details);
        a.setAttribute('href', href);
        a.textContent = text;
        return a;
    };

})();
