[% IF filters && filters.size > 0 %]
    [% filter_class = filter_class || 'filters' %]

    <fieldset class="action filters filters-[% filter_class | html %] d-flex gap-2">
        [% FOREACH filter IN filters %]
            <a id="[% filter.id | html %]" data-filter="[% filter.id | html %]" [% IF !filter.defined('active') || filter.active %]data-filtered[% END %]>
                <span><i class="fa fa-bars"></i> [% filter.label_show | html %]</span>
                <span><i class="fa fa-filter"></i> [% filter.label_hide | html %]</span>
            </a>
        [% END %]
    </fieldset>
[% END %]
