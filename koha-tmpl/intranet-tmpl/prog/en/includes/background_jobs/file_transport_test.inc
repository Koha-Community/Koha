[% USE Koha %]

[%- BLOCK operation_description -%]
    [%# Content between SWITCH and its first CASE never executes in Template Toolkit, so "status" must be computed here, before the SWITCH - and against operation.status (the field that actually holds 'error'/'success'), not the nonexistent operation.error. #%]
    [%- SET status = operation.status == 'error' ? "failed." : "passed." -%]
    [%- SWITCH operation.code -%]

    [%- CASE 'connection' -%]
        <span>Connection</span> [% status | html %]
    [%- CASE 'upload' -%]
        <span>Upload</span> [% status | html %]
    [%- CASE 'download' -%]
        <span>Download</span> [% status | html %]
    [%- CASE 'list' -%]
        <span>List files</span> [% status | html %]
    [%- CASE 'change_directory' -%]
        <span>Change directory ([% operation.detail.path | html %])</span> [% status | html %]
    [%- CASE -%]
        <span>[% operation.code | html %]</span> [% status | html %]
    [%- END -%]
[%- END -%]

[% SET report = job.decoded_data %]
[% BLOCK report %]
    [% IF job.status == 'finished' %]
        [%- IF report.status == 'errors' -%]
            <div class="alert alert-alert"> Connection test for [% report.transport_name | html %]([% report.transport_id | html %]) completed with errors </div>
        [%- ELSE -%]
            <div class="alert alert-success"> Connection test for [% report.transport_name | html %]([% report.transport_id | html %]) completed without errors </div>
        [%- END -%]
    [% ELSIF job.status == 'cancelled' %]
        <span>The connection test was cancelled before it finished.</span>
    [% END %]
[% END %]

[% BLOCK detail %]
    [% FOREACH operation IN report.operations %]
        [% IF operation.status == 'error' %]
            <div class="text-danger">
                <i class="fa-solid fa-circle-xmark"></i> [% PROCESS operation_description %]
                [%- IF operation.detail.error %]- error:[% operation.detail.error | html %][% END -%]</div
            >
        [% ELSE %]
            <div class="text-success"> <i class="fa-solid fa-circle-check"></i> [% PROCESS operation_description %] </div>
        [% END %]
    [% END %]
    [% IF job.status == 'cancelled' %]
        <span>The connection test was cancelled before it finished.</span>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
