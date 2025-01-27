[% USE AuthorisedValues %]
[%# Parameters: %]
[%# name: the name of the select element %]
[%# category: the authorised value category %]
[%# default: the default authorised value to select %]
[%# class: the CSS class of the select element %]
[%# size: the size to use for the input (generated if the authorised value category does not exist). %]
[%# all: add a "All" entry. All and empty should not be used at the same time. %]
[%# empty: add an empty entry. All and empty should not be used at the same time. %]

[% SET avs = AuthorisedValues.GetAuthValueDropbox( category ) %]
[% DEFAULT class = '' size = 20 %]

[% IF avs.count %]
    <select [% UNLESS no_id %]id="[% name | html %]"[% END %] name="[% name | html %]" class="[% class | html %]">
        [% IF all %]<option value="">All</option>[% END %]
        [% IF empty %]<option value=""></option>[% END %]
        [% FOR av IN avs %]
            [% IF av.authorised_value == default %]
                <option value="[% av.authorised_value | html %]" selected="selected">[% av.lib | html_entity %]</option>
            [% ELSE %]
                <option value="[% av.authorised_value | html %]">[% av.lib | html_entity %]</option>
            [% END %]
        [% END %]
    </select>
[% ELSE %]
    [% IF no_id %]
        <input type="text" name="[% name | html %]" size="[% size | html %]" value="[% default | html_entity %]" class="[% class | html %]" />
    [% ELSE %]
        <input type="text" id="[% name | html %]" name="[% name | html %]" size="[% size | html %]" value="[% default | html_entity %]" class="[% class | html %]" />
    [% END %]
[% END %]
