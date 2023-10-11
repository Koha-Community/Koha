<div id="ill-batch-details" style="display:none"></div>
<div id="ill-batch-modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="ill-batch-modal-label" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="closebtn" data-dismiss="modal" aria-hidden="true">×</button>
                <h3 id="ill-batch-modal-label"></h3>
            </div>
            <div class="modal-body">
                <div id="batch-form">
                    <form id="new-batch-form">
                        <fieldset class="rows">
                            <legend id="legend">Batch details</legend>
                            <ol>
                                <li id="batch_name">
                                    <label class="required" for="name">Batch name:</label>
                                    <input type="text" autocomplete="off" name="name" id="name" type="text"
                                    value="" />
                                </li>
                                <li id="batch_patron">
                                    <label class="required" for="batchcardnumber">Card number, username or surname:</label>
                                    <input type="text" autocomplete="off" name="batchcardnumber" id="batchcardnumber" type="text" value="" />
                                    <span id="patron_link"></span>
                                </li>
                                <li id="batch_branch">
                                    <label class="required" for="branchcode">Library:</label>
                                    <select id="branchcode" name="branchcode">
                                        [% PROCESS options_for_libraries libraries => Branches.all( selected => branchcode ) %]
                                    </select>
                                </li>
                                <li id="batch_status_code" style="display:none">
                                    <label class="required" for="status_code">Status:</label>
                                    <select id="status_code" name="status_code"></select>
                                </li>
                            </ol>
                        </fieldset>
                        <fieldset id="add_batch_items" class="rows" style="display:none">
                            <legend id="legend">Add batch items</legend>
                            <div id="textarea-metadata">
                                <div id="supported">Supported identifiers: <span id="supported_identifiers"></span></div>
                                <div id="row_count">Row count: <span id="row_count_value"></span></div>
                            </div>
                            <div id="textarea-errors" style="display:none" class="error">
                                <div id="duplicates" style="display:none">The following duplicates were found, these have been de-duplicated: <span id="dupelist"></span></div>
                                <div id="badidentifiers" style="display:none">The following unknown identifiers were found, it was not possible to establish their type: <span id="badids"></span></div>
                            </div>
                            <ol>
                                <li>
                                    <textarea id="identifiers_input" placeholder="Enter identifiers, one per line"></textarea>
                                </li>
                                <li id="process-button">
                                    <button id="process_button" disabled aria-disabled="true" type="button">Process identifiers</button>
                                </li>
                            </ol>
                        </fieldset>
                    </form>
                    <div id="create-progress" class="alert alert-info" role="alert" style="display:none">
                        <span id="progress-label"><strong></strong></span> -
                        Items processed: <span id="processed_count">0</span> out of <span id="processed_total">0</span>.
                        Items failed: <span id="processed_failed">0</span>.
                        <div class="progress">
                            <div id="processed_progress_bar" class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="min-width: 2em;">
                                0%
                            </div>
                        </div>
                    </div>
                    <table id="identifier-table" style="display:none">
                        <thead>
                            <tr id="identifier-table-header">
                                <th scope="col">Identifier type</th>
                                <th scope="col">Identifier value</th>
                                <th scope="col">Metadata</th>
                                <th scope="col">Request ID</th>
                                <th scope="col">Request status</th>
                                <th scope="col"></th>
                            </tr>
                        </thead>
                        <tbody id="identifier-table-body">
                        </tbody>
                    </table>
                </div>
                <div id="create-requests" style="display:none">
                    <button id="create-requests-button" type="button" class="btn btn-primary" aria-label="Add items to batch">Add items to batch</button>
                </div>
            </div>
            <div class="modal-footer">
                <div id="lhs">
                    <button class="btn btn-default" data-dismiss="modal" aria-hidden="false">Cancel</button>
                </div>
                <div id="rhs">
                    <button id="button_create_batch" class="btn btn-default" aria-hidden="true" disabled>Continue</button>
                    <button id="button_finish" disabled type="button" class="btn btn-default" aria-hidden="true">Finish and view batch</button>
                </div>
            </div>
        </div>
    </div>
</div>
