<!-- validator-strings.inc -->
<script>
    $(document).ready(function(){
        jQuery.extend(jQuery.validator.messages, {
            required: _("This field is required."),
            remote: _("Please fix this field."),
            email: _("Please enter a valid email address."),
            url: _("Please enter a valid URL."),
            date: _("Please enter a valid date."),
            dateISO: _("Please enter a valid date (ISO)."),
            number: _("Please enter a valid number."),
            digits: _("Please enter only digits."),
            equalTo: _("Please enter the same value again."),
            number: _("Please add amount in valid format: 0.00"),
            maxlength: $.validator.format(_("Please enter no more than {0} characters.")),
            minlength: $.validator.format(_("Please enter at least {0} characters.")),
            rangelength: $.validator.format(_("Please enter a value between {0} and {1} characters long.")),
            range: $.validator.format(_("Please enter a value between {0} and {1}.")),
            max: $.validator.format(_("Please enter a value less than or equal to {0}.")),
            min: $.validator.format(_("Please enter a value greater than or equal to {0}.")),
            phone: $.validator.format(_("Please enter a valid phone number."))
        });
    });
</script>
<!-- / validator-strings.inc -->
