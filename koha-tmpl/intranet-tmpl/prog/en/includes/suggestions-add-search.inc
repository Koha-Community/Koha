[% USE Koha %]
<div id="header_search">

    <div id="suggestions_search" class="residentsearch">
        <form action="/cgi-bin/koha/acqui/newordersuggestion.pl" method="get">
            <input type="hidden" name="booksellerid" value="[% booksellerid | html %]" />

            <span class="form-content">
                <input type="text" id="searchtitle" class="head-searchbox form-control" placeholder="Title" name="title" size="10" value="[% title | html %]" />
                <input type="text" id="searchauthor" class="head-searchbox form-control" placeholder="Author"  name="author" size="10" value="[% author | html %]" />
                <input type="text" class="head-searchbox form-control" placeholder="Publisher" id="searchpublishercode" name="publishercode" size="10" value="[% publishercode | html %]" />
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    [% INCLUDE 'patron-search-box.inc' %]

    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a title="Search suggestions" href="#suggestions_search" class="keep_text"><i class="fa fa-comment-o"></i> Search suggestions</a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i> Check out</a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i> Search catalog</a></li>[% END %]
    </ul>
</div>
<!-- End Suggestions Resident Search Box -->
