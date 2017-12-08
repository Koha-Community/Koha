[% INCLUDE 'blocking_errors.inc' %]
[% IF ( authid || CAN_user_editauthorities) %]

<div id="toolbar" class="btn-toolbar">

[% IF ( authid ) %]
    [% IF ( CAN_user_editauthorities ) %]
        <div class="btn-group"><a class="btn btn-default btn-sm" id="editAuth" href="authorities.pl?authid=[% authid %]"><i class="fa fa-pencil"></i> Edit</a></div>
        <div class="btn-group"><a class="btn btn-default btn-sm" id="dupAuth" href="authorities.pl?authid=[% authid %]&amp;op=duplicate"><i class="fa fa-copy"></i> Duplicate</a></div>
        [% UNLESS ( count ) %]
            <div class="btn-group"><a href="#" class="btn btn-default btn-sm" id="delAuth"><i class="fa fa-trash"></i> Delete</a></div>
        [% END %]
    [% END %]

    <div class="btn-group">
        <a class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" href="#"><i class="fa fa-download"></i> Save
        <span class="caret"></span>
        </a>
        <ul class="dropdown-menu">
            <li><a href="/cgi-bin/koha/authorities/export.pl?format=mads&amp;op=export&amp;authid=[% authid %]">MADS (XML)</a></li>
            <li><a href="/cgi-bin/koha/authorities/export.pl?format=marcxml&amp;op=export&amp;authid=[% authid %]">MARCXML</a></li>
            <li><a href="/cgi-bin/koha/authorities/export.pl?format=marc8&amp;op=export&amp;authid=[% authid %]">MARC (non-Unicode/MARC-8)</a></li>
            <li><a href="/cgi-bin/koha/authorities/export.pl?format=utf8&amp;op=export&amp;authid=[% authid %]">MARC (Unicode/UTF-8)</a></li>
        </ul>
    </div>
[% END %]

[% IF ( CAN_user_editauthorities ) %]
    <div class="btn-group">
        <a class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" href="#"><i class="fa fa-plus"></i> New authority
        <span class="caret"></span>
        </a>
        <ul class="dropdown-menu">
            [% FOREACH authority_type IN authority_types %]
                <li><a href="/cgi-bin/koha/authorities/authorities.pl?authtypecode=[% authority_type.authtypecode %]">[% authority_type.authtypetext %]</a></li>
            [% END %]
        </ul>
    </div>
    [% IF servers.count > 0 %]
        <div class="btn-group">
            <a class="btn btn-default btn-sm" id="z3950submit" href="#"><i class="fa fa-search"></i> New from Z39.50</a>
        </div>
    [% END %]
[% END %]
</div>

[% END %]
