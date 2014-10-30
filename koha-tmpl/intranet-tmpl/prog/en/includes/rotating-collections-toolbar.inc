            <div id="toolbar" class="btn-toolbar">
                <div class="btn-group">
                    <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=new"><i class="icon-plus"></i> New collection</a>
                </div>

                [% IF ( colId ) %]
                    <div class="btn-group">
                        <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/transferCollection.pl?colId=[% colId %]">Transfer</a>
                    </div>
                    <div class="btn-group">
                        <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=edit&amp;colId=[% colId %]"><i class="icon-pencil"></i> Edit</a>
                    </div>
                    <div class="btn-group">
                        <a class="btn btn-small" href="/cgi-bin/koha/rotating_collections/editCollections.pl?action=delete&amp;colId=[% colId %]"><i class="icon-remove"></i> Delete</a>
                    </div>
                [% END %]
            </div>