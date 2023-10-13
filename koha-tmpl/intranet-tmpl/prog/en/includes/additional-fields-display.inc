[% USE AuthorisedValues %]
[% FOR field IN available %]
        [% IF is_table_cell %]
            <td>
        [% END %]
        [% SET values_list = [] %]
        [% FOR value IN values.${field.id} %]
            [% IF field.authorised_value_category %]
                [% values_list.push(AuthorisedValues.GetByCode( field.authorised_value_category, value )) %]
            [% ELSE %]
                [% values_list.push(value) %]
            [% END %]
        [% END %]
        [% IF value_only %]
           [% values_list.join(', ') | html %]
        [% ELSIF !values_list.empty %]
            <li>
                <span class="label"> [% field.name | html %]: </span>
                [% values_list.join(', ') | html %]
            </li>
        [% END %]
        [% IF is_table_cell %]
            </td>
        [% END %]
[% END %]
