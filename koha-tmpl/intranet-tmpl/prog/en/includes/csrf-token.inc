[%- USE Koha %]
[%- USE raw %]
<input type="hidden" name="csrf_token" value="[% Koha.GenerateCSRF | $raw %]" />
