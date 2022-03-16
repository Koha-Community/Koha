[% USE Koha %]
[% USE raw %]
[% USE Asset %]
[% USE KohaDates %]
[% Asset.js("lib/moment/moment.min.js") | $raw %]
[% Asset.js("lib/moment/moment-timezone-with-data-10-year-range.min.js") | $raw %]
<!-- js-date-format.inc -->
<script>
    (function() {
        var def_date_format = '[% Koha.Preference('dateformat') | html %]';
        var def_time_format = '[% Koha.Preference('TimeFormat') | html %]';
        var def_tz = '[% KohaDates.tz | html %]';

        var get_date_pattern = function(format) {
            var date_pattern = 'YYYY-MM-DD';
            if(format == 'us') date_pattern = 'MM/DD/YYYY';
            if(format == 'metric') date_pattern = 'DD/MM/YYYY';
            if(format == 'dmydot') date_pattern = 'DD.MM.YYYY';
            return date_pattern;
        };

        var get_time_pattern = function(format) {
            var time_pattern = 'HH:mm';
            if(format == '12hr') time_pattern = 'hh:mm a';
            return time_pattern;
        };

        /*
         * A JS equivilent of the KohaDates TT Plugin. Passed an rfc3339 formatted date string,
         * or JS Date, the function will return a date string formatted as per the koha instance config.
         * Optionally accepts a dateformat parameter to allow override of the configured output format
         * as well as a 'withtime' boolean denoting whether to include time or not in the output string.
         */
        window.$date = function(value, options) {
            if(!value) return '';
            var tz = (options&&options.tz)||def_tz;
            var m = moment(value);
            if((m.creationData().format !== 'YYYY-MM-DD')&&tz) m.tz(tz);

            var dateformat = (options&&options.dateformat)||def_date_format;
            var withtime = (options&&options.withtime)||false;

            if(dateformat=='rfc3339' && withtime) return m.format();

            var timeformat = (options&&options.timeformat)||def_time_format;
            var date_pattern = get_date_pattern(dateformat);
            var time_pattern = !withtime?'':' '+get_time_pattern(timeformat);

            return m.format(date_pattern+time_pattern);
        }

        window.$datetime = function(value, options) {
            options = options||{};
            options.withtime = true;
            return $date(value, options);
        };

        window.$time = function(value, options) {
            if(!value) return '';
            var tz = (options&&options.tz)||def_tz;
            var m = moment(value);
            if(tz) m.tz(tz);

            var dateformat = (options&&options.dateformat);
            var timeformat = (dateformat=='rfc3339'&&'24hr')||(options&&options.timeformat)||def_time_format;

            return m.format(get_time_pattern(timeformat)+(dateformat=='rfc3339'?':ss'+(!m.isUTC()?'Z':''):''))+(dateformat=='rfc3339' && m.isUTC()?'Z':'');
        }

        window.$date_to_rfc3339 = function(value, options) {
            var dateformat = (options&&options.dateformat)||def_date_format;
            let m = moment(value, get_date_pattern(dateformat));
            return m.format("YYYY-MM-DD");
        }

    })();
</script>
<!-- / js-date-format.inc -->
