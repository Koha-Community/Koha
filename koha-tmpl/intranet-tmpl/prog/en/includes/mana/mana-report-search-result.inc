[% USE KohaDates %]
[% USE Koha %]
[% USE AuthorisedValues %]
[% USE Branches %]

<script type="text/javascript">
//<![CDATA[
$(document).ready(function() {
    $(document).on('click', 'button.mana-use', function() {
        id = $(this).attr('id');
        mana_use(id.substr(9));
    });

    $(document).on('change', 'select.mana-actions', function() {
        report_id = $(this).attr('id').substr(13);
        if ($(this).val() == 'other') {
            $('input#selected_id').val(report_id);
            $('#comment_box').modal('show');
        } else {
            comment_id = $(this).val();
            mana_increment(comment_id, 'resource_comment', 'nb');
        }
    });
});
//]]>
</script>
[% INCLUDE 'mana.inc' %]

[% IF statuscode == "200" AND reports %]
    <table id="mana_results_datatable" width=100%>
        <thead>
            <tr>
                <th>Report Name</th>
                <th class="anti-the" width=35%>Notes</th>
                <th>Type</th>
                <th title="number of libraries using this pattern"># of users</th>
                <th class="title-string" title="last time a library used this pattern">Last import</th>
                <th> Comments </th>
                [% UNLESS search_only %]
                  <th class="NoSort">Actions</th>
                [% END %]
            </tr>
        </thead>
        <tbody>
            [% FOREACH report IN reports %]
                [% UNLESS report.cannotdisplay %]
                    [% IF report.nbofcomment > highWarned %]
                  <tr id="row[% report.id %]" class = "high-warned-row">
                    [% ELSIF report.nbofcomment > warned %]
                  <tr id="row[% report.id %]" class = "warned-row">
                    [% ELSIF report.nbofcomment > lowWarned %]
                  <tr id="row[% report.id %]" class = "highlighted-row">
                    [% END %]
                    <input hidden class="rowid" value="[% report.id %]">
                    <td>[% IF ( report.report_name ) %][% report.report_name %][% END %]</td>
                    <td title="[% report.savedsql |html %]"><div>
                        [% IF report.notes.length > 200 %]
                            [% report.notes.substr(0,200) %]<a class="showbutton">Show More</a></div><div hidden>
                        [% END %]
                            [% report.notes %]
                        [% IF report.notes.length > 200 %]
                                <a class="hidebutton">Show Less</a></div> </td>
                        [% END %]
                    <td> [% report.type %] </td>
                    <td>[% IF ( report.nbofusers ) %][% report.nbofusers %][% END %]</td>
                    <td><span title="[% report.lastimport %]">[% report.lastimport | $KohaDates %]</span></td>
                    <td>[% FOREACH comment IN report.comments %][% comment.message %] ([% comment.nb %]) <br>[% END %]</td>

                    [% UNLESS search_only %]
                        <td>
                            <button class="mana-use" id="mana-use-[% report.id %]"><i class="fa fa-inbox"></i> Use</button>
                        </td>
                    [% END %]
                  </tr>
                [% END %]
            [% END %]
        </tbody>
    </table>
[% ELSE %]
    <h4> [% msg %]  statuscode: [% statuscode %]</h4>
[% END %]
