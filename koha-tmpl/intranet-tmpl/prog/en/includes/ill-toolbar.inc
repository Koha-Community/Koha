[% INCLUDE 'blocking_errors.inc' %]
[% USE Koha %]
[% IF Koha.Preference('ILLModule') && CAN_user_ill %]
    <div id="toolbar" class="btn-toolbar ill-toolbar">
        [% IF backends_available %]
          [% IF backends.size > 1 %]
            <div class="dropdown btn-group">
                <button class="btn btn-default dropdown-toggle" type="button" id="ill-backend-dropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                    <i class="fa fa-plus"></i> New ILL request <span class="caret"></span>
                </button>
                <ul class="dropdown-menu" aria-labelledby="ill-backend-dropdown">
                    [% FOREACH backend IN backends %]
                        <li><a href="/cgi-bin/koha/ill/ill-requests.pl?method=create&amp;backend=[% backend | uri %]">[% backend | html %]</a></li>
                    [% END %]
                </ul>
            </div>
          [% ELSE %]
            <a id="ill-new" class="btn btn-default" href="/cgi-bin/koha/ill/ill-requests.pl?method=create&amp;backend=[% backends.0 | html %]">
                <i class="fa fa-plus"></i> New ILL request
            </a>
          [% END %]
        [% ELSE %]
            <a id="ill-new" class="btn btn-default disabled" href="">
                <i class="fa fa-plus"></i> New ILL request
            </a>
        [% END %]
        [% IF query_type == 'illlist' %]
            <a id="ill-list" class="btn btn-sm btn-default btn-group" href="/cgi-bin/koha/ill/ill-requests.pl">
                <i class="fa fa-list"></i> Refresh
            </a>
        [% ELSE %]
            <a id="ill-list" class="btn btn-sm btn-default btn-group" href="/cgi-bin/koha/ill/ill-requests.pl">
                <i class="fa fa-list"></i> List requests
            </a>
        [% END %]
        [% IF have_batch.size > 0 && metadata_enrichment_services %]
        <div id="ill-batch">
            <div class="dropdown btn-group">
                <button class="btn btn-default dropdown-toggle" type="button" id="ill-batch-backend-dropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                    <i class="fa fa-plus"></i> New ILL requests batch <span class="caret"></span>
                </button>
                <ul class="dropdown-menu" aria-labelledby="ill-batch-backend-dropdown">
                    [% FOREACH backend IN have_batch %]
                        <li><a href="#" role="button" onclick="window.openBatchModal(null, '[% backend | html %]')">[% backend | html %]</a></li>
                    [% END %]
                </ul>
            </div>
            <a class="btn btn-default" type="button" href="/cgi-bin/koha/ill/ill-requests.pl?method=batch_list" %]">
                <i class="fa fa-tasks"></i> Batch requests</span>
            </a>
        </div>
        [% END %]
    </div>
[% END %]
