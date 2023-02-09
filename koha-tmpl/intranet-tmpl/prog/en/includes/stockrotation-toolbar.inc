[% USE Koha %]
<div id="toolbar" class="btn-toolbar">
    [% IF no_op_set %]
        <a id="addrota" class="btn btn-default" href="/cgi-bin/koha/tools/stockrotation.pl?op=create_edit_rota"><i class="fa fa-plus"></i> New rota</a>
    [% END %]
    [% IF op == 'manage_stages' %]
        <a id="editrota" class="btn btn-default" href="/cgi-bin/koha/tools/stockrotation.pl?op=create_edit_rota&amp;rota_id=[% rota_id | uri %]"><i class="fa fa-pencil-alt"></i> Edit rota</a>
        <a class="btn btn-default" href="#" id="addstage" data-toggle="modal" data-target="#addStageModal"><i class="fa fa-plus"></i> Add stage</a>
    [% END %]
    [% IF op == 'manage_items' %]
        <a id="editrota" class="btn btn-default" href="/cgi-bin/koha/tools/stockrotation.pl?op=create_edit_rota&amp;rota_id=[% rota_id | uri %]"><i class="fa fa-pencil-alt"></i> Edit rota</a>
        <a class="btn btn-default" href="#" id="additems" data-toggle="modal" data-target="#addItemsModal"><i class="fa fa-plus"></i> Add items</a>
    [% END %]
</div>
