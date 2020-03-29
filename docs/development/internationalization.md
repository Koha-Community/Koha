# Internationalization

This page documents how internationalization works in Koha.

## Making strings translatable

There are several ways of making a string translatable, depending on where it
is located

### In Template::Toolkit files (`*.tt`)

The simplest way to make a string translatable in a template is to do nothing.
Templates are parsed as HTML files and almost all text nodes are considered as
translatable strings. This also includes some attributes like `title` and
`placeholder`.

This method has some downsides: you don't have full control over what would
appear in PO files and you cannot use plural forms or context. In order to do
that you have to use `i18n.inc`

`i18n.inc` contains several macros that, when used, make a string translatable.
The first thing to do is to make these macros available by adding

    [% PROCESS 'i18n.inc' %]

at the top of the template file. Then you can use those macros.

The simplest one is `t(msgid)`

    [% t('This is a translatable string') %]

You can also use variable substitution with `tx(msgid, vars)`

    [% tx('Hello, {name}', { name = 'World' }) %]

You can use plural forms with `tn(msgid, msgid_plural, count)`

    [% tn('a child', 'several children', number_of_children) %]

You can add context, to help translators when a term is ambiguous, with
`tp(msgctxt, msgid)`

    [% tp('verb', 'order') %]
    [% tp('noun', 'order') %]

Or any combinations of the above

    [% tnpx('bibliographic record', '{count} item', '{count} items', items_count, { count = items_count }) %]

### In JavaScript files (`*.js`)

Like in templates, you have several functions available. Just replace `t` by `__`.

    __('This is a translatable string');
    __npx('bibliographic record, '{count} item', '{count} items', items_count, { count: items_count });

### In Perl files (`*.pl`, `*.pm`)

You will have to add

    use Koha::I18N;

at the top of the file, and then the same functions as above will be available.

    __('This is a translatable string');
    __npx('bibliographic record, '{count} item', '{count} items', $items_count, count => $items_count);

### In installer and preferences YAML files (`*.yml`)

Nothing special to do here. All strings will be automatically translatable.

## Manipulating PO files

Once strings have been made translatable in source files, they have to be
extracted into PO files and uploaded on https://translate.koha-community.org/
so they can be translated.

### Install gulp first

The next sections rely on gulp. If it's not installed, run the following
commands:

    # as root
    npm install gulp-cli -g

    # as normal user, from the root of Koha repository
    yarn

### Create PO files for a new language

If you want to add translations for a new language, you have to create the
missing PO files. You can do that by executing the following command:

    # Replace xx-XX by your language tag
    gulp po:create --lang xx-XX

New PO files will be available in `misc/translator/po`.

### Update PO files with new strings

When new features or bugfixes are added to Koha, new translatable strings can
be added, other can be removed or modified, and the PO file become out of sync.

To be able to translate the new or modified strings, you have to update PO
files. This can be done by executing the following command:

    # Update PO files for all languages
    gulp po:update

    # or only one language
    gulp po:update --lang xx-XX

### Only extract strings

Creating or updating PO files automatically extract strings, but if for some
reasons you want to only extract strings without touching PO files, you can run
the following command:

    gulp po:extract

POT files will be available in `misc/translator`.
