[% USE KohaDates %]
<legend>Patron selection</legend>
<table id="table_borrowers" class="table_borrowers">
    <thead>
        <tr>
            <th>Name</th>
            <th>Card number</th>
            <th>Date of birth</th>
            <th>Category</th>
            <th>Library</th>
            <th>Address</th>
        </tr>
    </thead>
    <tbody>
        [% FOREACH borrower IN borrowers %]
            [% IF ( destination == "circ" ) %]
                <tr class="clickable" data-url="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% borrower.borrowernumber %]">
                    <td><a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% borrower.borrowernumber %]">[% borrower.surname %], [% borrower.firstname %]</a></td>
            [% ELSE %]
                <tr class="clickable" data-url="/cgi-bin/koha/reserve/request.pl?borrowernumber=[% borrower.borrowernumber %]&amp;biblionumber=[% biblionumber %]">
                    <td><a href="/cgi-bin/koha/reserve/request.pl?borrowernumber=[% borrower.borrowernumber %]&amp;biblionumber=[% biblionumber %]">[% borrower.surname %], [% borrower.firstname %]</a></td>
            [% END %]
                <td>[% borrower.cardnumber %]</td>
                <td>[% borrower.dateofbirth | $KohaDates %]</td>
                <td>[% Categories.GetName( borrower.categorycode ) %]</td>
                <td>[% Branches.GetName( borrower.branchcode ) %]</td>
                <td>[% borrower.address %]</td>
            </tr>
        [% END %]
    </tbody>
</table>
