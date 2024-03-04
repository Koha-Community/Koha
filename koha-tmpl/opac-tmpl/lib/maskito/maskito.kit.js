//import { maskitoUpdateElement, MASKITO_DEFAULT_OPTIONS, maskitoTransform } from '@maskito/core';

const DEFAULT_DECIMAL_PSEUDO_SEPARATORS = ['.', ',', 'б', 'ю'];

const DEFAULT_MIN_DATE = new Date('0001-01-01');
const DEFAULT_MAX_DATE = new Date('9999-12-31');

const DEFAULT_TIME_SEGMENT_MAX_VALUES = {
    hours: 23,
    minutes: 59,
    seconds: 59,
    milliseconds: 999,
};

/**
 * {@link https://unicode-table.com/en/00A0/ Non-breaking space}.
 */
const CHAR_NO_BREAK_SPACE = '\u00A0';
/**
 * {@link https://symbl.cc/en/200B/ Zero width space}.
 */
const CHAR_ZERO_WIDTH_SPACE = '\u200B';
/**
 * {@link https://unicode-table.com/en/2013/ EN dash}
 * is used to indicate a range of numbers or a span of time.
 * @example 2006–2022
 */
const CHAR_EN_DASH = '\u2013';
/**
 * {@link https://unicode-table.com/en/2014/ EM dash}
 * is used to mark a break in a sentence.
 * @example Taiga UI — powerful set of open source components for Angular
 * ___
 * Don't confuse with {@link CHAR_EN_DASH} or {@link CHAR_HYPHEN}!
 */
const CHAR_EM_DASH = '\u2014';
/**
 * {@link https://unicode-table.com/en/002D/ Hyphen (minus sign)}
 * is used to combine words.
 * @example well-behaved
 * ___
 * Don't confuse with {@link CHAR_EN_DASH} or {@link CHAR_EM_DASH}!
 */
const CHAR_HYPHEN = '\u002D';
/**
 * {@link https://unicode-table.com/en/2212/ Minus}
 * is used as math operator symbol or before negative digits.
 * ---
 * Can be used as `&minus;`. Don't confuse with {@link CHAR_HYPHEN}
 */
const CHAR_MINUS = '\u2212';
/**
 * {@link https://symbl.cc/en/30FC/ Katakana-Hiragana Prolonged Sound Mark}
 * is used as prolonged sounds in Japanese.
 */
const CHAR_JP_HYPHEN = '\u30FC';

const POSSIBLE_DATE_RANGE_SEPARATOR = [
    CHAR_HYPHEN,
    CHAR_EN_DASH,
    CHAR_EM_DASH,
    CHAR_MINUS,
];
const POSSIBLE_DATE_TIME_SEPARATOR = [',', ' '];

const TIME_FIXED_CHARACTERS = [':', '.'];

const TIME_SEGMENT_VALUE_LENGTHS = {
    hours: 2,
    minutes: 2,
    seconds: 2,
    milliseconds: 3,
};

/**
 * Clamps a value between two inclusive limits
 *
 * @param value
 * @param min lower limit
 * @param max upper limit
 */
function clamp(value, min, max) {
    const clampedValue = Math.min(Number(max), Math.max(Number(min), Number(value)));
    return (value instanceof Date ? new Date(clampedValue) : clampedValue);
}

function appendDate(initialDate, { day, month, year } = {}) {
    const date = new Date(initialDate);
    if (day) {
        date.setDate(date.getDate() + day);
    }
    if (month) {
        date.setMonth(date.getMonth() + month);
    }
    if (year) {
        date.setFullYear(date.getFullYear() + year);
    }
    return date;
}

const getDateSegmentValueLength = (dateString) => {
    var _a, _b, _c;
    return ({
        day: ((_a = dateString.match(/d/g)) === null || _a === void 0 ? void 0 : _a.length) || 0,
        month: ((_b = dateString.match(/m/g)) === null || _b === void 0 ? void 0 : _b.length) || 0,
        year: ((_c = dateString.match(/y/g)) === null || _c === void 0 ? void 0 : _c.length) || 0,
    });
};

function dateToSegments(date) {
    return {
        day: String(date.getDate()).padStart(2, '0'),
        month: String(date.getMonth() + 1).padStart(2, '0'),
        year: String(date.getFullYear()).padStart(4, '0'),
        hours: String(date.getHours()).padStart(2, '0'),
        minutes: String(date.getMinutes()).padStart(2, '0'),
        seconds: String(date.getSeconds()).padStart(2, '0'),
        milliseconds: String(date.getMilliseconds()).padStart(3, '0'),
    };
}

function isDateStringComplete(dateString, dateModeTemplate) {
    if (dateString.length < dateModeTemplate.length) {
        return false;
    }
    return dateString.split(/\D/).every(segment => !segment.match(/^0+$/));
}

function parseDateRangeString(dateRange, dateModeTemplate, rangeSeparator) {
    const digitsInDate = dateModeTemplate.replace(/\W/g, '').length;
    return (dateRange
        .replace(rangeSeparator, '')
        .match(new RegExp(`(\\D*\\d[^\\d\\s]*){1,${digitsInDate}}`, 'g')) || []);
}

function parseDateString(dateString, fullMode) {
    const cleanMode = fullMode.replace(/[^dmy]/g, '');
    const onlyDigitsDate = dateString.replace(/\D+/g, '');
    const dateSegments = {
        day: onlyDigitsDate.slice(cleanMode.indexOf('d'), cleanMode.lastIndexOf('d') + 1),
        month: onlyDigitsDate.slice(cleanMode.indexOf('m'), cleanMode.lastIndexOf('m') + 1),
        year: onlyDigitsDate.slice(cleanMode.indexOf('y'), cleanMode.lastIndexOf('y') + 1),
    };
    return Object.fromEntries(Object.entries(dateSegments)
        .filter(([_, value]) => Boolean(value))
        .sort(([a], [b]) => fullMode.toLowerCase().indexOf(a[0]) >
        fullMode.toLowerCase().indexOf(b[0])
        ? 1
        : -1));
}

function segmentsToDate(parsedDate, parsedTime) {
    var _a, _b, _c, _d, _e, _f, _g;
    const year = ((_a = parsedDate.year) === null || _a === void 0 ? void 0 : _a.length) === 2 ? `20${parsedDate.year}` : parsedDate.year;
    const date = new Date(Number(year !== null && year !== void 0 ? year : '0'), Number((_b = parsedDate.month) !== null && _b !== void 0 ? _b : '1') - 1, Number((_c = parsedDate.day) !== null && _c !== void 0 ? _c : '1'), Number((_d = parsedTime === null || parsedTime === void 0 ? void 0 : parsedTime.hours) !== null && _d !== void 0 ? _d : '0'), Number((_e = parsedTime === null || parsedTime === void 0 ? void 0 : parsedTime.minutes) !== null && _e !== void 0 ? _e : '0'), Number((_f = parsedTime === null || parsedTime === void 0 ? void 0 : parsedTime.seconds) !== null && _f !== void 0 ? _f : '0'), Number((_g = parsedTime === null || parsedTime === void 0 ? void 0 : parsedTime.milliseconds) !== null && _g !== void 0 ? _g : '0'));
    // needed for years less than 1900
    date.setFullYear(Number(year !== null && year !== void 0 ? year : '0'));
    return date;
}

const DATE_TIME_SEPARATOR = ', ';

function toDateString({ day, month, year, hours, minutes, seconds, milliseconds, }, dateMode, timeMode) {
    var _a;
    const safeYear = ((_a = dateMode.match(/y/g)) === null || _a === void 0 ? void 0 : _a.length) === 2 ? year === null || year === void 0 ? void 0 : year.slice(-2) : year;
    const fullMode = dateMode + (timeMode ? DATE_TIME_SEPARATOR + timeMode : '');
    return fullMode
        .replace(/d+/g, day !== null && day !== void 0 ? day : '')
        .replace(/m+/g, month !== null && month !== void 0 ? month : '')
        .replace(/y+/g, safeYear !== null && safeYear !== void 0 ? safeYear : '')
        .replace(/H+/g, hours !== null && hours !== void 0 ? hours : '')
        .replace(/MSS/g, milliseconds !== null && milliseconds !== void 0 ? milliseconds : '')
        .replace(/M+/g, minutes !== null && minutes !== void 0 ? minutes : '')
        .replace(/S+/g, seconds !== null && seconds !== void 0 ? seconds : '')
        .replace(/^\D+/g, '')
        .replace(/\D+$/g, '');
}

function padWithZeroesUntilValid(segmentValue, paddedMaxValue, prefixedZeroesCount = 0) {
    if (Number(segmentValue.padEnd(paddedMaxValue.length, '0')) <= Number(paddedMaxValue)) {
        return { validatedSegmentValue: segmentValue, prefixedZeroesCount };
    }
    if (segmentValue.endsWith('0')) {
        // 00:|00 => Type 9 => 00:09|
        return padWithZeroesUntilValid(`0${segmentValue.slice(0, paddedMaxValue.length - 1)}`, paddedMaxValue, prefixedZeroesCount + 1);
    }
    // |19:00 => Type 2 => 2|0:00
    return padWithZeroesUntilValid(`${segmentValue.slice(0, paddedMaxValue.length - 1)}0`, paddedMaxValue, prefixedZeroesCount);
}

const dateMaxValues = {
    day: 31,
    month: 12,
    year: 9999,
};
function validateDateString({ dateString, dateModeTemplate, offset, selection: [from, to], }) {
    const parsedDate = parseDateString(dateString, dateModeTemplate);
    const dateSegments = Object.entries(parsedDate);
    const validatedDateSegments = {};
    let paddedZeroes = 0;
    for (const [segmentName, segmentValue] of dateSegments) {
        const validatedDate = toDateString(validatedDateSegments, dateModeTemplate);
        const maxSegmentValue = dateMaxValues[segmentName];
        const fantomSeparator = validatedDate.length && 1;
        const lastSegmentDigitIndex = offset +
            validatedDate.length +
            fantomSeparator +
            getDateSegmentValueLength(dateModeTemplate)[segmentName];
        const isLastSegmentDigitAdded = lastSegmentDigitIndex >= from && lastSegmentDigitIndex === to;
        if (isLastSegmentDigitAdded && Number(segmentValue) > Number(maxSegmentValue)) {
            // 3|1.10.2010 => Type 9 => 3|1.10.2010
            return { validatedDateString: '', updatedSelection: [from, to] }; // prevent changes
        }
        if (isLastSegmentDigitAdded && Number(segmentValue) < 1) {
            // 31.0|1.2010 => Type 0 => 31.0|1.2010
            return { validatedDateString: '', updatedSelection: [from, to] }; // prevent changes
        }
        const { validatedSegmentValue, prefixedZeroesCount } = padWithZeroesUntilValid(segmentValue, `${maxSegmentValue}`);
        paddedZeroes += prefixedZeroesCount;
        validatedDateSegments[segmentName] = validatedSegmentValue;
    }
    const validatedDateString = toDateString(validatedDateSegments, dateModeTemplate);
    const addedDateSegmentSeparators = validatedDateString.length - dateString.length;
    return {
        validatedDateString,
        updatedSelection: [
            from + paddedZeroes + addedDateSegmentSeparators,
            to + paddedZeroes + addedDateSegmentSeparators,
        ],
    };
}

/**
 * Copy-pasted solution from lodash
 * @see https://lodash.com/docs/4.17.15#escapeRegExp
 */
const reRegExpChar = /[\\^$.*+?()[\]{}|]/g;
const reHasRegExpChar = new RegExp(reRegExpChar.source);
function escapeRegExp(str) {
    return str && reHasRegExpChar.test(str) ? str.replace(reRegExpChar, '\\$&') : str;
}

function extractAffixes(value, { prefix, postfix }) {
    var _a, _b;
    const prefixRegExp = new RegExp(`^${escapeRegExp(prefix)}`);
    const postfixRegExp = new RegExp(`${escapeRegExp(postfix)}$`);
    const [extractedPrefix = ''] = (_a = value.match(prefixRegExp)) !== null && _a !== void 0 ? _a : [];
    const [extractedPostfix = ''] = (_b = value.match(postfixRegExp)) !== null && _b !== void 0 ? _b : [];
    const cleanValue = value.replace(prefixRegExp, '').replace(postfixRegExp, '');
    return { extractedPrefix, extractedPostfix, cleanValue };
}

function findCommonBeginningSubstr(a, b) {
    let res = '';
    for (let i = 0; i < a.length; i++) {
        if (a[i] !== b[i]) {
            return res;
        }
        res += a[i];
    }
    return res;
}

/**
 * Returns current active element, including shadow dom
 *
 * @return element or null
 */
function getFocused({ activeElement }) {
    if (!(activeElement === null || activeElement === void 0 ? void 0 : activeElement.shadowRoot)) {
        return activeElement;
    }
    let element = activeElement.shadowRoot.activeElement;
    while (element === null || element === void 0 ? void 0 : element.shadowRoot) {
        element = element.shadowRoot.activeElement;
    }
    return element;
}

function identity(x) {
    return x;
}

function isEmpty(entity) {
    return !entity || (typeof entity === 'object' && Object.keys(entity).length === 0);
}

function raiseSegmentValueToMin(segments, fullMode) {
    const segmentsLength = getDateSegmentValueLength(fullMode);
    return Object.fromEntries(Object.entries(segments).map(([key, value]) => {
        const segmentLength = segmentsLength[key];
        return [
            key,
            value.length === segmentLength && value.match(/^0+$/)
                ? '1'.padStart(segmentLength, '0')
                : value,
        ];
    }));
}

function createMinMaxDatePostprocessor({ dateModeTemplate, min = DEFAULT_MIN_DATE, max = DEFAULT_MAX_DATE, rangeSeparator = '', dateSegmentSeparator = '.', }) {
    return ({ value, selection }) => {
        const endsWithRangeSeparator = rangeSeparator && value.endsWith(rangeSeparator);
        const dateStrings = parseDateRangeString(value, dateModeTemplate, rangeSeparator);
        let validatedValue = '';
        for (const dateString of dateStrings) {
            validatedValue += validatedValue ? rangeSeparator : '';
            const parsedDate = parseDateString(dateString, dateModeTemplate);
            if (!isDateStringComplete(dateString, dateModeTemplate)) {
                const fixedDate = raiseSegmentValueToMin(parsedDate, dateModeTemplate);
                const fixedValue = toDateString(fixedDate, dateModeTemplate);
                const tail = dateString.endsWith(dateSegmentSeparator)
                    ? dateSegmentSeparator
                    : '';
                validatedValue += fixedValue + tail;
                continue;
            }
            const date = segmentsToDate(parsedDate);
            const clampedDate = clamp(date, min, max);
            validatedValue += toDateString(dateToSegments(clampedDate), dateModeTemplate);
        }
        return {
            selection,
            value: validatedValue + (endsWithRangeSeparator ? rangeSeparator : ''),
        };
    };
}

function normalizeDatePreprocessor({ dateModeTemplate, dateSegmentsSeparator, rangeSeparator = '', }) {
    return ({ elementState, data }) => {
        const separator = rangeSeparator
            ? new RegExp(`${rangeSeparator}|-`)
            : DATE_TIME_SEPARATOR;
        const possibleDates = data.split(separator);
        const dates = data.includes(DATE_TIME_SEPARATOR)
            ? [possibleDates[0]]
            : possibleDates;
        if (dates.every(date => date.trim().split(/\D/).length ===
            dateModeTemplate.split(dateSegmentsSeparator).length)) {
            const newData = dates
                .map(date => normalizeDateString(date, dateModeTemplate, dateSegmentsSeparator))
                .join(rangeSeparator);
            return {
                elementState,
                data: `${newData}${data.includes(DATE_TIME_SEPARATOR)
                    ? DATE_TIME_SEPARATOR + possibleDates[1] || ''
                    : ''}`,
            };
        }
        return { elementState, data };
    };
}
function normalizeDateString(dateString, template, separator) {
    const dateSegments = dateString.split(/\D/);
    const templateSegments = template.split(separator);
    const normalizedSegments = dateSegments.map((segment, index) => index === templateSegments.length - 1
        ? segment
        : segment.padStart(templateSegments[index].length, '0'));
    return normalizedSegments.join(separator);
}

function maskitoPostfixPostprocessorGenerator(postfix) {
    const postfixRE = new RegExp(`${escapeRegExp(postfix)}$`);
    return postfix
        ? ({ value, selection }, initialElementState) => {
            if (!value && !initialElementState.value.endsWith(postfix)) {
                // cases when developer wants input to be empty (programmatically)
                return { value, selection };
            }
            if (!value.endsWith(postfix) &&
                !initialElementState.value.endsWith(postfix)) {
                return { selection, value: value + postfix };
            }
            const initialValueBeforePostfix = initialElementState.value.replace(postfixRE, '');
            const postfixWasModified = initialElementState.selection[1] >= initialValueBeforePostfix.length;
            const alreadyExistedValueBeforePostfix = findCommonBeginningSubstr(initialValueBeforePostfix, value);
            return {
                selection,
                value: Array.from(postfix)
                    .reverse()
                    .reduce((newValue, char, index) => {
                    const i = newValue.length - 1 - index;
                    const isInitiallyMirroredChar = alreadyExistedValueBeforePostfix[i] === char &&
                        postfixWasModified;
                    return newValue[i] !== char || isInitiallyMirroredChar
                        ? newValue.slice(0, i + 1) + char + newValue.slice(i + 1)
                        : newValue;
                }, value),
            };
        }
        : identity;
}

function maskitoPrefixPostprocessorGenerator(prefix) {
    return prefix
        ? ({ value, selection }, initialElementState) => {
            if (value.startsWith(prefix) || // already valid
                (!value && !initialElementState.value.startsWith(prefix)) // cases when developer wants input to be empty
            ) {
                return { value, selection };
            }
            const [from, to] = selection;
            const prefixedValue = Array.from(prefix).reduce((modifiedValue, char, i) => modifiedValue[i] === char
                ? modifiedValue
                : modifiedValue.slice(0, i) + char + modifiedValue.slice(i), value);
            const addedCharsCount = prefixedValue.length - value.length;
            return {
                selection: [from + addedCharsCount, to + addedCharsCount],
                value: prefixedValue,
            };
        }
        : identity;
}

function createValidDatePreprocessor({ dateModeTemplate, dateSegmentsSeparator, rangeSeparator = '', }) {
    return ({ elementState, data }) => {
        const { value, selection } = elementState;
        if (data === dateSegmentsSeparator) {
            return {
                elementState,
                data: selection[0] === value.length ? data : '',
            };
        }
        if (POSSIBLE_DATE_RANGE_SEPARATOR.includes(data)) {
            return { elementState, data: rangeSeparator };
        }
        const newCharacters = data.replace(new RegExp(`[^\\d${escapeRegExp(dateSegmentsSeparator)}${rangeSeparator}]`, 'g'), '');
        if (!newCharacters) {
            return { elementState, data: '' };
        }
        const [from, rawTo] = selection;
        let to = rawTo + data.length;
        const newPossibleValue = value.slice(0, from) + newCharacters + value.slice(to);
        const dateStrings = parseDateRangeString(newPossibleValue, dateModeTemplate, rangeSeparator);
        let validatedValue = '';
        const hasRangeSeparator = Boolean(rangeSeparator) && newPossibleValue.includes(rangeSeparator);
        for (const dateString of dateStrings) {
            const { validatedDateString, updatedSelection } = validateDateString({
                dateString,
                dateModeTemplate,
                offset: validatedValue
                    ? validatedValue.length + rangeSeparator.length
                    : 0,
                selection: [from, to],
            });
            if (dateString && !validatedDateString) {
                return { elementState, data: '' }; // prevent changes
            }
            to = updatedSelection[1];
            validatedValue +=
                hasRangeSeparator && validatedValue
                    ? rangeSeparator + validatedDateString
                    : validatedDateString;
        }
        const newData = validatedValue.slice(from, to);
        return {
            elementState: {
                selection,
                value: validatedValue.slice(0, from) +
                    newData
                        .split(dateSegmentsSeparator)
                        .map(segment => '0'.repeat(segment.length))
                        .join(dateSegmentsSeparator) +
                    validatedValue.slice(to),
            },
            data: newData,
        };
    };
}

function maskitoEventHandler(name, handler, eventListenerOptions) {
    return (element, maskitoOptions) => {
        const listener = () => handler(element, maskitoOptions);
        element.addEventListener(name, listener, eventListenerOptions);
        return () => element.removeEventListener(name, listener, eventListenerOptions);
    };
}

function maskitoAddOnFocusPlugin(value) {
    return maskitoEventHandler('focus', element => {
        if (!element.value) {
            maskitoUpdateElement(element, value);
        }
    });
}

function maskitoCaretGuard(guard) {
    return element => {
        const document = element.ownerDocument;
        let isPointerDown = 0;
        const onPointerDown = () => isPointerDown++;
        const onPointerUp = () => {
            isPointerDown = Math.max(--isPointerDown, 0);
        };
        const listener = () => {
            if (getFocused(document) !== element) {
                return;
            }
            if (isPointerDown) {
                return document.addEventListener('mouseup', listener, {
                    once: true,
                    passive: true,
                });
            }
            const start = element.selectionStart || 0;
            const end = element.selectionEnd || 0;
            const [fromLimit, toLimit] = guard(element.value, [start, end]);
            if (fromLimit > start || toLimit < end) {
                element.setSelectionRange(clamp(start, fromLimit, toLimit), clamp(end, fromLimit, toLimit));
            }
        };
        document.addEventListener('selectionchange', listener, { passive: true });
        element.addEventListener('mousedown', onPointerDown, { passive: true });
        document.addEventListener('mouseup', onPointerUp, { passive: true });
        return () => {
            document.removeEventListener('selectionchange', listener);
            document.removeEventListener('mousedown', onPointerDown);
            document.removeEventListener('mouseup', onPointerUp);
        };
    };
}

function maskitoRejectEvent(element) {
    const listener = () => {
        const value = element.value;
        element.addEventListener('beforeinput', event => {
            if (event.defaultPrevented && value === element.value) {
                element.dispatchEvent(new CustomEvent('maskitoReject', { bubbles: true }));
            }
        }, { once: true });
    };
    element.addEventListener('beforeinput', listener, true);
    return () => element.removeEventListener('beforeinput', listener, true);
}

function maskitoRemoveOnBlurPlugin(value) {
    return maskitoEventHandler('blur', element => {
        if (element.value === value) {
            maskitoUpdateElement(element, '');
        }
    });
}

function maskitoWithPlaceholder(placeholder, focusedOnly = false) {
    const removePlaceholder = (value) => {
        for (let i = value.length - 1; i >= 0; i--) {
            if (value[i] !== placeholder[i]) {
                return value.slice(0, i + 1);
            }
        }
        return '';
    };
    const plugins = [maskitoCaretGuard(value => [0, removePlaceholder(value).length])];
    let focused = false;
    if (focusedOnly) {
        const focus = maskitoEventHandler('focus', element => {
            focused = true;
            maskitoUpdateElement(element, element.value + placeholder.slice(element.value.length));
        }, { capture: true });
        const blur = maskitoEventHandler('blur', element => {
            focused = false;
            maskitoUpdateElement(element, removePlaceholder(element.value));
        }, { capture: true });
        plugins.push(focus, blur);
    }
    return {
        plugins,
        removePlaceholder,
        preprocessors: [
            ({ elementState, data }) => {
                const { value, selection } = elementState;
                return {
                    elementState: {
                        selection,
                        value: removePlaceholder(value),
                    },
                    data,
                };
            },
        ],
        postprocessors: [
            ({ value, selection }, initialElementState) =>
            /**
             * If `value` still equals to `initialElementState.value`,
             * then it means that value is patched programmatically (from Maskito's plugin or externally).
             * In this case, we don't want to mutate value and automatically add placeholder.
             * ___
             * For example, developer wants to remove manually placeholder (+ do something else with value) on blur.
             * Without this condition, placeholder will be unexpectedly added again.
             */
            value !== initialElementState.value && (focused || !focusedOnly)
                ? {
                    value: value + placeholder.slice(value.length),
                    selection,
                }
                : { value, selection },
        ],
    };
}

function createZeroPlaceholdersPreprocessor() {
    return ({ elementState }, actionType) => {
        const { value, selection } = elementState;
        if (!value || isLastChar(value, selection)) {
            return { elementState };
        }
        const [from, to] = selection;
        const zeroes = value.slice(from, to).replace(/\d/g, '0');
        const newValue = value.slice(0, from) + zeroes + value.slice(to);
        if (actionType === 'validation' || (actionType === 'insert' && from === to)) {
            return {
                elementState: { selection, value: newValue },
            };
        }
        return {
            elementState: {
                selection: actionType === 'deleteBackward' || actionType === 'insert'
                    ? [from, from]
                    : [to, to],
                value: newValue,
            },
        };
    };
}
function isLastChar(value, [_, to]) {
    return to === value.length;
}

function maskitoDateOptionsGenerator({ mode, separator = '.', max, min, }) {
    const dateModeTemplate = mode.split('/').join(separator);
    return Object.assign(Object.assign({}, MASKITO_DEFAULT_OPTIONS), { mask: Array.from(dateModeTemplate).map(char => char === separator ? char : /\d/), overwriteMode: 'replace', preprocessors: [
            createZeroPlaceholdersPreprocessor(),
            normalizeDatePreprocessor({
                dateModeTemplate,
                dateSegmentsSeparator: separator,
            }),
            createValidDatePreprocessor({
                dateModeTemplate,
                dateSegmentsSeparator: separator,
            }),
        ], postprocessors: [
            createMinMaxDatePostprocessor({
                min,
                max,
                dateModeTemplate,
                dateSegmentSeparator: separator,
            }),
        ] });
}

function createMinMaxRangeLengthPostprocessor({ dateModeTemplate, rangeSeparator, minLength, maxLength, max = DEFAULT_MAX_DATE, }) {
    if (isEmpty(minLength) && isEmpty(maxLength)) {
        return identity;
    }
    return ({ value, selection }) => {
        const dateStrings = parseDateRangeString(value, dateModeTemplate, rangeSeparator);
        if (dateStrings.length !== 2 ||
            dateStrings.some(date => !isDateStringComplete(date, dateModeTemplate))) {
            return { value, selection };
        }
        const [fromDate, toDate] = dateStrings.map(dateString => segmentsToDate(parseDateString(dateString, dateModeTemplate)));
        const minDistantToDate = appendDate(fromDate, Object.assign(Object.assign({}, minLength), {
            // 06.02.2023 - 07.02.2023 => {minLength: {day: 3}} => 06.02.2023 - 08.02.2023
            // "from"-day is included in the range
            day: (minLength === null || minLength === void 0 ? void 0 : minLength.day) && minLength.day - 1 }));
        const maxDistantToDate = !isEmpty(maxLength)
            ? appendDate(fromDate, Object.assign(Object.assign({}, maxLength), { day: (maxLength === null || maxLength === void 0 ? void 0 : maxLength.day) && maxLength.day - 1 }))
            : max;
        const minLengthClampedToDate = clamp(toDate, minDistantToDate, max);
        const minMaxLengthClampedToDate = minLengthClampedToDate > maxDistantToDate
            ? maxDistantToDate
            : minLengthClampedToDate;
        return {
            selection,
            value: dateStrings[0] +
                rangeSeparator +
                toDateString(dateToSegments(minMaxLengthClampedToDate), dateModeTemplate),
        };
    };
}

function createSwapDatesPostprocessor({ dateModeTemplate, rangeSeparator, }) {
    return ({ value, selection }) => {
        const dateStrings = parseDateRangeString(value, dateModeTemplate, rangeSeparator);
        const isDateRangeComplete = dateStrings.length === 2 &&
            dateStrings.every(date => isDateStringComplete(date, dateModeTemplate));
        const [from, to] = selection;
        const caretAtTheEnd = from >= value.length;
        const allValueSelected = from === 0 && to >= value.length; // dropping text inside with a pointer
        if (!(caretAtTheEnd || allValueSelected) || !isDateRangeComplete) {
            return { value, selection };
        }
        const [fromDate, toDate] = dateStrings.map(dateString => segmentsToDate(parseDateString(dateString, dateModeTemplate)));
        return {
            selection,
            value: fromDate > toDate ? dateStrings.reverse().join(rangeSeparator) : value,
        };
    };
}

function maskitoDateRangeOptionsGenerator({ mode, min, max, minLength, maxLength, dateSeparator = '.', rangeSeparator = `${CHAR_NO_BREAK_SPACE}${CHAR_EN_DASH}${CHAR_NO_BREAK_SPACE}`, }) {
    const dateModeTemplate = mode.split('/').join(dateSeparator);
    const dateMask = Array.from(dateModeTemplate).map(char => char === dateSeparator ? char : /\d/);
    return Object.assign(Object.assign({}, MASKITO_DEFAULT_OPTIONS), { mask: [...dateMask, ...Array.from(rangeSeparator), ...dateMask], overwriteMode: 'replace', preprocessors: [
            createZeroPlaceholdersPreprocessor(),
            normalizeDatePreprocessor({
                dateModeTemplate,
                rangeSeparator,
                dateSegmentsSeparator: dateSeparator,
            }),
            createValidDatePreprocessor({
                dateModeTemplate,
                rangeSeparator,
                dateSegmentsSeparator: dateSeparator,
            }),
        ], postprocessors: [
            createMinMaxDatePostprocessor({
                min,
                max,
                dateModeTemplate,
                rangeSeparator,
                dateSegmentSeparator: dateSeparator,
            }),
            createMinMaxRangeLengthPostprocessor({
                dateModeTemplate,
                minLength,
                maxLength,
                max,
                rangeSeparator,
            }),
            createSwapDatesPostprocessor({
                dateModeTemplate,
                rangeSeparator,
            }),
        ] });
}

function padTimeSegments(timeSegments) {
    return Object.fromEntries(Object.entries(timeSegments).map(([segmentName, segmentValue]) => [
        segmentName,
        `${segmentValue}`.padEnd(TIME_SEGMENT_VALUE_LENGTHS[segmentName], '0'),
    ]));
}

/**
 * @param timeString can be with/without fixed characters
 */
function parseTimeString(timeString) {
    const onlyDigits = timeString.replace(/\D+/g, '');
    const timeSegments = {
        hours: onlyDigits.slice(0, 2),
        minutes: onlyDigits.slice(2, 4),
        seconds: onlyDigits.slice(4, 6),
        milliseconds: onlyDigits.slice(6, 9),
    };
    return Object.fromEntries(Object.entries(timeSegments).filter(([_, value]) => Boolean(value)));
}

function toTimeString({ hours = '', minutes = '', seconds = '', milliseconds = '', }) {
    const mm = minutes && `:${minutes}`;
    const ss = seconds && `:${seconds}`;
    const ms = milliseconds && `.${milliseconds}`;
    return `${hours}${mm}${ss}${ms}`;
}

const TRAILING_TIME_SEGMENT_SEPARATOR_REG = new RegExp(`[${TIME_FIXED_CHARACTERS.map(escapeRegExp).join('')}]$`);
function validateTimeString({ timeString, paddedMaxValues, offset, selection: [from, to], }) {
    const parsedTime = parseTimeString(timeString);
    const possibleTimeSegments = Object.entries(parsedTime);
    const validatedTimeSegments = {};
    let paddedZeroes = 0;
    for (const [segmentName, segmentValue] of possibleTimeSegments) {
        const validatedTime = toTimeString(validatedTimeSegments);
        const maxSegmentValue = paddedMaxValues[segmentName];
        const fantomSeparator = validatedTime.length && 1;
        const lastSegmentDigitIndex = offset +
            validatedTime.length +
            fantomSeparator +
            TIME_SEGMENT_VALUE_LENGTHS[segmentName];
        const isLastSegmentDigitAdded = lastSegmentDigitIndex >= from && lastSegmentDigitIndex <= to;
        if (isLastSegmentDigitAdded && Number(segmentValue) > Number(maxSegmentValue)) {
            // 2|0:00 => Type 9 => 2|0:00
            return { validatedTimeString: '', updatedTimeSelection: [from, to] }; // prevent changes
        }
        const { validatedSegmentValue, prefixedZeroesCount } = padWithZeroesUntilValid(segmentValue, `${maxSegmentValue}`);
        paddedZeroes += prefixedZeroesCount;
        validatedTimeSegments[segmentName] = validatedSegmentValue;
    }
    const [trailingSegmentSeparator = ''] = timeString.match(TRAILING_TIME_SEGMENT_SEPARATOR_REG) || [];
    const validatedTimeString = toTimeString(validatedTimeSegments) + trailingSegmentSeparator;
    const addedDateSegmentSeparators = Math.max(validatedTimeString.length - timeString.length, 0);
    return {
        validatedTimeString,
        updatedTimeSelection: [
            from + paddedZeroes + addedDateSegmentSeparators,
            to + paddedZeroes + addedDateSegmentSeparators,
        ],
    };
}

function isDateTimeStringComplete(dateTimeString, dateMode, timeMode) {
    return (dateTimeString.length >=
        dateMode.length + timeMode.length + DATE_TIME_SEPARATOR.length &&
        dateTimeString
            .split(DATE_TIME_SEPARATOR)[0]
            .split(/\D/)
            .every(segment => !segment.match(/^0+$/)));
}

function parseDateTimeString(dateTime, dateModeTemplate) {
    const hasSeparator = dateTime.includes(DATE_TIME_SEPARATOR);
    return [
        dateTime.slice(0, dateModeTemplate.length),
        dateTime.slice(hasSeparator
            ? dateModeTemplate.length + DATE_TIME_SEPARATOR.length
            : dateModeTemplate.length),
    ];
}

function createMinMaxDateTimePostprocessor({ dateModeTemplate, timeMode, min = DEFAULT_MIN_DATE, max = DEFAULT_MAX_DATE, }) {
    return ({ value, selection }) => {
        const [dateString, timeString] = parseDateTimeString(value, dateModeTemplate);
        const parsedDate = parseDateString(dateString, dateModeTemplate);
        const parsedTime = parseTimeString(timeString);
        if (!isDateTimeStringComplete(value, dateModeTemplate, timeMode)) {
            const fixedDate = raiseSegmentValueToMin(parsedDate, dateModeTemplate);
            const { year, month, day } = isDateStringComplete(dateString, dateModeTemplate)
                ? dateToSegments(clamp(segmentsToDate(fixedDate), min, max))
                : fixedDate;
            const fixedValue = toDateString(Object.assign({ year,
                month,
                day }, parsedTime), dateModeTemplate, timeMode);
            const tail = value.slice(fixedValue.length);
            return {
                selection,
                value: fixedValue + tail,
            };
        }
        const date = segmentsToDate(parsedDate, parsedTime);
        const clampedDate = clamp(date, min, max);
        const validatedValue = toDateString(dateToSegments(clampedDate), dateModeTemplate, timeMode);
        return {
            selection,
            value: validatedValue,
        };
    };
}

function createValidDateTimePreprocessor({ dateModeTemplate, dateSegmentsSeparator, }) {
    const invalidCharsRegExp = new RegExp(`[^\\d${TIME_FIXED_CHARACTERS.map(escapeRegExp).join('')}${escapeRegExp(dateSegmentsSeparator)}]+`);
    return ({ elementState, data }) => {
        const { value, selection } = elementState;
        if (data === dateSegmentsSeparator) {
            return {
                elementState,
                data: selection[0] === value.length ? data : '',
            };
        }
        if (POSSIBLE_DATE_TIME_SEPARATOR.includes(data)) {
            return { elementState, data: DATE_TIME_SEPARATOR };
        }
        const newCharacters = data.replace(invalidCharsRegExp, '');
        if (!newCharacters) {
            return { elementState, data: '' };
        }
        const [from, rawTo] = selection;
        let to = rawTo + data.length;
        const newPossibleValue = value.slice(0, from) + newCharacters + value.slice(to);
        const [dateString, timeString] = parseDateTimeString(newPossibleValue, dateModeTemplate);
        let validatedValue = '';
        const hasDateTimeSeparator = newPossibleValue.includes(DATE_TIME_SEPARATOR);
        const { validatedDateString, updatedSelection } = validateDateString({
            dateString,
            dateModeTemplate,
            offset: 0,
            selection: [from, to],
        });
        if (dateString && !validatedDateString) {
            return { elementState, data: '' }; // prevent changes
        }
        to = updatedSelection[1];
        validatedValue += validatedDateString;
        const paddedMaxValues = padTimeSegments(DEFAULT_TIME_SEGMENT_MAX_VALUES);
        const { validatedTimeString, updatedTimeSelection } = validateTimeString({
            timeString,
            paddedMaxValues,
            offset: validatedValue.length + DATE_TIME_SEPARATOR.length,
            selection: [from, to],
        });
        if (timeString && !validatedTimeString) {
            return { elementState, data: '' }; // prevent changes
        }
        to = updatedTimeSelection[1];
        validatedValue += hasDateTimeSeparator
            ? DATE_TIME_SEPARATOR + validatedTimeString
            : validatedTimeString;
        const newData = validatedValue.slice(from, to);
        return {
            elementState: {
                selection,
                value: validatedValue.slice(0, from) +
                    newData
                        .split(dateSegmentsSeparator)
                        .map(segment => '0'.repeat(segment.length))
                        .join(dateSegmentsSeparator) +
                    validatedValue.slice(to),
            },
            data: newData,
        };
    };
}

function maskitoDateTimeOptionsGenerator({ dateMode, timeMode, dateSeparator = '.', min, max, }) {
    const dateModeTemplate = dateMode.split('/').join(dateSeparator);
    return Object.assign(Object.assign({}, MASKITO_DEFAULT_OPTIONS), { mask: [
            ...Array.from(dateModeTemplate).map(char => char === dateSeparator ? char : /\d/),
            ...DATE_TIME_SEPARATOR.split(''),
            ...Array.from(timeMode).map(char => TIME_FIXED_CHARACTERS.includes(char) ? char : /\d/),
        ], overwriteMode: 'replace', preprocessors: [
            createZeroPlaceholdersPreprocessor(),
            normalizeDatePreprocessor({
                dateModeTemplate,
                dateSegmentsSeparator: dateSeparator,
            }),
            createValidDateTimePreprocessor({
                dateModeTemplate,
                dateSegmentsSeparator: dateSeparator,
            }),
        ], postprocessors: [
            createMinMaxDateTimePostprocessor({
                min,
                max,
                dateModeTemplate,
                timeMode,
            }),
        ] });
}

/**
 * It drops prefix and postfix from data
 * Needed for case, when prefix or postfix contain decimalSeparator, to ignore it in resulting number
 * @example User pastes '{prefix}123.45{postfix}' => 123.45
 */
function createAffixesFilterPreprocessor({ prefix, postfix, }) {
    return ({ elementState, data }) => {
        const { cleanValue: cleanData } = extractAffixes(data, {
            prefix,
            postfix,
        });
        return {
            elementState,
            data: cleanData,
        };
    };
}

function generateMaskExpression({ decimalSeparator, isNegativeAllowed, precision, thousandSeparator, prefix, postfix, decimalPseudoSeparators = [], pseudoMinuses = [], }) {
    const computedPrefix = computeAllOptionalCharsRegExp(prefix);
    const digit = '\\d';
    const optionalMinus = isNegativeAllowed
        ? `[${CHAR_MINUS}${pseudoMinuses.map(x => `\\${x}`).join('')}]?`
        : '';
    const integerPart = thousandSeparator
        ? `[${digit}${escapeRegExp(thousandSeparator).replace(/\s/g, '\\s')}]*`
        : `[${digit}]*`;
    const decimalPart = precision > 0
        ? `([${escapeRegExp(decimalSeparator)}${decimalPseudoSeparators
            .map(escapeRegExp)
            .join('')}]${digit}{0,${Number.isFinite(precision) ? precision : ''}})?`
        : '';
    const computedPostfix = computeAllOptionalCharsRegExp(postfix);
    return new RegExp(`^${computedPrefix}${optionalMinus}${integerPart}${decimalPart}${computedPostfix}$`);
}
function computeAllOptionalCharsRegExp(str) {
    return str
        ? `${str
            .split('')
            .map(char => `${escapeRegExp(char)}?`)
            .join('')}`
        : '';
}

function maskitoParseNumber(maskedNumber, decimalSeparator = '.') {
    const hasNegativeSign = !!maskedNumber.match(new RegExp(`^\\D*[${CHAR_MINUS}\\${CHAR_HYPHEN}${CHAR_EN_DASH}${CHAR_EM_DASH}]`));
    const escapedDecimalSeparator = escapeRegExp(decimalSeparator);
    const unmaskedNumber = maskedNumber
        // drop all decimal separators not followed by a digit
        .replace(new RegExp(`${escapedDecimalSeparator}(?!\\d)`, 'g'), '')
        // drop all non-digit characters except decimal separator
        .replace(new RegExp(`[^\\d${escapedDecimalSeparator}]`, 'g'), '')
        .replace(decimalSeparator, '.');
    return unmaskedNumber
        ? Number((hasNegativeSign ? CHAR_HYPHEN : '') + unmaskedNumber)
        : NaN;
}

/**
 * Convert number to string with replacing exponent part on decimals
 *
 * @param value the number
 * @return string representation of a number
 */
function stringifyNumberWithoutExp(value) {
    const valueAsString = String(value);
    const [numberPart, expPart] = valueAsString.split('e-');
    let valueWithoutExp = valueAsString;
    if (expPart) {
        const [, fractionalPart] = numberPart.split('.');
        const decimalDigits = Number(expPart) + ((fractionalPart === null || fractionalPart === void 0 ? void 0 : fractionalPart.length) || 0);
        valueWithoutExp = value.toFixed(decimalDigits);
    }
    return valueWithoutExp;
}

function validateDecimalPseudoSeparators({ decimalSeparator, thousandSeparator, decimalPseudoSeparators = DEFAULT_DECIMAL_PSEUDO_SEPARATORS, }) {
    return decimalPseudoSeparators.filter(char => char !== thousandSeparator && char !== decimalSeparator);
}

/**
 * If `decimalZeroPadding` is `true`, it pads decimal part with zeroes
 * (until number of digits after decimalSeparator is equal to the `precision`).
 * @example 1,42 => (`precision` is equal to 4) => 1,4200.
 */
function createDecimalZeroPaddingPostprocessor({ decimalSeparator, precision, decimalZeroPadding, prefix, postfix, }) {
    if (precision <= 0 || !decimalZeroPadding) {
        return identity;
    }
    return ({ value, selection }) => {
        const { cleanValue, extractedPrefix, extractedPostfix } = extractAffixes(value, {
            prefix,
            postfix,
        });
        if (Number.isNaN(maskitoParseNumber(cleanValue, decimalSeparator))) {
            return { value, selection };
        }
        const [integerPart, decimalPart = ''] = cleanValue.split(decimalSeparator);
        return {
            value: extractedPrefix +
                integerPart +
                decimalSeparator +
                decimalPart.padEnd(precision, '0') +
                extractedPostfix,
            selection,
        };
    };
}

/**
 * Replace fullwidth numbers with half width number
 * @param fullWidthNumber full width number
 * @returns processed half width number
 */
function toHalfWidthNumber(fullWidthNumber) {
    return fullWidthNumber.replace(/[０-９]/g, s => String.fromCharCode(s.charCodeAt(0) - 0xfee0));
}

/**
 * Convert full width numbers like １, ２ to half width numbers 1, 2
 */
function createFullWidthToHalfWidthPreprocessor() {
    return ({ elementState, data }) => {
        const { value, selection } = elementState;
        return {
            elementState: {
                selection,
                value: toHalfWidthNumber(value),
            },
            data: toHalfWidthNumber(data),
        };
    };
}

/**
 * This preprocessor works only once at initialization phase (when `new Maskito(...)` is executed).
 * This preprocessor helps to avoid conflicts during transition from one mask to another (for the same input).
 * For example, the developer changes postfix (or other mask's props) during run-time.
 * ```
 * let maskitoOptions = maskitoNumberOptionsGenerator({postfix: ' year'});
 * // [3 seconds later]
 * maskitoOptions = maskitoNumberOptionsGenerator({postfix: ' years'});
 * ```
 */
function createInitializationOnlyPreprocessor({ decimalSeparator, decimalPseudoSeparators, pseudoMinuses, prefix, postfix, }) {
    let isInitializationPhase = true;
    const cleanNumberMask = generateMaskExpression({
        decimalSeparator,
        decimalPseudoSeparators,
        pseudoMinuses,
        prefix: '',
        postfix: '',
        thousandSeparator: '',
        precision: Infinity,
        isNegativeAllowed: true,
    });
    return ({ elementState, data }) => {
        if (!isInitializationPhase) {
            return { elementState, data };
        }
        isInitializationPhase = false;
        const { cleanValue } = extractAffixes(elementState.value, { prefix, postfix });
        return {
            elementState: maskitoTransform(Object.assign(Object.assign({}, elementState), { value: cleanValue }), {
                mask: cleanNumberMask,
            }),
            data,
        };
    };
}

/**
 * It removes repeated leading zeroes for integer part.
 * @example 0,|00005 => Backspace => |5
 * @example -0,|00005 => Backspace => -|5
 * @example User types "000000" => 0|
 * @example 0| => User types "5" => 5|
 */
function createLeadingZeroesValidationPostprocessor({ decimalSeparator, thousandSeparator, prefix, postfix, }) {
    const trimLeadingZeroes = (value) => {
        const escapedThousandSeparator = escapeRegExp(thousandSeparator);
        return value
            .replace(
        // all leading zeroes followed by another zero
        new RegExp(`^(\\D+)?[0${escapedThousandSeparator}]+(?=0)`), '$1')
            .replace(
        // zero followed by not-zero digit
        new RegExp(`^(\\D+)?[0${escapedThousandSeparator}]+(?=[1-9])`), '$1');
    };
    const countTrimmedZeroesBefore = (value, index) => {
        const valueBefore = value.slice(0, index);
        const followedByZero = value.slice(index).startsWith('0');
        return (valueBefore.length -
            trimLeadingZeroes(valueBefore).length +
            (followedByZero ? 1 : 0));
    };
    return ({ value, selection }) => {
        const [from, to] = selection;
        const { cleanValue, extractedPrefix, extractedPostfix } = extractAffixes(value, {
            prefix,
            postfix,
        });
        const hasDecimalSeparator = cleanValue.includes(decimalSeparator);
        const [integerPart, decimalPart = ''] = cleanValue.split(decimalSeparator);
        const zeroTrimmedIntegerPart = trimLeadingZeroes(integerPart);
        if (integerPart === zeroTrimmedIntegerPart) {
            return { value, selection };
        }
        const newFrom = from - countTrimmedZeroesBefore(value, from);
        const newTo = to - countTrimmedZeroesBefore(value, to);
        return {
            value: extractedPrefix +
                zeroTrimmedIntegerPart +
                (hasDecimalSeparator ? decimalSeparator : '') +
                decimalPart +
                extractedPostfix,
            selection: [Math.max(newFrom, 0), Math.max(newTo, 0)],
        };
    };
}

/**
 * This postprocessor is connected with {@link createMinMaxPlugin}:
 * both validate `min`/`max` bounds of entered value (but at the different point of time).
 */
function createMinMaxPostprocessor({ min, max, decimalSeparator, }) {
    return ({ value, selection }) => {
        const parsedNumber = maskitoParseNumber(value, decimalSeparator);
        const limitedValue =
        /**
         * We cannot limit lower bound if user enters positive number.
         * The same for upper bound and negative number.
         * ___
         * @example (min = 5)
         * Empty input => Without this condition user cannot type 42 (the first digit will be rejected)
         * ___
         * @example (max = -10)
         * Value is -10 => Without this condition user cannot delete 0 to enter another digit
         */
        parsedNumber > 0 ? Math.min(parsedNumber, max) : Math.max(parsedNumber, min);
        if (!Number.isNaN(parsedNumber) && limitedValue !== parsedNumber) {
            const newValue = `${limitedValue}`
                .replace('.', decimalSeparator)
                .replace(CHAR_HYPHEN, CHAR_MINUS);
            return {
                value: newValue,
                selection: [newValue.length, newValue.length],
            };
        }
        return {
            value,
            selection,
        };
    };
}

/**
 * Manage caret-navigation when user "deletes" non-removable digits or separators
 * @example 1,|42 => Backspace => 1|,42 (only if `decimalZeroPadding` is `true`)
 * @example 1|,42 => Delete => 1,|42 (only if `decimalZeroPadding` is `true`)
 * @example 0,|00 => Delete => 0,0|0 (only if `decimalZeroPadding` is `true`)
 * @example 1 |000 => Backspace => 1| 000 (always)
 */
function createNonRemovableCharsDeletionPreprocessor({ decimalSeparator, thousandSeparator, decimalZeroPadding, }) {
    return ({ elementState, data }, actionType) => {
        const { value, selection } = elementState;
        const [from, to] = selection;
        const selectedCharacters = value.slice(from, to);
        const nonRemovableSeparators = decimalZeroPadding
            ? [decimalSeparator, thousandSeparator]
            : [thousandSeparator];
        const areNonRemovableZeroesSelected = decimalZeroPadding &&
            from > value.indexOf(decimalSeparator) &&
            Boolean(selectedCharacters.match(/^0+$/gi));
        if ((actionType !== 'deleteBackward' && actionType !== 'deleteForward') ||
            (!nonRemovableSeparators.includes(selectedCharacters) &&
                !areNonRemovableZeroesSelected)) {
            return {
                elementState,
                data,
            };
        }
        return {
            elementState: {
                value,
                selection: actionType === 'deleteForward' ? [to, to] : [from, from],
            },
            data,
        };
    };
}

/**
 * It pads integer part with zero if user types decimal separator (for empty input).
 * @example Empty input => User types "," (decimal separator) => 0,|
 */
function createNotEmptyIntegerPartPreprocessor({ decimalSeparator, precision, prefix, postfix, }) {
    const startWithDecimalSepRegExp = new RegExp(`^\\D*${escapeRegExp(decimalSeparator)}`);
    return ({ elementState, data }) => {
        const { value, selection } = elementState;
        const { cleanValue } = extractAffixes(value, {
            prefix,
            postfix,
        });
        const [from] = selection;
        if (precision <= 0 ||
            cleanValue.includes(decimalSeparator) ||
            !data.match(startWithDecimalSepRegExp)) {
            return { elementState, data };
        }
        const digitsBeforeCursor = cleanValue.slice(0, from).match(/\d+/);
        return {
            elementState,
            data: digitsBeforeCursor ? data : `0${data}`,
        };
    };
}

/**
 * It replaces pseudo characters with valid one.
 * @example User types '.' (but separator is equal to comma) => dot is replaced with comma.
 * @example User types hyphen / en-dash / em-dash => it is replaced with minus.
 */
function createPseudoCharactersPreprocessor({ validCharacter, pseudoCharacters, prefix, postfix, }) {
    const pseudoCharactersRegExp = new RegExp(`[${pseudoCharacters.join('')}]`, 'gi');
    return ({ elementState, data }) => {
        const { value, selection } = elementState;
        const { cleanValue, extractedPostfix, extractedPrefix } = extractAffixes(value, {
            prefix,
            postfix,
        });
        return {
            elementState: {
                selection,
                value: extractedPrefix +
                    cleanValue.replace(pseudoCharactersRegExp, validCharacter) +
                    extractedPostfix,
            },
            data: data.replace(pseudoCharactersRegExp, validCharacter),
        };
    };
}

/**
 * It rejects new typed decimal separator if it already exists in text field.
 * Behaviour is similar to native <input type="number"> (Chrome).
 * @example 1|23,45 => Press comma (decimal separator) => 1|23,45 (do nothing).
 */
function createRepeatedDecimalSeparatorPreprocessor({ decimalSeparator, prefix, postfix, }) {
    return ({ elementState, data }) => {
        const { value, selection } = elementState;
        const [from, to] = selection;
        const { cleanValue } = extractAffixes(value, { prefix, postfix });
        return {
            elementState,
            data: !cleanValue.includes(decimalSeparator) ||
                value.slice(from, to + 1).includes(decimalSeparator)
                ? data
                : data.replace(new RegExp(escapeRegExp(decimalSeparator), 'gi'), ''),
        };
    };
}

/**
 * It adds symbol for separating thousands.
 * @example 1000000 => (thousandSeparator is equal to space) => 1 000 000.
 */
function createThousandSeparatorPostprocessor({ thousandSeparator, decimalSeparator, prefix, postfix, }) {
    if (!thousandSeparator) {
        return identity;
    }
    const isAllSpaces = (...chars) => chars.every(x => /\s/.test(x));
    return ({ value, selection }) => {
        const { cleanValue, extractedPostfix, extractedPrefix } = extractAffixes(value, {
            prefix,
            postfix,
        });
        const [integerPart, decimalPart = ''] = cleanValue
            .replace(CHAR_MINUS, '')
            .split(decimalSeparator);
        const [initialFrom, initialTo] = selection;
        let [from, to] = selection;
        const processedIntegerPart = Array.from(integerPart).reduceRight((formattedValuePart, char, i) => {
            const isLeadingThousandSeparator = !i && char === thousandSeparator;
            const isPositionForSeparator = !isLeadingThousandSeparator &&
                formattedValuePart.length &&
                (formattedValuePart.length + 1) % 4 === 0;
            if (isPositionForSeparator &&
                (char === thousandSeparator || isAllSpaces(char, thousandSeparator))) {
                return thousandSeparator + formattedValuePart;
            }
            if (char === thousandSeparator && !isPositionForSeparator) {
                if (i && i <= initialFrom) {
                    from--;
                }
                if (i && i <= initialTo) {
                    to--;
                }
                return formattedValuePart;
            }
            if (!isPositionForSeparator) {
                return char + formattedValuePart;
            }
            if (i <= initialFrom) {
                from++;
            }
            if (i <= initialTo) {
                to++;
            }
            return char + thousandSeparator + formattedValuePart;
        }, '');
        return {
            value: extractedPrefix +
                (cleanValue.includes(CHAR_MINUS) ? CHAR_MINUS : '') +
                processedIntegerPart +
                (cleanValue.includes(decimalSeparator) ? decimalSeparator : '') +
                decimalPart +
                extractedPostfix,
            selection: [from, to],
        };
    };
}

/**
 * It drops decimal part if precision is zero.
 * @example User pastes '123.45' (but precision is zero) => 123
 */
function createZeroPrecisionPreprocessor({ precision, decimalSeparator, prefix, postfix, }) {
    if (precision > 0) {
        return identity;
    }
    const decimalPartRegExp = new RegExp(`${escapeRegExp(decimalSeparator)}.*$`, 'g');
    return ({ elementState, data }) => {
        const { value, selection } = elementState;
        const { cleanValue, extractedPrefix, extractedPostfix } = extractAffixes(value, {
            prefix,
            postfix,
        });
        const [from, to] = selection;
        const newValue = extractedPrefix +
            cleanValue.replace(decimalPartRegExp, '') +
            extractedPostfix;
        return {
            elementState: {
                selection: [
                    Math.min(from, newValue.length),
                    Math.min(to, newValue.length),
                ],
                value: newValue,
            },
            data: data.replace(decimalPartRegExp, ''),
        };
    };
}

const DUMMY_SELECTION = [0, 0];
/**
 * It removes repeated leading zeroes for integer part on blur-event.
 * @example 000000 => blur => 0
 * @example 00005 => blur => 5
 */
function createLeadingZeroesValidationPlugin({ decimalSeparator, thousandSeparator, prefix, postfix, }) {
    const dropRepeatedLeadingZeroes = createLeadingZeroesValidationPostprocessor({
        decimalSeparator,
        thousandSeparator,
        prefix,
        postfix,
    });
    return maskitoEventHandler('blur', element => {
        const newValue = dropRepeatedLeadingZeroes({
            value: element.value,
            selection: DUMMY_SELECTION,
        }, { value: '', selection: DUMMY_SELECTION }).value;
        if (element.value !== newValue) {
            maskitoUpdateElement(element, newValue);
        }
    }, { capture: true });
}

/**
 * This plugin is connected with {@link createMinMaxPostprocessor}:
 * both validate `min`/`max` bounds of entered value (but at the different point of time).
 */
function createMinMaxPlugin({ min, max, decimalSeparator, }) {
    return maskitoEventHandler('blur', (element, options) => {
        const parsedNumber = maskitoParseNumber(element.value, decimalSeparator);
        const clampedNumber = clamp(parsedNumber, min, max);
        if (!Number.isNaN(parsedNumber) && parsedNumber !== clampedNumber) {
            maskitoUpdateElement(element, maskitoTransform(stringifyNumberWithoutExp(clampedNumber), options));
        }
    }, { capture: true });
}

/**
 * It pads EMPTY integer part with zero if decimal parts exists.
 * It works on blur event only!
 * @example 1|,23 => Backspace => Blur => 0,23
 */
function createNotEmptyIntegerPlugin({ decimalSeparator, prefix, postfix, }) {
    return maskitoEventHandler('blur', element => {
        const { cleanValue, extractedPostfix, extractedPrefix } = extractAffixes(element.value, { prefix, postfix });
        const newValue = extractedPrefix +
            cleanValue.replace(new RegExp(`^(\\D+)?${escapeRegExp(decimalSeparator)}`), `$10${decimalSeparator}`) +
            extractedPostfix;
        if (newValue !== element.value) {
            maskitoUpdateElement(element, newValue);
        }
    }, { capture: true });
}

function maskitoNumberOptionsGenerator({ max = Number.MAX_SAFE_INTEGER, min = Number.MIN_SAFE_INTEGER, precision = 0, thousandSeparator = CHAR_NO_BREAK_SPACE, decimalSeparator = '.', decimalPseudoSeparators, decimalZeroPadding = false, prefix: unsafePrefix = '', postfix = '', } = {}) {
    const pseudoMinuses = [
        CHAR_HYPHEN,
        CHAR_EN_DASH,
        CHAR_EM_DASH,
        CHAR_JP_HYPHEN,
    ].filter(char => char !== thousandSeparator && char !== decimalSeparator);
    const validatedDecimalPseudoSeparators = validateDecimalPseudoSeparators({
        decimalSeparator,
        thousandSeparator,
        decimalPseudoSeparators,
    });
    const prefix = unsafePrefix.endsWith(decimalSeparator) && precision > 0
        ? `${unsafePrefix}${CHAR_ZERO_WIDTH_SPACE}`
        : unsafePrefix;
    return Object.assign(Object.assign({}, MASKITO_DEFAULT_OPTIONS), { mask: generateMaskExpression({
            decimalSeparator,
            precision,
            thousandSeparator,
            prefix,
            postfix,
            isNegativeAllowed: min < 0,
        }), preprocessors: [
            createInitializationOnlyPreprocessor({
                decimalSeparator,
                decimalPseudoSeparators: validatedDecimalPseudoSeparators,
                pseudoMinuses,
                prefix,
                postfix,
            }),
            createAffixesFilterPreprocessor({ prefix, postfix }),
            createFullWidthToHalfWidthPreprocessor(),
            createPseudoCharactersPreprocessor({
                validCharacter: CHAR_MINUS,
                pseudoCharacters: pseudoMinuses,
                prefix,
                postfix,
            }),
            createPseudoCharactersPreprocessor({
                validCharacter: decimalSeparator,
                pseudoCharacters: validatedDecimalPseudoSeparators,
                prefix,
                postfix,
            }),
            createNotEmptyIntegerPartPreprocessor({
                decimalSeparator,
                precision,
                prefix,
                postfix,
            }),
            createNonRemovableCharsDeletionPreprocessor({
                decimalSeparator,
                decimalZeroPadding,
                thousandSeparator,
            }),
            createZeroPrecisionPreprocessor({
                precision,
                decimalSeparator,
                prefix,
                postfix,
            }),
            createRepeatedDecimalSeparatorPreprocessor({
                decimalSeparator,
                prefix,
                postfix,
            }),
        ], postprocessors: [
            createMinMaxPostprocessor({ decimalSeparator, min, max }),
            maskitoPrefixPostprocessorGenerator(prefix),
            maskitoPostfixPostprocessorGenerator(postfix),
            createThousandSeparatorPostprocessor({
                decimalSeparator,
                thousandSeparator,
                prefix,
                postfix,
            }),
            createDecimalZeroPaddingPostprocessor({
                decimalSeparator,
                decimalZeroPadding,
                precision,
                prefix,
                postfix,
            }),
        ], plugins: [
            createLeadingZeroesValidationPlugin({
                decimalSeparator,
                thousandSeparator,
                prefix,
                postfix,
            }),
            createNotEmptyIntegerPlugin({
                decimalSeparator,
                prefix,
                postfix,
            }),
            createMinMaxPlugin({ min, max, decimalSeparator }),
        ], overwriteMode: decimalZeroPadding
            ? ({ value, selection: [from] }) => from <= value.indexOf(decimalSeparator) ? 'shift' : 'replace'
            : 'shift' });
}

function createMaxValidationPreprocessor(timeSegmentMaxValues) {
    const paddedMaxValues = padTimeSegments(timeSegmentMaxValues);
    const invalidCharsRegExp = new RegExp(`[^\\d${TIME_FIXED_CHARACTERS.map(escapeRegExp).join('')}]+`);
    return ({ elementState, data }, actionType) => {
        if (actionType === 'deleteBackward' || actionType === 'deleteForward') {
            return { elementState, data };
        }
        const { value, selection } = elementState;
        if (actionType === 'validation') {
            const { validatedTimeString, updatedTimeSelection } = validateTimeString({
                timeString: value,
                paddedMaxValues,
                offset: 0,
                selection,
            });
            return {
                elementState: {
                    value: validatedTimeString,
                    selection: updatedTimeSelection,
                },
                data,
            };
        }
        const newCharacters = data.replace(invalidCharsRegExp, '');
        const [from, rawTo] = selection;
        let to = rawTo + newCharacters.length; // to be conformed with `overwriteMode: replace`
        const newPossibleValue = value.slice(0, from) + newCharacters + value.slice(to);
        const { validatedTimeString, updatedTimeSelection } = validateTimeString({
            timeString: newPossibleValue,
            paddedMaxValues,
            offset: 0,
            selection: [from, to],
        });
        if (newPossibleValue && !validatedTimeString) {
            return { elementState, data: '' }; // prevent changes
        }
        to = updatedTimeSelection[1];
        const newData = validatedTimeString.slice(from, to);
        return {
            elementState: {
                selection,
                value: validatedTimeString.slice(0, from) +
                    '0'.repeat(newData.length) +
                    validatedTimeString.slice(to),
            },
            data: newData,
        };
    };
}

function maskitoTimeOptionsGenerator({ mode, timeSegmentMaxValues = {}, }) {
    const enrichedTimeSegmentMaxValues = Object.assign(Object.assign({}, DEFAULT_TIME_SEGMENT_MAX_VALUES), timeSegmentMaxValues);
    return Object.assign(Object.assign({}, MASKITO_DEFAULT_OPTIONS), { mask: Array.from(mode).map(char => TIME_FIXED_CHARACTERS.includes(char) ? char : /\d/), preprocessors: [
            createZeroPlaceholdersPreprocessor(),
            createMaxValidationPreprocessor(enrichedTimeSegmentMaxValues),
        ], overwriteMode: 'replace' });
}

//export { maskitoAddOnFocusPlugin, maskitoCaretGuard, maskitoDateOptionsGenerator, maskitoDateRangeOptionsGenerator, maskitoDateTimeOptionsGenerator, maskitoEventHandler, maskitoNumberOptionsGenerator, maskitoParseNumber, maskitoPostfixPostprocessorGenerator, maskitoPrefixPostprocessorGenerator, maskitoRejectEvent, maskitoRemoveOnBlurPlugin, maskitoTimeOptionsGenerator, maskitoWithPlaceholder };
