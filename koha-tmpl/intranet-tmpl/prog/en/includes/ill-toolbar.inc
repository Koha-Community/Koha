[% USE Koha %]
[% IF Koha.Preference('ILLModule ') && CAN_user_ill %]
    <div id="toolbar" class="btn-toolbar">
        [% IF backends_available %]
          [% IF backends.size > 1 %]
            <div class="dropdown btn-group">
                <button class="btn btn-sm btn-default dropdown-toggle" type="button" id="ill-backend-dropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                    <i class="fa fa-plus"></i> New ILL request <span class="caret"></span>
                </button>
                <ul class="dropdown-menu" aria-labelledby="ill-backend-dropdown">
                    [% FOREACH backend IN backends %]
                        <li><a href="/cgi-bin/koha/ill/ill-requests.pl?method=create&amp;backend=[% backend | uri %]">[% backend | html %]</a></li>
                    [% END %]
                </ul>
            </div>
          [% ELSE %]
            <a id="ill-new" class="btn btn-sm btn-default" href="/cgi-bin/koha/ill/ill-requests.pl?method=create&amp;backend=[% backends.0 | html %]">
                <i class="fa fa-plus"></i> New ILL request
            </a>
          [% END %]
        [% ELSE %]
            <a id="ill-new" class="btn btn-sm btn-default disabled" href="">
                <i class="fa fa-plus"></i> New ILL request
            </a>
        [% END %]
        <a id="ill-list" class="btn btn-sm btn-default btn-group" href="/cgi-bin/koha/ill/ill-requests.pl">
            <i class="fa fa-list"></i> List requests
        </a>
    </div>
[% END %]
