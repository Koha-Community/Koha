[% INCLUDE 'blocking_errors.inc' %]
<div id="toolbar" class="btn-toolbar">
    <div class="btn-group">
        <button class="btn btn-default dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> New <span class="caret"></span></button>
        <ul class="dropdown-menu">
            <li><a href="/cgi-bin/koha/labels/label-edit-batch.pl?op=new">Label batch</a></li>
            <li><a href="/cgi-bin/koha/labels/label-edit-layout.pl?op=new">Layout</a></li>
            <li><a href="/cgi-bin/koha/labels/label-edit-template.pl?op=new">Label template</a></li>
            <li><a href="/cgi-bin/koha/labels/label-edit-profile.pl?op=new">Printer profile</a></li>
            <li><a href="/cgi-bin/koha/labels/label-edit-range.pl">Barcode range</a></li>
        </ul>
    </div>
    <div class="btn-group">
        <button class="btn btn-default dropdown-toggle" data-toggle="dropdown"><i class="fa-solid fa-pencil" aria-hidden="true"></i> Manage <span class="caret"></span></button>
        <ul class="dropdown-menu">
            <li><a href="/cgi-bin/koha/labels/label-manage.pl?label_element=batch">Label batches</a></li>
            <li><a href="/cgi-bin/koha/labels/label-manage.pl?label_element=layout">Layouts</a></li>
            <li><a href="/cgi-bin/koha/labels/label-manage.pl?label_element=template">Label templates</a></li>
            <li><a href="/cgi-bin/koha/labels/label-manage.pl?label_element=profile">Printer profiles</a></li>
        </ul>
    </div>
</div>
