[%- BLOCK restriction_type_description -%]
    [% ddisplay = restriction.display_text %]
    [% SWITCH ddisplay %]
        [% CASE 'Manual' %]<span>Manual</span>
        [% CASE 'Overdues' %]<span>Overdues</span>
        [% CASE 'Suspension' %]<span>Suspension</span>
        [% CASE 'Discharge' %]<span>Discharge</span>
        [% CASE %]<span>[% ddisplay | html %]</span>
    [% END %]
[%- END -%]
