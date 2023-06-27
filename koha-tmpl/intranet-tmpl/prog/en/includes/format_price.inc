[% USE Koha %]
<!-- format-price.inc -->
<script>
    [%# This should use the Format template plugin, but not pushed yet %]
    [% IF Koha.Preference("CurrencyFormat") == 'FR' %]
        var default_value = {
            thousands_sep: ' ',
            decimal_point: ',',
            decimal_digits: 2
        };
    [% ELSIF Koha.Preference("CurrencyFormat") == 'CH' %]
        var default_value = {
            thousands_sep: '\'',
            decimal_point: '.',
            decimal_digits: 2
        };
    [% ELSE %]
        var default_value = {
            thousands_sep: ',',
            decimal_point: '.',
            decimal_digits: 2
        };

    [% END %]
    Number.prototype.format_price = function( value, params ) {
        params = params == undefined ? {} : params;
        var thousands_sep = params.thousands_sep == undefined ? default_value.thousands_sep : params.thousands_sep,
            decimal_point = params.decimal_point == undefined ? default_value.decimal_point : params.decimal_point,
            //symbol = params.symbol == undefined ? '$' : params.symbol, // Not implemented yet
            decimal_digits = params.decimal_digits == undefined ? default_value.decimal_digits : params.decimal_digits;

            var re = '\\d(?=(\\d{' + 3 + '})+' + '\\D' + ')', value = this.toFixed(decimal_digits);
            return value.replace('.', decimal_point).replace(new RegExp(re, 'g'), '$&' + thousands_sep);
    }
    String.prototype.unformat_price = function (params) {
        params = params == undefined ? {} : params;
        var thousands_sep = params.thousands_sep == undefined ? default_value.thousands_sep : params.thousands_sep,
            decimal_point = params.decimal_point == undefined ? default_value.decimal_point : params.decimal_point,
            //symbol = params.symbol == undefined ? '$' : params.symbol, // Not implemented yet
            decimal_digits = params.decimal_digits == undefined ? default_value.decimal_digits : params.decimal_digits;

        let value = this.valueOf();
        value = value.replace(thousands_sep, '').replace(decimal_point, '.').replace(new RegExp('[^\\d.]', 'g'), '');
        return Number(value).toFixed(decimal_digits);
    }

</script>
<!-- / format-price.inc -->
