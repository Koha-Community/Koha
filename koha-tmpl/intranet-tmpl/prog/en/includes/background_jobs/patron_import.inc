[% USE Koha %]
[% USE raw %]

[% BLOCK report %]
    [% SET job_data = job.decoded_data %]
    [% IF job.status == 'finished' %]
        <div class="alert alert-info">
            <ul>
                <li>[% job_data.imported | html %] imported records</li>
                [% IF job_data.patron_list_name %]
                    <li>Patron list with imported patrons: [% job_data.patron_list_name | html %]</li>
                [% END %]
                <li>[% job_data.overwritten | html %] overwritten records</li>
                <li>[% job_data.already_in_db | html %] not imported because they are already in the borrowers table and overwrite is disabled</li>
                <li>[% job_data.invalid | html %] not imported because they are not in the expected format</li>
                <li>[% job_data.total | html %] records parsed</li>
            </ul>
        </div>
    [% ELSIF job.status == 'started' OR job.status == 'running' %]
        [% INCLUDE "job_progress.inc" job_id=job.id %]
    [% ELSIF job.status == 'cancelled' %]
        <div class="alert alert-warning">The job was cancelled before it finished.</div>
    [% ELSIF job.status == 'failed' %]
        <div class="alert alert-danger">The job failed.</div>
    [% ELSE %]
        [% INCLUDE "job_progress.inc" job_id=job.id %]
    [% END %]
[% END %]

[% BLOCK detail %]
    [% SET job_data = job.decoded_data %]
    [% IF job_data.feedback %]
        <h3>Feedback</h3>
        <ul class="feedback">
            [% FOREACH f IN job_data.feedback %]
                <li>
                    [% IF f.filename %]
                        <span>Parsing upload file</span> <span class="filename">[% f.filename | html %]</span>
                    [% ELSIF f.backend %]
                        <span>Upload parsed using [% f.backend | html %]</span>
                    [% ELSIF f.headerrow %]
                        <span>These fields found: [% f.value | html %]</span>
                    [% ELSIF f.already_in_db %]
                        <span>Patron already in database: [% f.value | html %]</span>
                    [% ELSE %]
                        [% f.name | html %]:
                        [% f.value | html %]
                    [% END %]
                </li>
            [% END %]
        </ul>
    [% END %]

    [% IF job_data.errors %]
        <h3>Error analysis</h3>
        <ul>
            [% FOREACH e IN job_data.errors %]
                [% IF e.badheader %]<li>Header row could not be parsed</li>[% END %]

                [% FOREACH missing_critical IN e.missing_criticals %]
                    <li class="line_error">
                        Line <span class="linenumber">[% missing_critical.line | html %]</span>

                        [% IF missing_critical.badparse %]
                            <span>could not be parsed!</span>
                        [% ELSIF missing_critical.bad_date %]
                            <span>has &quot;[% missing_critical.key | html %]&quot; in unrecognized format:</span> &quot;[% missing_critical.value | html %]&quot;
                        [% ELSE %]
                            <span>Critical field &quot;[% missing_critical.key | html %]&quot;</span>

                            [% IF missing_critical.branch_map %]
                                <span>has unrecognized value &quot;[% missing_critical.value | html %]&quot;</span>
                            [% ELSIF missing_critical.category_map %]
                                <span>has unrecognized value &quot;[% missing_critical.value | html %]&quot;</span>
                            [% ELSE %]
                                <span>missing</span>
                            [% END %]
                            (<span>borrowernumber: [% missing_critical.borrowernumber | html %]</span>; <span>surname: [% missing_critical.surname | html %]</span>).
                        [% END %]

                        <br />
                        <code>[% missing_critical.lineraw | html %]</code>
                    </li>
                [% END %]

                [% IF e.invalid_cardnumber %]
                    <li class="line_error">Card number [% e.cardnumber | html %] is not a valid card number[% IF e.borrowernumber %](for patron with borrowernumber [% e.borrowernumber | html %])[% END %]</li>
                [% END %]
                [% IF e.duplicate_userid %]
                    <li class="line_error">Userid [% e.userid | html %] is already used by another patron.</li>
                [% END %]
                [% IF e.passwd_too_short %]
                    <li class="line_error">Password is too short for patron with borrowernumber [% e.borrowernumber | html %]. Minimum length is [% e.min_length | html %], length is [% e.length | html %].</li>
                [% END %]
                [% IF e.passwd_whitespace %]
                    <li class="line_error">Password contains whitespace for patron with borrowernumber [% e.borrowernumber | html %].</li>
                [% END %]
                [% IF e.passwd_too_weak %]
                    <li class="line_error">Password is too weak for patron with borrowernumber [% e.borrowernumber | html %].</li>
                [% END %]
                [% IF e.passwd_plugin_err %]
                    <li class="line_error">Password plugin error for patron with borrowernumber [% e.borrowernumber | html %].</li>
                [% END %]
                [% IF e.passwd_unknown_err %]
                    <li class="line_error">Password error for patron with borrowernumber [% e.borrowernumber | html %].</li>
                [% END %]
                [% IF e.patron_attribute_unique_id_constraint %]
                    <li class="line_error">
                        [% IF e.borrowernumber %]
                            <span>Patron attribute [% e.attribute.code | html %] must be unique for patron with borrowernumber [% e.borrowernumber | html %].</span>
                        [% ELSE %]
                            <span>Patron attribute [% e.attribute.code | html %] must be unique for patron [% e.patron_id | html %].</span>
                        [% END %]
                    </li>
                [% END %]
                [% IF e.patron_attribute_invalid_type %]
                    <li class="line_error">
                        [% IF e.borrowernumber %]
                            <span>Patron attribute [% e.attribute_type_code | html %] is invalid for patron with borrowernumber [% e.borrowernumber | html %].</span>
                        [% ELSE %]
                            <span>Patron attribute [% e.attribute_type_code | html %] is invalid for patron [% e.patron_id | html %].</span>
                        [% END %]
                    </li>
                [% END %]
                [% IF e.patron_attribute_non_repeatable %]
                    <li class="line_error">
                        [% IF e.borrowernumber %]
                            <span>Patron attribute [% e.attribute.code | html %] is non-repeatable for patron with borrowernumber [% e.borrowernumber | html %].</span>
                        [% ELSE %]
                            <span>Patron attribute [% e.attribute.code | html %] is non-repeatable for patron [% e.patron_id | html %].</span>
                        [% END %]
                    </li>
                [% END %]
            [% END %]
        </ul>
    [% END %]
[% END %]

[% BLOCK js %]
    [% IF job.status != 'finished' AND job.status != 'cancelled' AND job.status != 'failed' %]
        [% INCLUDE 'str/job_progress.inc' job_id=job.id %]
        [% Asset.js("js/job_progress.js") | $raw %]
        <script nonce="[% Koha.CSPNonce | $raw %]">
            $(document).ready(function () {
                updateProgress([% job.id | html %], {
                    finish_callback: function () {
                        window.location.reload();
                    },
                });
            });
        </script>
    [% END %]
[% END %]
