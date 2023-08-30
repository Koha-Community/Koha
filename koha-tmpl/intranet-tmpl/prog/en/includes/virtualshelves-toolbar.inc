[% INCLUDE 'blocking_errors.inc' %]

<div id="toolbar" class="btn-toolbar">
    <div class="btn-group"><a id="newshelf" class="btn btn-default" href="/cgi-bin/koha/virtualshelves/shelves.pl?op=add_form&amp;referer=[% op | html %]"><i class="fa fa-plus"></i> New list</a></div>

    [% IF ( can_add_biblios ) %]
        <div class="btn-group">
            <button type="button" class="btn btn-default" data-toggle="modal" data-target="#addToList">
                <i class="fa fa-plus"></i> Add items
            </button>
        </div>
    [% END %]

    [% IF shelf AND op == 'view' %]
        [% IF can_manage_shelf %]
        <div class="btn-group">
            <button class="btn btn-default dropdown-toggle" data-toggle="dropdown"><i class="fa-solid fa-pencil" aria-hidden="true"></i> Edit <span class="caret"></span></button>
            <ul class="dropdown-menu">
                <li><a href="/cgi-bin/koha/virtualshelves/shelves.pl?op=edit_form&amp;shelfnumber=[% shelf.shelfnumber | uri %]&amp;referer=[% op | uri %]">Edit list</a></li>
                <li>
                    <a id="deleteshelf_toolbar" href="#">Delete list</a>
                    <form id="deleteshelf_toolbar_form" action="shelves.pl" method="post">
                        [% INCLUDE 'csrf-token.inc' %]
                        <input type="hidden" name="op" value="delete">
                        <input type="hidden" name="shelfnumber" value="[% shelf.shelfnumber | html %]">
                    </form>
                </li>
            </ul>
        </div>
        [% END %]

        <div class="btn-group">
            <button class="btn btn-default dropdown-toggle" data-toggle="dropdown"><i class="fa fa-download"></i> Download list <span class="caret"></span></button>
                <ul class="dropdown-menu">
                    <li><a href="/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=iso2709&amp;shelfid=[% shelf.shelfnumber | uri %]">iso2709</a></li>
                    <li><a href="/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=ris&amp;shelfid=[% shelf.shelfnumber | uri %]">RIS</a></li>
                    <li><a href="/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=bibtex&amp;shelfid=[% shelf.shelfnumber | uri %]">BibTex</a></li>
                    [% FOREACH csv_profile IN csv_profiles %]
                        <li><a href="/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=[% csv_profile.export_format_id | uri %]&amp;shelfid=[% shelf.shelfnumber | uri %]">CSV - [% csv_profile.profile | html %]</a></li>
                    [% END %]
                </ul>
        </div>
        <div class="btn-group"><a class="btn btn-default" href="#" id="sendlist"><i class="fa-solid fa-envelope"></i> Send list</a></div>
        <div class="btn-group"><a class="btn btn-default" id="printlist" target="_blank" href="/cgi-bin/koha/virtualshelves/shelves.pl?op=view&amp;shelfnumber=[% shelf.shelfnumber | html %]&amp;print=1"><i class="fa fa-print"></i> Print list</a></div>
    [% END %]
</div>
