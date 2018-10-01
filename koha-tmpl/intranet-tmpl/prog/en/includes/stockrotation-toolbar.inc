[% USE Koha %]
<div id="toolbar" class="btn-toolbar">
    [% IF no_op_set %]
        <a id="addrota" class="btn btn-default btn-sm" href="/cgi-bin/koha/tools/stockrotation.pl?op=create_edit_rota"><i class="fa fa-plus"></i> New rota</a>
    [% END %]
    [% IF op == 'manage_stages' %]
        <a id="editrota" class="btn btn-default btn-sm" href="/cgi-bin/koha/tools/stockrotation.pl?op=create_edit_rota&amp;rota_id=[% rota_id %]"><i class="fa fa-pencil"></i> Edit rota</a>
    [% END %]
    [% IF op == 'manage_items' %]
        <a id="editrota" class="btn btn-default btn-sm" href="/cgi-bin/koha/tools/stockrotation.pl?op=create_edit_rota&amp;rota_id=[% rota_id %]"><i class="fa fa-pencil"></i> Edit rota</a>
    [% END %]
</div>
