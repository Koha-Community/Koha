[% USE AuthorisedValues %]
[% FOR field IN available %]
    <li>
        <span class="label"> [% field.name | html %]: </span>
        [% IF field.authorised_value_category %]
            [% AuthorisedValues.GetByCode( field.authorised_value_category, values.${field.name} ) | html %]
        [% ELSE %]
            [% values.${field.name} | html %]
        [% END %]
    </li>
[% END %]
