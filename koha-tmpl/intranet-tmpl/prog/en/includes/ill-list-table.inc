[% SET table_id = 'ill-requests' %]
[% IF patron.borrowernumber %]
    [% table_id = 'ill-requests-patron-' _ patron.borrowernumber %]
[% ELSIF batch.id %]
    [% table_id = 'ill-requests-batch-' _ batch.id %]
[% END %]
<table id="[% table_id | html %]">
    <thead>
        <tr id="ill_requests_header">
            <th scope="col">Request ID</th>
            <th scope="col">Batch</th>
            <th scope="col">Request details</th>
            <th scope="col" data-datatype="related-object" data-related="extended_attributes" data-related-key="type" data-related-value="type" data-related-search-on="value">Request type</th>
            <th scope="col">Order ID</th>
            <th scope="col">Patron</th>
            <th scope="col">Bibliographic record ID</th>
            <th scope="col">Library</th>
            <th scope="col">Status</th>
            <th scope="col" class="placed_formatted">Placed on</th>
            <th scope="col" class="updated_formatted">Updated on</th>
            <th scope="col">Replied</th>
            <th scope="col" class="completed_formatted">Completed on</th>
            <th scope="col">Access URL</th>
            <th scope="col">Cost</th>
            <th scope="col">Price paid</th>
            <th scope="col">Comments</th>
            <th scope="col">OPAC notes</th>
            <th scope="col">Staff notes</th>
            <th scope="col">Backend</th>
            <th scope="col" class="actions"></th>
        </tr>
    </thead>
    <tbody id="illview-body"> </tbody>
</table>
