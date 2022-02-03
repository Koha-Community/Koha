<!-- js-patron-get-age.inc -->
<script>
    (function() {

        window.$get_age = function(dob, options) {
            if(!dob) return '';

            var today = new Date();
            dob = new Date(dob);
            var age = today.getFullYear() - dob.getFullYear();
            var m = today.getMonth() - dob.getMonth();
            if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
                age--;
            }
            return age;
        }

    })();
</script>
<!-- / js-patron-get-age.inc -->
