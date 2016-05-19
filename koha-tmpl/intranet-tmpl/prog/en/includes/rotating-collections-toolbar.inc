<script type="text/javascript">
    $(document).ready(function(){
        $(".confirmdelete").click(function(){
            $(this).parents('tr').addClass("warn");
            if(confirm(_("Are you sure you want to delete this rotating collection?"))){
                return true;
            } else {
                $(this).parents('tr').removeClass("warn");
                return false;
            }
        });
});
</script>

            <div id="toolbar" class="btn-toolbar">
                <div class="btn-group">
                    <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=new"><i class="fa fa-plus"></i> New collection</a>
                </div>

                [% IF ( colId ) %]
                    <div class="btn-group">
                        <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/transferCollection.pl?colId=[% colId %]"><i class="fa fa-exchange"></i> Transfer</a>
                    </div>
                    <div class="btn-group">
                        <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=edit&amp;colId=[% colId %]"><i class="fa fa-pencil"></i> Edit</a>
                    </div>
                    <div class="btn-group">
                        <a class="btn btn-small confirmdelete" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=delete&amp;colId=[% colId %]"><i class="fa fa-trash"></i> Delete</a>
                    </div>
                [% END %]
            </div>
