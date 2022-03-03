<!-- js-patron-get-age.inc -->
[% USE KohaDates %]
<script>
    (function() {

        const tz = '[% KohaDates.tz | html %]';
        window.$get_age = function(dob, options) {
            if(!dob) return '';

            let today = new Date();
            dob = new Date(dob);
            if ( tz ) {
                let today_tz = new Date(today.toLocaleString('en-US', {timeZone: tz}));
                let diff = today.getTime() - today_tz.getTime();
                today = new Date(today.getTime() - diff);

                let dob_tz = new Date(dob.toLocaleString('en-US', {timeZone: tz}));
                diff = dob.getTime() - dob_tz.getTime();
                dob = new Date(dob.getTime() - diff);
            }
            let age = today.getFullYear() - dob.getFullYear();
            let m = today.getMonth() - dob.getMonth();
            if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
                age--;
            }
            return age;
        }

    })();
</script>
<!-- / js-patron-get-age.inc -->
