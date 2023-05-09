[% USE Koha %]
[% IF ( relatives_issues_count ) %]
    <table id="relatives-issues-table" style="width: 100% !Important;">
        <thead>
            <tr>
                <th scope="col">Due date (unformatted, hidden)</th>
                <th scope="col">Due date</th>
                <th scope="col">Title</th>
                <th scope="col">Record-level item type</th>
                <th scope="col">Item type</th>
                <th scope="col">Collection</th>
                <th scope="col">Location</th>
                <th scope="col">Checked out on (hidden, unformatted)</th>
                <th scope="col">Checked out on</th>
                <th scope="col">Checked out from</th>
                <th scope="col">Call number</th>
                <th scope="col">Copy number</th>
                <th scope="col">Charge</th>
                <th scope="col">Fine</th>
                <th scope="col">Price</th>
                <th scope="col">Patron</th>
            </tr>
        </thead>
    </table>
[% END %]
