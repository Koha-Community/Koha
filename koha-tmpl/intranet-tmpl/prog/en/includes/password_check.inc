[% USE Koha %]
[% BLOCK add_password_check %]
<script type="text/javascript">
    var pwd_title = "";
    var pattern_title = "";
    var new_password_node_name = "[% new_password %]";
    [% IF Koha.Preference('RequireStrongPassword') %]
        pwd_title = _("Password must contain at least %s characters, including UPPERCASE, lowercase and numbers").format([% minPasswordLength %]);
        pattern_regex = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{[% minPasswordLength %],}/;
    [% ELSIF minPasswordLength %]
        pwd_title = _("Password must contain at least %s characters").format([% minPasswordLength %]);
        pattern_regex = /.{[% minPasswordLength %],}/;
    [% END %]
    jQuery.validator.addMethod("password_strong", function(value, element){
        return this.optional(element) || value == '****' || pattern_regex.test(value);
    }, pwd_title);
    jQuery.validator.addMethod("password_no_spaces", function(value, element){
        return ( this.optional(element) || !value.match(/^\s/) && !value.match(/\s$/) );
    }, _("Password contains leading and/or trailing spaces"));
    jQuery.validator.addMethod("password_match", function(value, element){
        var new_password_node = $("input[name='" + new_password_node_name + "']:first");
        return value == $(new_password_node).val();
    }, _("Please enter the same password as above"));
</script>
[% END %]
