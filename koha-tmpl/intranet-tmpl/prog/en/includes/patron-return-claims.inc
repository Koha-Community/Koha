<p id="return-claims-controls">
    [% IF ( patron.return_claims.resolved.count > 0 || patron.return_claims.unresolved.count > 0 ) %]
        <a id="show_all_claims" class="ctrl_link" href="#">Show all [% patron.return_claims.count | html %] claim(s)</a>
        <a id="show_unresolved_claims" class="ctrl_link disabled" href="#">Show [% patron.return_claims.unresolved.count | html %] unresolved claims</a>
    [% ELSE %]
        <a id="show_all_claims" class="ctrl_link" href="#"></a>
        <a id="show_unresolved_claims" class="ctrl_link disabled" href="#"></a>
    [% END %]
</p>
<table id="return-claims-table" class="table table-bordered table-striped">
    <thead>
        <tr>
            <th class="return-claim-id">Claim ID</th>
            <th class="return-claim-id">Resolved?</th>
            <th class="return-claim-record-title anti-the">Title</th>
            <th class="return-claim-notes">Notes</th>
            <th class="return-claim-created-on">Created on</th>
            <th class="return-claim-created-on">Created on</th>
            <th class="return-claim-updated-on">Updated on</th>
            <th class="return-claim-updated-on">Updated on</th>
            <th class="return-claim-resolution">Resolution</th>
            <th class="return-claim-actions NoSort">&nbsp;</th>
        </tr>
    </thead>
</table>
