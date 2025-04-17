[% IF whole.error %]
    <p>Unhandled error</p>
[% END %]

[% IF whole.stage == "confirm" %]
    <h2>Cancel manual request</h2>
    <p>Proceeding with this action will set this request to 'Cancelled'.</p>
    <p>This means that actions have been taken to cancel this request at the source with whom the request was placed.</p>
    <p>If you can confirm this has been done, please proceed.</p>
    <p>
        [% base_url = "/cgi-bin/koha/ill/ill-requests.pl" %]
        [% proceed_url = base_url _ "?method=cancel&stage=confirm" _ "&illrequest_id=" _ request.illrequest_id %]
        <a class="btn btn-sm btn-primary" href="[% proceed_url | url %]">Revert request</a>
        <a class="btn btn-sm btn-default cancel" href="[% base_url | url %]">Cancel</a>
    </p>
[% END %]
