[%# USAGE [ INCLUDE 'throttled-button.inc' element_type='button' classes='btn btn-primary' label=t('Run report') attrs={ name => 'op', value => 'cud-run' } ] %]

[% DEFAULT element_type = 'link' %]
[% DEFAULT ready_icon = 'fa fa-play' %]
[% DEFAULT active_icon = 'fa fa-spinner fa-spin' %]
[% DEFAULT classes = 'btn btn-default' %]
[% DEFAULT href = '#' %]

[%# Common attributes shared by both button and link %]
[% BLOCK common_attrs %]
    class="[% classes | html %]"[% IF id %]id="[% id | html %]"[% END %] data-state="ready" data-throttled-button [% IF persist %]data-throttle-persist[% END %]
    [% IF attrs %][% FOREACH key IN attrs.keys %][% key | html %]="[% attrs.$key | html %]"[% END %][% END %]
[% END %]

[%# Inner content shared by both button and link %]
[% BLOCK inner_content %]
    <span class="button-icon-ready"><i class="[% ready_icon | html %]"></i></span>
    <span class="button-icon-running" style="display: none;"><i class="[% active_icon | html %]"></i></span>
    [% IF done_icon %]<span class="button-icon-done" style="display: none;"><i class="[% done_icon | html %]"></i></span>[% END %]
    [% UNLESS icon_only %][% label | html %][% END %]
[% END %]

[% IF element_type == 'button' -%]
    <button type="submit" [% PROCESS common_attrs %]> [% PROCESS inner_content %] </button>
[%- ELSE -%]
    <a [% PROCESS common_attrs %] href="[% href | html %]"> [% PROCESS inner_content %] </a>
[%- END %]
