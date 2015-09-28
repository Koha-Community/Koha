            <div id="toolbar" class="btn-toolbar">
                <div class="btn-group">
                    <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=new"><i class="fa fa-plus"></i> New collection</a>
                </div>

                [% IF ( colId ) %]
                    <div class="btn-group">
                        <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/transferCollection.pl?colId=[% colId %]">Transfer</a>
                    </div>
                    <div class="btn-group">
                        <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=edit&amp;colId=[% colId %]"><i class="fa fa-pencil"></i> Edit</a>
                    </div>
                    <div class="btn-group">
                        <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=delete&amp;colId=[% colId %]"><i class="fa fa-remove"></i> Delete</a>
                    </div>
                [% END %]
            </div>