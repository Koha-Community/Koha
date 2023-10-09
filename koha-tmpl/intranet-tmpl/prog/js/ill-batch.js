(function () {
    // Enable the modal to be opened from anywhere
    // If we're working with an existing batch, set the ID so the
    // modal can access it
    window.openBatchModal = function (id, backend) {
        var idEl = document.getElementById('ill-batch-details');
        idEl.dataset.backend = backend;
        if (id) {
            idEl.dataset.batchId = id;
        }
        $('#ill-batch-modal').modal({ show: true });
    };

    // Make a batch API call, returning the resulting promise
    window.doBatchApiRequest = function (url, options) {
        var batchListApi = '/api/v1/ill/batches';
        var fullUrl = batchListApi + (url ? url : '');
        return doApiRequest(fullUrl, options);
    };

    // Make a "create local ILL submission" call
    window.doCreateSubmission = function (body, options) {
        options = Object.assign(
            options || {},
            {
                headers: {
                    'Content-Type': 'application/json'
                },
                method: 'POST',
                body: JSON.stringify(body)
            }
        );
        return doApiRequest(
            '/api/v1/ill/requests',
            options
        )
    }

    // Make an API call, returning the resulting promise
    window.doApiRequest = function (url, options) {
        return fetch(url, options);
    };

    // Display an API error
    window.handleApiError = function (error) {
        alert(error);
    };

})();
