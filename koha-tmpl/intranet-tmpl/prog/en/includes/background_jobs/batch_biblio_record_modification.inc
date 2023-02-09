[% USE KohaSpan %]
[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        [% IF report.total_records == report.total_success %]
            <div class="dialog message">
                <span>All records have successfully been modified!</span>
                <a href="/cgi-bin/koha/tools/batch_record_modification.pl" title="New batch record modification">New batch record modification</a>
                [% IF lists.count %]
                    <br />
                    <span>Add modified records to the following list:</span>
                    <select name="add_bibs_to_list" id="add_bibs_to_list">
                        <option value="">Select a list</option>
                        [% FOREACH list IN lists %]
                            <option class="shelf" value="[% list.shelfnumber | html %]">[% list.shelfname | html %]</option>
                        [% END %]
                    </select>
                [% END %]
            </div>
        [% ELSE %]
            <div class="dialog message">
                <span>[% report.total_success | html %] / [% report.total_records | html %] records have successfully been modified. Some errors occurred.</span>
                [% IF job.status == 'cancelled' %]<span>The job has been cancelled before it finished.</span>[% END %]
                <a href="/cgi-bin/koha/tools/batch_record_modification.pl" title="New batch record modification">New batch record modification</a>
            </div>
        [% END %]
    [% END %]
[% END %]

[% BLOCK detail %]
    [% FOR m IN job.messages %]
        <div class="dialog message">
            [% IF m.type == 'success' %]
                <i class="fa fa-check success"></i>
            [% ELSIF m.type == 'warning' %]
                <i class="fa fa-warning warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% biblio_link = BLOCK %]<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% m.biblionumber | uri %]">[% m.biblionumber | html %]</a>[% END %]
            [% SWITCH m.code %]
            [% CASE 'biblio_not_modified' %]
                <span>Bibliographic record [% biblio_link | $raw %] has not been modified. An error occurred on modifying it.</span>
                [% IF m.error %] ([% m.error | html %])[% END %].
            [% CASE 'biblio_modified' %]
                <span>Bibliographic record [% biblio_link | $raw %] has successfully been modified.</span>
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
    <script>
        $("#add_bibs_to_list").change(function(){
            var selected = $("#add_bibs_to_list").find("option:selected");
            if ( selected.attr("class") == "shelf" ){
                var shelfnumber = selected.val();
                var bibs = new Array();
                [% FOREACH message IN job.messages %]
                    [% IF message.code == 'biblio_modified' %]
                        bibs.push("biblionumber="+[% message.biblionumber | html %]);
                    [% END %]
                [% END %]
                var bibstring = bibs.join("&");
                window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?shelfnumber='+shelfnumber+'&confirm=1&'+bibstring, 'popup', 'width=500,height=500,toolbar=false,scrollbars=yes,resizable=yes');
                return false;
            }
        });
    </script>
[% END %]
