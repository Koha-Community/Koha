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
            [% IF destination == "circ" %]
                <tr class="clickable" data-url="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% borrower.borrowernumber | html %]">
                    <td><a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% borrower.borrowernumber | html %]">[% borrower.surname | html %], [% borrower.firstname | html %]</a></td>
            [% ELSIF destination == "holds" %]
                [% IF multi_hold %]
                    [% SET data_url = "/cgi-bin/koha/reserve/request.pl?borrowernumber=" _ borrower.borrowernumber _ "&amp;multi_hold=1&amp;biblionumbers=" _ biblionumbers %]
                [% ELSE %]
                    [% SET data_url = "/cgi-bin/koha/reserve/request.pl?borrowernumber=" _ borrower.borrowernumber _ "&amp;biblionumber=" _ biblionumber %]
                [% END %]
                <tr class="clickable" data-url="[% data_url | html %]">
                    <td><a href="[% data_url | html %]">[% borrower.surname | html %], [% borrower.firstname | html %]</a></td>
            [% END %]
                <td>[% borrower.cardnumber | html %]</td>
                <td>[% borrower.dateofbirth | $KohaDates %]</td>
                <td>[% Categories.GetName( borrower.categorycode ) | html %]</td>
                <td>[% Branches.GetName( borrower.branchcode ) | html %]</td>
                <td>[% borrower.address | html %]</td>
            </tr>
        [% END %]
    </tbody>
</table>
