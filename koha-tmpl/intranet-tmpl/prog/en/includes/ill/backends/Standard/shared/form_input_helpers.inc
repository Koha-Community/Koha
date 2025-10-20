[% USE raw %]
[% BLOCK ill_text_input_field %]
    <li>
        <label for="[% id | html %]">[% label | html %]:</label>
        [% IF opac %]
            <input class="form-control input-fluid" type="text" name="[% id | html %]" id="[% id | html %]" value="[% value | html %]" />
        [% ELSE %]
            <input type="text" name="[% id | html %]" id="[% id | html %]" value="[% value | html %]" />
        [% END %]
        [% IF required %]
            <div class="required_label required">Required</div>
        [% END %]
        [% SET required = 0 %]
    </li>
[% END %]

[% BLOCK ill_select_field %]
    <li>
        <label for="[% id | html %]">[% label | html %]:</label>
        [% IF opac %]
            <select class="form-select input-fluid" name="[% id | html %]" id="[% id | html %]"
                >[% content | $raw %]</select
            >
        [% ELSE %]
            <select name="[% id | html %]" id="[% id | html %]"
                >[% content | $raw %]</select
            >
        [% END %]

        [% IF required %]
            <div class="required_label required">Required</div>
        [% END %]
        [% SET required = 0 %]
    </li>
[% END %]

[% BLOCK book_text_input_fields %]
    [% PROCESS ill_text_input_field id = 'title' label = t('Title') value = whole.value.other.title %]
    [% PROCESS ill_text_input_field id = 'author' label = t('Author') value = whole.value.other.author %]
    [% PROCESS ill_text_input_field id = 'editor' label = t('Editor') value = whole.value.other.editor %]
    [% PROCESS ill_text_input_field id = 'publisher' label = t('Publisher') value = whole.value.other.publisher %]
    [% PROCESS ill_text_input_field id = 'published_place' label = t('Place of publication') value = whole.value.other.published_place %]
    [% PROCESS ill_text_input_field id = 'year' label = t('Year') value = whole.value.other.year %]
    [% PROCESS ill_text_input_field id = 'part_edition' label = t('Part / Edition') value = whole.value.other.part_edition %]
    [% PROCESS ill_text_input_field id = 'volume' label = t('Volume') value = whole.value.other.volume %]
    [% PROCESS ill_text_input_field id = 'isbn' label = t('ISBN') value = whole.value.other.isbn %]
    [% PROCESS ill_text_input_field id = 'doi' label = t('DOI') value = whole.value.other.doi %]
[% END %]

[% BLOCK journal_text_input_fields %]
    [% PROCESS ill_text_input_field id = 'title' label = t('Title') value = whole.value.other.title %]
    [% PROCESS ill_text_input_field id = 'publisher' label = t('Publisher') value = whole.value.other.publisher %]
    [% PROCESS ill_text_input_field id = 'volume' label = t('Volume') value = whole.value.other.volume %]
    [% PROCESS ill_text_input_field id = 'issue' label = t('Issue number') value = whole.value.other.issue %]
    [% PROCESS ill_text_input_field id = 'year' label = t('Year') value = whole.value.other.year %]
    [% PROCESS ill_text_input_field id = 'issn' label = t('ISSN') value = whole.value.other.issn %]
    [% PROCESS ill_text_input_field id = 'eissn' label = t('eISSN') value = whole.value.other.eissn %]
[% END %]
