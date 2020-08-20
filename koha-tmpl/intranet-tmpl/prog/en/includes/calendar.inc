[% USE Asset %]
[% USE Koha %]
[% USE raw %]
<!-- calendar.inc -->
<script>
    var debug    = "[% debug | html %]";
    var dateformat_pref = "[% Koha.Preference('dateformat ') | html %]";
    var dateformat_string = [% IF ( dateformat == "us" ) %]"mm/dd/yy"[% ELSIF ( dateformat == "metric" ) %]"dd/mm/yy"[% ELSIF ( dateformat == "dmydot" ) %]"dd.mm.yy"[% ELSE %]"yy-mm-dd"[% END %];
    var sentmsg = 0;
    var bidi = [% IF(bidi) %] true[% ELSE %] false[% END %];
    var calendarFirstDayOfWeek = '[% Koha.Preference('CalendarFirstDayOfWeek') | html %]';
</script>
<!-- / calendar.inc -->
[% Asset.js("js/calendar.js") | $raw %]
