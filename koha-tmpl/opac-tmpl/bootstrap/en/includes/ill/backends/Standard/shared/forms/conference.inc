<fieldset id="conference-standard-fieldset" class="rows">
    <legend>Conference details</legend>
    <ol id="conference-standard-fields">
        [% PROCESS ill_text_input_field id = 'title' label = t('Conference title') value = whole.value.other.title %]
        [% PROCESS ill_text_input_field id = 'publication' label = t('Publication') value = whole.value.other.publication %]
        [% PROCESS ill_text_input_field id = 'conference_date' label = t('Conference date') value = whole.value.other.conference_date %]
        [% PROCESS ill_text_input_field id = 'venue' label = t('Venue') value = whole.value.other.venue %]
        [% PROCESS ill_text_input_field id = 'sponsor' label = t('Sponsor') value = whole.value.other.sponsor %]
        [% PROCESS ill_text_input_field id = 'volume' label = t('Volume') value = whole.value.other.volume %]
        [% PROCESS ill_text_input_field id = 'isbn' label = t('ISBN') value = whole.value.other.isbn %]
        [% PROCESS ill_text_input_field id = 'issn' label = t('ISSN') value = whole.value.other.issn %]
        [% PROCESS ill_text_input_field id = 'eissn' label = t('eISSN') value = whole.value.other.eissn %]
        [% PROCESS ill_text_input_field id = 'part_edition' label = t('Part') value = whole.value.other.part_edition %]
        [% PROCESS ill_text_input_field id = 'paper_title' label = t('Paper title') value = whole.value.other.paper_title %]
        [% PROCESS ill_text_input_field id = 'paper_author' label = t('Paper author') value = whole.value.other.paper_author %]
    </ol>
</fieldset>
