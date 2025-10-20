<fieldset id="resource-standard-fieldset" class="rows">
    <legend>Generic resource details</legend>
    <ol id="resource-standard-fields">
        [% PROCESS ill_text_input_field id = 'title' label = t('Title') value = whole.value.other.title %]
        [% PROCESS ill_text_input_field id = 'author' label = t('Author') value = whole.value.other.author %]
        [% PROCESS ill_text_input_field id = 'editor' label = t('Editor') value = whole.value.other.editor %]
        [% PROCESS ill_text_input_field id = 'publisher' label = t('Publisher') value = whole.value.other.publisher %]
        [% PROCESS ill_text_input_field id = 'published_place' label = t('Place of publication') value = whole.value.other.published_place %]
        [% PROCESS ill_text_input_field id = 'year' label = t('Year') value = whole.value.other.year %]
        [% PROCESS ill_text_input_field id = 'part_edition' label = t('Part / Edition') value = whole.value.other.part_edition %]
        [% PROCESS ill_text_input_field id = 'volume' label = t('Volume') value = whole.value.other.volume %]
        [% PROCESS ill_text_input_field id = 'pages' label = t('Pages') value = whole.value.other.pages %]
        [% PROCESS ill_text_input_field id = 'isbn' label = t('ISBN') value = whole.value.other.isbn %]
        [% PROCESS ill_text_input_field id = 'issn' label = t('ISSN') value = whole.value.other.issn %]
        [% PROCESS ill_text_input_field id = 'eissn' label = t('eISSN') value = whole.value.other.eissn %]
        [% PROCESS ill_text_input_field id = 'doi' label = t('DOI') value = whole.value.other.doi %]
    </ol>
</fieldset>
