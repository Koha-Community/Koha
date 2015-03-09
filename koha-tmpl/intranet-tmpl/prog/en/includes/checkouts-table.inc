<div id="checkouts">
    [% IF ( issuecount ) %]
        <div id="issues-table-loading-message">
            <p>
                <a id="issues-table-load-now-button" href="#" class="btn"><i class="icon-book"></i> Show checkouts</a>
            </p>
        </div>
        <form name="issues" action="/cgi-bin/koha/tools/export.pl" method="post" class="checkboxed">
            <table id="issues-table" style="width: 100% !Important;">
                <thead>
                    <tr>
                        <th scope="col">&nbsp;</th>
                        <th scope="col">&nbsp;</th>
                        <th scope="col">Due date</th>
                        <th scope="col">Due date</th>
                        <th scope="col">Title</th>
                        <th scope="col">Item type</th>
                        <th scope="col">Checked out on</th>
                        <th scope="col">Checked out from</th>
                        <th scope="col">Call no</th>
                        <th scope="col">Charge</th>
                        <th scope="col">Fine</th>
                        <th scope="col">Price</th>
                        <th scope="col">Renew <p class="column-tool"><a href="#" id="CheckAllRenewals">select all</a> | <a href="#" id="UncheckAllRenewals">none</a></p></th>
                        <th scope="col">Check in <p class="column-tool"><a href="#" id="CheckAllCheckins">select all</a> | <a href="#" id="UncheckAllCheckins">none</a></p></th>
                        <th scope="col">Export <p class="column-tool"><a href="#" id="CheckAllExports">select all</a> | <a href="#" id="UncheckAllExports">none</a></p></th>
                    </tr>
                </thead>
                [% INCLUDE 'checkouts-table-footer.inc' %]
            </table>

            <label for="issues-table-load-immediately">Always show checkouts immediately</label>
            <input id="issues-table-load-immediately" type="checkbox" />

            <div id="issues-table-actions">
                <fieldset class="action">
                    [% IF ( CAN_user_circulate_override_renewals ) %]
                        [% IF ( AllowRenewalLimitOverride ) %]
                            <label for="override_limit">Override renewal limit:</label>
                            <input type="checkbox" name="override_limit" id="override_limit" value="1" />
                        [% END %]
                    [% END %]
                    <button class="btn" id="RenewCheckinChecked"><i class="icon-check"></i> Renew or return checked items</button>
                    <button class="btn" id="RenewAll"><i class="icon-book"></i> Renew all</button>
                </fieldset>

                [% IF ( exports_enabled ) %]
                    <fieldset>
                        <label for="output_format"><b>Export checkouts using format:</b></label>
                        <select name="output_format" id="output_format">
                            <option value="iso2709_995">ISO2709 with items</option>
                            <option value="iso2709">ISO2709 without items</option>
                            [% IF Koha.Preference('ExportWithCsvProfile') %]
                                <option value="csv">CSV</option>
                            [% END %]
                        </select>

                       <label for="export_remove_fields">Don't export fields:</label> <input type="text" id="export_remove_fields" name="export_remove_fields" value="[% export_remove_fields %]" title="Use for iso2709 exports" />
                        <input type="hidden" name="op" value="export" />
                        <input type="hidden" id="output_format" name="output_format" value="iso2709" />
                        <input type="hidden" id="dont_export_item" name="dont_export_item" value="0" />
                        <input type="hidden" id="record_type" name="record_type" value="bibs" />
                        <button class="btn btn-small" id="export_submit"><i class="icon-download-alt"></i> Export</button>
                    </fieldset>
                [% END %]
            </div>
        </form>
    [% ELSE %]
        <p>Patron has nothing checked out.</p>
    [% END %]
</div>
