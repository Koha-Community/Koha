[% USE KohaDates %]
<table id="mana_results_datatable">
    <thead>
        <tr>
            <th>ISSN</th>
            <th class="anti-the">Title</th>
            <th>Frequency</th>
            <th>Numbering pattern</th>
            <th class="NoSort">Number of users</th>
            <th class="title-string">Last Import</th>
            [% UNLESS search_only %]
              <th class="NoSort">Actions</th>
            [% END %]
        </tr>
    </thead>
    <tfoot>
        <tr>
            <td><input type="text" class="dt-filter" data-column_num="0" placeholder="Search ISSN" /></td>
            <td><input type="text" class="dt-filter" data-column_num="1" placeholder="Search title" /></td>
            <td><input type="text" class="dt-filter" data-column_num="2" placeholder="Search frequency" /></td>
            <td><input type="text" class="dt-filter" data-column_num="3" placeholder="Search numbering pattern" /></td>
            <td></td>
            <td><input type="text" class="dt-filter" data-column_num="5" placeholder="Search last import" /></td>
            [% UNLESS search_only %]
              <td></td>
            [% END %]
        </tr>
    </tfoot>
    <tbody>
        [% FOREACH subscription IN subscriptions %]
            [% UNLESS subscription.cannotdisplay %]
                <tr id="row[% subscription.subscriptionid %]">
                    <td>[% IF ( subscription.issn ) %][% subscription.issn %][% END %]</td>
                    <td>[% subscription.title %]</a></td>
                    <td>[% IF ( subscription.sfdescription ) %][% subscription.sfdescription %][% END %]</td>
                    <td>[% IF ( subscription.numberingmethod ) %][% subscription.numberingmethod %][% END %]</td>
                    <td>[% IF ( subscription.nbofusers ) %][% subscription.nbofusers %][% END %]</td>
                    <td><span title="[% subscription.lastimport %]">[% subscription.lastimport | $KohaDates %]</span></td>
                    [% UNLESS search_only %]
                      <td><a style="cursor:pointer" onclick="mana_use([% subscription.id %])"> <i class="fa fa-inbox"></i> Use</a></td>
                    [% END %]
                </tr>
            [% END %]
        [% END %]
    </tbody>
</table>
