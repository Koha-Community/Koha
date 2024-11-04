<fieldset id="dvd-standard-fieldset" class="rows">
    <legend>DVD details</legend>
    <ol id="dvd-standard-fields">
        [% PROCESS ill_text_input_field id = 'title' label = t('Title') value = whole.value.other.title %]
        [% PROCESS ill_text_input_field id = 'author' label = t('Author') value = whole.value.other.author %]
        [% PROCESS ill_text_input_field id = 'studio' label = t('Studio') value = whole.value.other.studio %]
        [% PROCESS ill_text_input_field id = 'genre' label = t('Genre') value = whole.value.other.genre %]
        [% PROCESS ill_text_input_field id = 'year' label = t('Year') value = whole.value.other.year %]
        [% PROCESS ill_text_input_field id = 'format' label = t('Format') value = whole.value.other.format %]
        [% PROCESS ill_text_input_field id = 'language' label = t('Language') value = whole.value.other.language %]
    </ol>
</fieldset>
