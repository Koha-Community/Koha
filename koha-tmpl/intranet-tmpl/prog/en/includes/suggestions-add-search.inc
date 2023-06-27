
[% USE Koha %]
<div id="header_search" role="tablist">
    <div class="tab-content">

        <div id="suggestions_search" role="tabpanel" class="tab-pane active">
            <form action="/cgi-bin/koha/acqui/newordersuggestion.pl" method="get">
                <input type="hidden" name="booksellerid" value="[% booksellerid | html %]" />

                <div class="form-title">
                    <label class="control-label"><span class="control-text">Search suggestions</span> <i class="fa-solid fa-fw fa-comment" aria-hidden="true"></i></label>
                </div>

                <div class="form-content">
                    <input type="text" id="searchtitle" class="head-searchbox form-control" placeholder="Title" name="title" size="10" value="[% title | html %]" />
                    <input type="text" id="searchauthor" class="head-searchbox form-control" placeholder="Author"  name="author" size="10" value="[% author | html %]" />
                    <input type="text" class="head-searchbox form-control" placeholder="Publisher" id="searchpublishercode" name="publishercode" size="10" value="[% publishercode | html %]" />
                </div>

                <button type="submit"><i class="fa fa-arrow-right"></i></button>
            </form>
        </div>

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% INCLUDE 'patron-search-box.inc' %]
        [% END %]

        [% IF ( CAN_user_catalogue ) %]
            [% INCLUDE 'catalogue-search-box.inc' %]
        [% END %]
    </div><!-- /.tab-content -->
    <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="active">
            <a title="Search suggestions" href="#suggestions_search" role="tab" aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa-solid fa-comment" aria-hidden="true"></i> <span class="tab-title">Search suggestions</span></a>
        </li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            <li role="presentation">
                <a title="Check out" href="#circ_search" aria-controls="circ_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-upload" aria-hidden="true"></i> <span class="tab-title">Check out</span></a>
            </li>
        [% END %]
        [% IF ( CAN_user_catalogue ) %]
            <li role="presentation">
                <a title="Search catalog" href="#catalog_search" aria-controls="catalog_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-search" aria-hidden="true"></i> <span class="tab-title">Search catalog</span></a>
            </li>
        [% END %]
    </ul>
</div><!-- /#header_search -->
<!-- /suggestions-add-search.inc -->
