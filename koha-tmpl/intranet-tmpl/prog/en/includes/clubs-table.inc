[% IF destination == 'holds' %]
    <table id="clubs-table" class="selections-table">
[% ELSE %]
    <table id="clubs-table">
[% END %]
    <thead>
        <tr>
            <th>Name</th>
            <th>Template</th>
            <th>Description</th>
            [% UNLESS destination == 'holds' %]
                <th>Public enrollment</th>
                <th>Email required</th>
            [% END %]
            <th>Library</th>
            <th>Start date</th>
            <th>End date</th>
            <th>Enrolled patrons</th>
            [% UNLESS destination == 'holds' %]
                <th>&nbsp;</th>
            [% END %]
        </tr>
    </thead>
    <tbody>
        [% FOREACH c IN clubs %]
            [% IF destination == 'holds' %]
                [% SET data_url = "/cgi-bin/koha/reserve/request.pl?club=" _ c.id %]
                [% FOREACH biblionumber IN biblionumbers %]
                    [% SET data_url = data_url _ "&amp;biblionumber=" _ biblionumber %]
                [% END %]
                [% IF multi_hold %]
                    [% SET data_url = data_url _ "&amp;multi_hold=1" %]
                [% END %]
                <tr class="clickable" data-url="[% data_url | html %]">
                    <td><a href="[% data_url | url %]">[% c.name | html %]</a></td>
            [% ELSE %]
                <tr>
                    <td>[% c.name | html %]</td>
            [% END %]
                <td>[% c.club_template.name | html %]</td>
                <td>[% c.description | html %]</td>
                [% UNLESS destination == 'holds' %]
                    <td>
                        [% IF c.club_template.is_enrollable_from_opac %]
                            <span>Yes</span>
                        [% ELSE %]
                            <span>No</span>
                        [% END %]
                    </td>
                    <td>
                        [% IF c.club_template.is_email_required %]
                            <span>Yes</span>
                        [% ELSE %]
                            <span>No</span>
                        [% END %]
                    </td>
                [% END %]
                <td>[% Branches.GetName( c.branchcode ) | html %]</td>
                <td>
                    [% IF c.date_start %]
                        [% c.date_start | $KohaDates %]
                    [% END %]
                </td>
                <td>
                    [% IF c.date_end %]
                        [% c.date_end | $KohaDates %]
                    [% END %]
                </td>
                <td>
                    [% c.club_enrollments.count | html %]
                </td>
                [% UNLESS destination == 'holds' %]
                    <td class="actions">
                        <div class="btn-group dropup">
                            <a class="btn btn-default btn-xs dropdown-toggle" id="clubactions[% c.id | html %]" role="button" data-toggle="dropdown" href="#">
                                Actions <b class="caret"></b>
                            </a>
                            <ul class="dropdown-menu pull-right" role="menu" aria-labelledby="clubactions[% c.id | html %]">
                                [% IF ( c.club_enrollments.count ) %]
                                    <li>
                                        <a href="club-enrollments.pl?id=[% c.id | uri %]">
                                            <i class="fa fa-list-ul"></i> Enrollments
                                        </a>
                                    </li>
                                [% ELSE %]
                                    <li class="disabled">
                                        <a href="#" data-toggle="tooltip" data-placement="left" title="There are no enrollments for this club yet">
                                            <i class="fa fa-list-ul"></i> Enrollments
                                        </a>
                                    </li>
                                [% END %]
                                [% IF CAN_user_clubs_edit_clubs %]
                                    <li>
                                        <a href="clubs-add-modify.pl?id=[% c.id | uri %]">
                                            <i class="fa fa-pencil-alt"></i> Edit
                                        </a>
                                    </li>
                                    <li>
                                        <a href="#" class="delete_club" data-id="[% c.id | html %]" data-name="[% c.name | html %]">
                                            <i class="fa fa-trash-can"></i> Delete
                                        </a>
                                    </li>
                                [% END %]
                                [% IF ( c.club_enrollments.count ) %]
                                    <li>
                                        <a href="#" class="club_hold_search" data-id="[% c.id | html %]">
                                            <i class="fa fa-search"></i> Search to hold
                                        </a>
                                    </li>
                                [% END %]
                            </ul>
                        </div>
                    </td>
                [% END %]
            </tr>
        [% END %]
    </tbody>
</table> <!-- /.clubs-table -->
