<script type="text/javascript">
//<![CDATA[
    $(document).ready(function() {
        $("#delAuth").click(function(){
            confirm_deletion();
            return false;
        });
    });

//]]>
</script>

[% IF ( authid || CAN_user_editauthorities) %]

<div id="toolbar" class="btn-toolbar">

[% IF ( authid ) %]
    [% IF ( CAN_user_editauthorities ) %]
        <div class="btn-group"><a class="btn btn-small" id="editAuth" href="authorities.pl?authid=[% authid %]"><i class="icon-pencil"></i> Edit</a></div>
        <div class="btn-group"><a class="btn btn-small" id="dupAuth" href="authorities.pl?authid=[% authid %]&amp;op=duplicate"><i class="icon-copy"></i> Duplicate</a></div>
        [% UNLESS ( count ) %]
            <div class="btn-group"><a href="#" class="btn btn-small" id="delAuth"><i class="icon-remove"></i> Delete</a></div>
        [% END %]
    [% END %]

    <div class="btn-group">
        <a class="btn btn-small dropdown-toggle" data-toggle="dropdown" href="#"><i class="icon-download-alt"></i> Save
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
        <a class="btn btn-small dropdown-toggle" data-toggle="dropdown" href="#"><i class="icon-plus"></i> New authority
        <span class="caret"></span>
        </a>
        <ul class="dropdown-menu">
            [% FOREACH authtypesloo IN authtypesloop %]
            <li><a href="/cgi-bin/koha/authorities/authorities.pl?authtypecode=[% authtypesloo.value %]">[% authtypesloo.authtypetext %]</a></li>
            [% END %]
        </ul>
    </div>
[% END %]
</div>

[% END %]
