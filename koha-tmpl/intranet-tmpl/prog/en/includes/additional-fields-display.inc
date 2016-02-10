[% USE AuthorisedValues %]
[% FOR field IN available %]
    <li>
        <span class="label"> [% field.name %]: </span>
        [% IF field.authorised_value_category %]
            [% AuthorisedValues.GetByCode( field.authorised_value_category, values.${field.name} ) %]
        [% ELSE %]
            [% values.${field.name} %]
        [% END %]
    </li>
[% END %]
