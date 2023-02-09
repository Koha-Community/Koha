[% INCLUDE 'blocking_errors.inc' %]
<div id="toolbar" class="btn-toolbar">
    <div class="btn-group">
        <a class="btn btn-default" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=new"><i class="fa fa-plus"></i> New collection</a>
    </div>

    [% IF ( colId ) %]
        <div class="btn-group">
            <a class="btn btn-default" href="/cgi-bin/koha/rotating_collections/transferCollection.pl?colId=[% colId | html %]"><i class="fa-solid fa-right-left"></i> Transfer</a>
        </div>
        <div class="btn-group">
            <a class="btn btn-default" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=edit&amp;colId=[% colId | html %]"><i class="fa fa-pencil-alt"></i> Edit</a>
        </div>
        <div class="btn-group">
            <a class="btn btn-default confirmdelete" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=delete&amp;colId=[% colId | html %]"><i class="fa fa-trash-can"></i> Delete</a>
        </div>
    [% END %]
</div>
