<script type="text/javascript">
//<![CDATA[

[% IF ( viewshelf ) %]

    function sendList(){
        open(CGIBIN+'virtualshelves/sendshelf.pl?shelfid=[% shelfnumber %]','win_form','scrollbars=no,resizable=no,height=300,width=450,top=50,left=100');
     }

     $(document).ready(function() {
        $("#sendlist").click(function(){
            sendList();
            return false;
        });
        $("#printlist").click(function(){
            print();
            return false;
        });
        $("#deleteshelf").click(function(e){
            if(confirmDelete(_("Are you sure you want to delete this list?"))){
                return true;
            } else {
                e.preventDefault();
            }
        });
     });

[% END %]

//]]>
</script>

<div id="toolbar" class="btn-toolbar">
    <div class="btn-group"><a id="newshelf" class="btn btn-small" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelves=1"><i class="icon-plus"></i> New list</a></div>

    [% IF ( viewshelf ) %]
        [% IF ( manageshelf ) %]
        <div class="btn-group">
            <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="icon-pencil"></i> Edit <span class="caret"></span></button>
                <ul class="dropdown-menu">
                    <li><a href="/cgi-bin/koha/virtualshelves/shelves.pl?shelfnumber=[% shelfnumber %]&amp;op=modif">Edit list</a></li>
                    [% IF ( showprivateshelves ) %]
                        <li><a id="deleteshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?display=privateshelves&amp;shelves=1&amp;DEL-[% shelfnumber %]=1">Delete list</a></li>
                    [% ELSE %]
                        <li><a id="deleteshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelves=1&amp;DEL-[% shelfnumber %]=1">Delete list</a></li>
                    [% END %]
                </ul>
        </div>
        [% END %]

        <div class="btn-group">
            <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="icon-download"></i> Download list <span class="caret"></span></button>
                <ul class="dropdown-menu">
                    <li><a href="/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=iso2709&amp;shelfid=[% shelfnumber %]">iso2709</a></li>
                    <li><a href="/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=ris&amp;shelfid=[% shelfnumber %]">RIS</a></li>
                    <li><a href="/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=bibtex&amp;shelfid=[% shelfnumber %]">BibTex</a></li>
                    [% FOREACH csv_profile IN csv_profiles %]
                        <li><a href="/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=[% csv_profile.export_format_id %]&amp;shelfid=[% shelfnumber %]">CSV - [% csv_profile.profile %]</a></li>
                    [% END %]
                </ul>
        </div>
        <div class="btn-group"><a class="btn btn-small" href="#" id="sendlist"><i class="icon-envelope"></i> Send list</a></div>
        <div class="btn-group"><a class="btn btn-small" id="printlist" href="#"><i class="icon-print"></i> Print list</a></div>
    [% END %]
</div>
