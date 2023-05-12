[% IF query_type == "batch_list" %]
<div>
    <table id="ill-batch-requests">
        <thead>
            <tr id="ill-batch-header">
                <th scope="col">Batch ID</th>
                <th scope="col">Name</th>
                <th scope="col">Number of requests</th>
                <th scope="col">Status</th>
                <th scope="col">Patron</th>
                <th scope="col">Branch</th>
                <th scope="col"></th>
            </tr>
        </thead>
        <tbody id="ill-batch-body">
        </tbody>
    </table>
</div>
[% END %]