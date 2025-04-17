[% IF whole.error %]
    <p>Unhandled error</p>
[% END %]

[% IF whole.stage == "confirm" %]
    <h2>Confirm manual request</h2>
    <p>Proceeding with this action will set this request to 'Requested'.</p>
    <p>This means that actions have been taken to request this request from a source.</p>
    <p>If you can confirm this has been done, please proceed.</p>
    <p>
        [% base_url = "/cgi-bin/koha/ill/ill-requests.pl" %]
        [% proceed_url = base_url _ "?method=confirm&stage=confirm" _ "&illrequest_id=" _ request.illrequest_id %]
        <a class="btn btn-sm btn-primary" href="[% proceed_url | url %]">Confirm request</a>
        <a class="btn btn-sm btn-default cancel" href="[% base_url | url %]">Cancel</a>
    </p>
[% ELSE %]
    <p>Unknown stage. This should not have happened. </p>
[% END %]
