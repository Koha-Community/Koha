const MASKITO_DEFAULT_ELEMENT_PREDICATE = e => e.querySelector('input,textarea') ||
    e;

const MASKITO_DEFAULT_OPTIONS = {
    mask: /^.*$/,
    preprocessors: [],
    postprocessors: [],
    plugins: [],
    overwriteMode: 'shift',
};

class MaskHistory {
    constructor() {
        this.now = null;
        this.past = [];
        this.future = [];
    }
    undo() {
        const state = this.past.pop();
        if (state && this.now) {
            this.future.push(this.now);
            this.updateElement(state, 'historyUndo');
        }
    }
    redo() {
        const state = this.future.pop();
        if (state && this.now) {
            this.past.push(this.now);
            this.updateElement(state, 'historyRedo');
        }
    }
    updateHistory(state) {
        if (!this.now) {
            this.now = state;
            return;
        }
        const isValueChanged = this.now.value !== state.value;
        const isSelectionChanged = this.now.selection.some((item, index) => item !== state.selection[index]);
        if (!isValueChanged && !isSelectionChanged) {
            return;
        }
        if (isValueChanged) {
            this.past.push(this.now);
            this.future = [];
        }
        this.now = state;
    }
    updateElement(state, inputType) {
        this.now = state;
        this.updateElementState(state, { inputType, data: null });
    }
}

function areElementValuesEqual(sampleState, ...states) {
    return states.every(({ value }) => value === sampleState.value);
}
function areElementStatesEqual(sampleState, ...states) {
    return states.every(({ value, selection }) => value === sampleState.value &&
        selection[0] === sampleState.selection[0] &&
        selection[1] === sampleState.selection[1]);
}

function applyOverwriteMode({ value, selection }, newCharacters, mode) {
    const [from, to] = selection;
    const computedMode = typeof mode === 'function' ? mode({ value, selection }) : mode;
    return {
        value,
        selection: computedMode === 'replace' ? [from, from + newCharacters.length] : [from, to],
    };
}

function isFixedCharacter(char) {
    return typeof char === 'string';
}

function getLeadingFixedCharacters(mask, validatedValuePart, newCharacter, initialElementState) {
    let leadingFixedCharacters = '';
    for (let i = validatedValuePart.length; i < mask.length; i++) {
        const charConstraint = mask[i];
        const isInitiallyExisted = (initialElementState === null || initialElementState === void 0 ? void 0 : initialElementState.value[i]) === charConstraint;
        if (!isFixedCharacter(charConstraint) ||
            (charConstraint === newCharacter && !isInitiallyExisted)) {
            return leadingFixedCharacters;
        }
        leadingFixedCharacters += charConstraint;
    }
    return leadingFixedCharacters;
}

function validateValueWithMask(value, maskExpression) {
    if (Array.isArray(maskExpression)) {
        return (value.length === maskExpression.length &&
            Array.from(value).every((char, i) => {
                const charConstraint = maskExpression[i];
                return isFixedCharacter(charConstraint)
                    ? char === charConstraint
                    : char.match(charConstraint);
            }));
    }
    return maskExpression.test(value);
}

function guessValidValueByPattern(elementState, mask, initialElementState) {
    let maskedFrom = null;
    let maskedTo = null;
    const maskedValue = Array.from(elementState.value).reduce((validatedCharacters, char, charIndex) => {
        const leadingCharacters = getLeadingFixedCharacters(mask, validatedCharacters, char, initialElementState);
        const newValidatedChars = validatedCharacters + leadingCharacters;
        const charConstraint = mask[newValidatedChars.length];
        if (isFixedCharacter(charConstraint)) {
            return newValidatedChars + charConstraint;
        }
        if (!char.match(charConstraint)) {
            return newValidatedChars;
        }
        if (maskedFrom === null && charIndex >= elementState.selection[0]) {
            maskedFrom = newValidatedChars.length;
        }
        if (maskedTo === null && charIndex >= elementState.selection[1]) {
            maskedTo = newValidatedChars.length;
        }
        return newValidatedChars + char;
    }, '');
    const trailingFixedCharacters = getLeadingFixedCharacters(mask, maskedValue, '', initialElementState);
    return {
        value: validateValueWithMask(maskedValue + trailingFixedCharacters, mask)
            ? maskedValue + trailingFixedCharacters
            : maskedValue,
        selection: [maskedFrom !== null && maskedFrom !== void 0 ? maskedFrom : maskedValue.length, maskedTo !== null && maskedTo !== void 0 ? maskedTo : maskedValue.length],
    };
}

function guessValidValueByRegExp({ value, selection }, maskRegExp) {
    const [from, to] = selection;
    let newFrom = from;
    let newTo = to;
    const validatedValue = Array.from(value).reduce((validatedValuePart, char, i) => {
        const newPossibleValue = validatedValuePart + char;
        if (from === i) {
            newFrom = validatedValuePart.length;
        }
        if (to === i) {
            newTo = validatedValuePart.length;
        }
        return newPossibleValue.match(maskRegExp) ? newPossibleValue : validatedValuePart;
    }, '');
    return { value: validatedValue, selection: [newFrom, newTo] };
}

function calibrateValueByMask(elementState, mask, initialElementState = null) {
    if (validateValueWithMask(elementState.value, mask)) {
        return elementState;
    }
    const { value, selection } = Array.isArray(mask)
        ? guessValidValueByPattern(elementState, mask, initialElementState)
        : guessValidValueByRegExp(elementState, mask);
    return {
        selection,
        value: Array.isArray(mask) ? value.slice(0, mask.length) : value,
    };
}

function removeFixedMaskCharacters(initialElementState, mask) {
    if (!Array.isArray(mask)) {
        return initialElementState;
    }
    const [from, to] = initialElementState.selection;
    const selection = [];
    const unmaskedValue = Array.from(initialElementState.value).reduce((rawValue, char, i) => {
        const charConstraint = mask[i];
        if (i === from) {
            selection.push(rawValue.length);
        }
        if (i === to) {
            selection.push(rawValue.length);
        }
        return isFixedCharacter(charConstraint) && charConstraint === char
            ? rawValue
            : rawValue + char;
    }, '');
    if (selection.length < 2) {
        selection.push(...new Array(2 - selection.length).fill(unmaskedValue.length));
    }
    return {
        value: unmaskedValue,
        selection: [selection[0], selection[1]],
    };
}

class MaskModel {
    constructor(initialElementState, maskOptions) {
        this.initialElementState = initialElementState;
        this.maskOptions = maskOptions;
        this.value = '';
        this.selection = [0, 0];
        const { value, selection } = calibrateValueByMask(initialElementState, this.getMaskExpression(initialElementState));
        this.value = value;
        this.selection = selection;
    }
    addCharacters([from, to], newCharacters) {
        const { value } = this;
        const maskExpression = this.getMaskExpression({
            value: value.slice(0, from) + newCharacters + value.slice(to),
            selection: [from + newCharacters.length, from + newCharacters.length],
        });
        const initialElementState = { value, selection: [from, to] };
        const unmaskedElementState = removeFixedMaskCharacters(initialElementState, maskExpression);
        const [unmaskedFrom, unmaskedTo] = applyOverwriteMode(unmaskedElementState, newCharacters, this.maskOptions.overwriteMode).selection;
        const newUnmaskedLeadingValuePart = unmaskedElementState.value.slice(0, unmaskedFrom) + newCharacters;
        const newCaretIndex = newUnmaskedLeadingValuePart.length;
        const maskedElementState = calibrateValueByMask({
            value: newUnmaskedLeadingValuePart +
                unmaskedElementState.value.slice(unmaskedTo),
            selection: [newCaretIndex, newCaretIndex],
        }, maskExpression, initialElementState);
        const isInvalidCharsInsertion =
        // eslint-disable-next-line @typescript-eslint/prefer-string-starts-ends-with
        value.slice(0, unmaskedFrom) ===
            calibrateValueByMask({
                value: newUnmaskedLeadingValuePart,
                selection: [newCaretIndex, newCaretIndex],
            }, maskExpression, initialElementState).value;
        if (isInvalidCharsInsertion ||
            areElementStatesEqual(this, maskedElementState) // If typing new characters does not change value
        ) {
            throw new Error('Invalid mask value');
        }
        this.value = maskedElementState.value;
        this.selection = maskedElementState.selection;
    }
    deleteCharacters([from, to]) {
        if (from === to || !to) {
            return;
        }
        const { value } = this;
        const maskExpression = this.getMaskExpression({
            value: value.slice(0, from) + value.slice(to),
            selection: [from, from],
        });
        const initialElementState = { value, selection: [from, to] };
        const unmaskedElementState = removeFixedMaskCharacters(initialElementState, maskExpression);
        const [unmaskedFrom, unmaskedTo] = unmaskedElementState.selection;
        const newUnmaskedValue = unmaskedElementState.value.slice(0, unmaskedFrom) +
            unmaskedElementState.value.slice(unmaskedTo);
        const maskedElementState = calibrateValueByMask({ value: newUnmaskedValue, selection: [unmaskedFrom, unmaskedFrom] }, maskExpression, initialElementState);
        this.value = maskedElementState.value;
        this.selection = maskedElementState.selection;
    }
    getMaskExpression(elementState) {
        const { mask } = this.maskOptions;
        return typeof mask === 'function' ? mask(elementState) : mask;
    }
}

class EventListener {
    constructor(element) {
        this.element = element;
        this.listeners = [];
    }
    listen(eventType, fn, options) {
        const untypedFn = fn;
        this.element.addEventListener(eventType, untypedFn, options);
        this.listeners.push(() => this.element.removeEventListener(eventType, untypedFn));
    }
    destroy() {
        this.listeners.forEach(stopListen => stopListen());
    }
}

const HotkeyModifier = {
    CTRL: 1 << 0,
    ALT: 1 << 1,
    SHIFT: 1 << 2,
    META: 1 << 3,
};
// TODO add variants that can be processed correctly
const HotkeyCode = {
    Y: 89,
    Z: 90,
};
/**
 * Checks if the passed keyboard event match the required hotkey.
 *
 * @example
 * input.addEventListener('keydown', (event) => {
 *     if (isHotkey(event, HotkeyModifier.CTRL | HotkeyModifier.SHIFT, HotkeyCode.Z)) {
 *         // redo hotkey pressed
 *     }
 * })
 *
 * @return will return `true` only if the {@link HotkeyCode} matches and only the necessary
 * {@link HotkeyModifier modifiers} have been pressed
 */
function isHotkey(event, modifiers, hotkeyCode) {
    return (event.ctrlKey === !!(modifiers & HotkeyModifier.CTRL) &&
        event.altKey === !!(modifiers & HotkeyModifier.ALT) &&
        event.shiftKey === !!(modifiers & HotkeyModifier.SHIFT) &&
        event.metaKey === !!(modifiers & HotkeyModifier.META) &&
        /**
         * We intentionally use legacy {@link KeyboardEvent#keyCode `keyCode`} property. It is more
         * "keyboard-layout"-independent than {@link KeyboardEvent#key `key`} or {@link KeyboardEvent#code `code`} properties.
         * @see {@link https://github.com/taiga-family/maskito/issues/315 `KeyboardEvent#code` issue}
         */
        // eslint-disable-next-line sonar/deprecation
        event.keyCode === hotkeyCode);
}

function isRedo(event) {
    return (isHotkey(event, HotkeyModifier.CTRL, HotkeyCode.Y) || // Windows
        isHotkey(event, HotkeyModifier.CTRL | HotkeyModifier.SHIFT, HotkeyCode.Z) || // Windows & Android
        isHotkey(event, HotkeyModifier.META | HotkeyModifier.SHIFT, HotkeyCode.Z) // macOS & iOS
    );
}
function isUndo(event) {
    return (isHotkey(event, HotkeyModifier.CTRL, HotkeyCode.Z) || // Windows & Android
        isHotkey(event, HotkeyModifier.META, HotkeyCode.Z) // macOS & iOS
    );
}

/**
 * Sets value to element, and dispatches input event
 * if you passed ELementState, it also sets selection range
 *
 * @example
 * maskitoUpdateElement(input, newValue);
 * maskitoUpdateElement(input, elementState);
 *
 * @see {@link https://github.com/taiga-family/maskito/issues/804 issue}
 *
 * @return void
 */
function maskitoUpdateElement(element, valueOrElementState) {
    var _a;
    if (typeof valueOrElementState === 'string') {
        element.value = valueOrElementState;
    }
    else {
        const [from, to] = valueOrElementState.selection;
        element.value = valueOrElementState.value;
        (_a = element.setSelectionRange) === null || _a === void 0 ? void 0 : _a.call(element, from, to);
    }
    element.dispatchEvent(new Event('input',
    /**
     * React handles this event only on bubbling phase
     *
     * here is the list of events that are processed in the capture stage, others are processed in the bubbling stage
     * https://github.com/facebook/react/blob/cb2439624f43c510007f65aea5c50a8bb97917e4/packages/react-dom-bindings/src/events/DOMPluginEventSystem.js#L222
     */
    { bubbles: true }));
}

function getLineSelection({ value, selection }, isForward) {
    const [from, to] = selection;
    if (from !== to) {
        return [from, to];
    }
    const nearestBreak = isForward
        ? value.slice(from).indexOf('\n') + 1 || value.length
        : value.slice(0, to).lastIndexOf('\n') + 1;
    const selectFrom = isForward ? from : nearestBreak;
    const selectTo = isForward ? nearestBreak : to;
    return [selectFrom, selectTo];
}

function getNotEmptySelection({ value, selection }, isForward) {
    const [from, to] = selection;
    if (from !== to) {
        return [from, to];
    }
    const notEmptySelection = isForward ? [from, to + 1] : [from - 1, to];
    return notEmptySelection.map(x => Math.min(Math.max(x, 0), value.length));
}

const TRAILING_SPACES_REG = /\s+$/g;
const LEADING_SPACES_REG = /^\s+/g;
const SPACE_REG = /\s/;
function getWordSelection({ value, selection }, isForward) {
    const [from, to] = selection;
    if (from !== to) {
        return [from, to];
    }
    if (isForward) {
        const valueAfterSelectionStart = value.slice(from);
        const [leadingSpaces] = valueAfterSelectionStart.match(LEADING_SPACES_REG) || [
            '',
        ];
        const nearestWordEndIndex = valueAfterSelectionStart
            .trimStart()
            .search(SPACE_REG);
        return [
            from,
            nearestWordEndIndex !== -1
                ? from + leadingSpaces.length + nearestWordEndIndex
                : value.length,
        ];
    }
    const valueBeforeSelectionEnd = value.slice(0, to);
    const [trailingSpaces] = valueBeforeSelectionEnd.match(TRAILING_SPACES_REG) || [''];
    const selectedWordLength = valueBeforeSelectionEnd
        .trimEnd()
        .split('')
        .reverse()
        .findIndex(char => char.match(SPACE_REG));
    return [
        selectedWordLength !== -1 ? to - trailingSpaces.length - selectedWordLength : 0,
        to,
    ];
}

/* eslint-disable @typescript-eslint/ban-types */
/**
 * @internal
 */
function maskitoPipe(processors = []) {
    return (initialData, ...readonlyArgs) => processors.reduce((data, fn) => (Object.assign(Object.assign({}, data), fn(data, ...readonlyArgs))), initialData);
}

function maskitoTransform(valueOrState, maskitoOptions) {
    const options = Object.assign(Object.assign({}, MASKITO_DEFAULT_OPTIONS), maskitoOptions);
    const preprocessor = maskitoPipe(options.preprocessors);
    const postprocessor = maskitoPipe(options.postprocessors);
    const initialElementState = typeof valueOrState === 'string'
        ? { value: valueOrState, selection: [0, 0] }
        : valueOrState;
    const { elementState } = preprocessor({ elementState: initialElementState, data: '' }, 'validation');
    const maskModel = new MaskModel(elementState, options);
    const { value, selection } = postprocessor(maskModel, initialElementState);
    return typeof valueOrState === 'string' ? value : { value, selection };
}

function maskitoInitialCalibrationPlugin(customOptions) {
    return (element, options) => {
        const from = element.selectionStart || 0;
        const to = element.selectionEnd || 0;
        maskitoUpdateElement(element, {
            value: maskitoTransform(element.value, customOptions || options),
            selection: [from, to],
        });
    };
}

function maskitoStrictCompositionPlugin() {
    return (element, maskitoOptions) => {
        const listener = (event) => {
            if (event.inputType !== 'insertCompositionText') {
                return;
            }
            const selection = [
                element.selectionStart || 0,
                element.selectionEnd || 0,
            ];
            const elementState = {
                selection,
                value: element.value,
            };
            const validatedState = maskitoTransform(elementState, maskitoOptions);
            if (!areElementStatesEqual(elementState, validatedState)) {
                event.preventDefault();
                maskitoUpdateElement(element, validatedState);
            }
        };
        element.addEventListener('input', listener);
        return () => element.removeEventListener('input', listener);
    };
}

class Maskito extends MaskHistory {
    constructor(element, maskitoOptions) {
        super();
        this.element = element;
        this.maskitoOptions = maskitoOptions;
        this.isTextArea = this.element.nodeName === 'TEXTAREA';
        this.eventListener = new EventListener(this.element);
        this.options = Object.assign(Object.assign({}, MASKITO_DEFAULT_OPTIONS), this.maskitoOptions);
        this.preprocessor = maskitoPipe(this.options.preprocessors);
        this.postprocessor = maskitoPipe(this.options.postprocessors);
        this.teardowns = this.options.plugins.map(plugin => plugin(this.element, this.options));
        this.updateHistory(this.elementState);
        this.eventListener.listen('keydown', event => {
            if (isRedo(event)) {
                event.preventDefault();
                return this.redo();
            }
            if (isUndo(event)) {
                event.preventDefault();
                return this.undo();
            }
        });
        this.eventListener.listen('beforeinput', event => {
            const isForward = event.inputType.includes('Forward');
            this.updateHistory(this.elementState);
            switch (event.inputType) {
                // historyUndo/historyRedo will not be triggered if value was modified programmatically
                case 'historyUndo':
                    event.preventDefault();
                    return this.undo();
                case 'historyRedo':
                    event.preventDefault();
                    return this.redo();
                case 'deleteByCut':
                case 'deleteContentBackward':
                case 'deleteContentForward':
                    return this.handleDelete({
                        event,
                        isForward,
                        selection: getNotEmptySelection(this.elementState, isForward),
                    });
                case 'deleteWordForward':
                case 'deleteWordBackward':
                    return this.handleDelete({
                        event,
                        isForward,
                        selection: getWordSelection(this.elementState, isForward),
                        force: true,
                    });
                case 'deleteSoftLineBackward':
                case 'deleteSoftLineForward':
                case 'deleteHardLineBackward':
                case 'deleteHardLineForward':
                    return this.handleDelete({
                        event,
                        isForward,
                        selection: getLineSelection(this.elementState, isForward),
                        force: true,
                    });
                case 'insertCompositionText':
                    return; // will be handled inside `compositionend` event
                case 'insertLineBreak':
                    return this.handleEnter(event);
                case 'insertFromPaste':
                case 'insertText':
                case 'insertFromDrop':
                default:
                    return this.handleInsert(event, event.data || '');
            }
        });
        this.eventListener.listen('input', ({ inputType }) => {
            if (inputType === 'insertCompositionText') {
                return; // will be handled inside `compositionend` event
            }
            this.ensureValueFitsMask();
            this.updateHistory(this.elementState);
        });
        this.eventListener.listen('compositionend', () => {
            this.ensureValueFitsMask();
            this.updateHistory(this.elementState);
        });
    }
    get elementState() {
        const { value, selectionStart, selectionEnd } = this.element;
        return {
            value,
            selection: [selectionStart || 0, selectionEnd || 0],
        };
    }
    get maxLength() {
        const { maxLength } = this.element;
        return maxLength === -1 ? Infinity : maxLength;
    }
    destroy() {
        this.eventListener.destroy();
        this.teardowns.forEach(teardown => teardown === null || teardown === void 0 ? void 0 : teardown());
    }
    updateElementState({ value, selection }, eventInit = {
        inputType: 'insertText',
        data: null,
    }) {
        const initialValue = this.elementState.value;
        this.updateValue(value);
        this.updateSelectionRange(selection);
        if (initialValue !== value) {
            this.dispatchInputEvent(eventInit);
        }
    }
    updateSelectionRange([from, to]) {
        var _a, _b;
        if (this.element.selectionStart !== from || this.element.selectionEnd !== to) {
            (_b = (_a = this.element).setSelectionRange) === null || _b === void 0 ? void 0 : _b.call(_a, from, to);
        }
    }
    updateValue(value) {
        this.element.value = value;
    }
    ensureValueFitsMask() {
        this.updateElementState(maskitoTransform(this.elementState, this.options));
    }
    dispatchInputEvent(eventInit = {
        inputType: 'insertText',
        data: null,
    }) {
        if (globalThis.InputEvent) {
            this.element.dispatchEvent(new InputEvent('input', Object.assign(Object.assign({}, eventInit), { bubbles: true, cancelable: false })));
        }
    }
    handleDelete({ event, selection, isForward, force = false, }) {
        const initialState = {
            value: this.elementState.value,
            selection,
        };
        const [initialFrom, initialTo] = initialState.selection;
        const { elementState } = this.preprocessor({
            elementState: initialState,
            data: '',
        }, isForward ? 'deleteForward' : 'deleteBackward');
        const maskModel = new MaskModel(elementState, this.options);
        const [from, to] = elementState.selection;
        maskModel.deleteCharacters([from, to]);
        const newElementState = this.postprocessor(maskModel, initialState);
        const newPossibleValue = initialState.value.slice(0, initialFrom) +
            initialState.value.slice(initialTo);
        if (newPossibleValue === newElementState.value && !force) {
            return;
        }
        event.preventDefault();
        if (areElementValuesEqual(initialState, elementState, maskModel, newElementState)) {
            // User presses Backspace/Delete for the fixed value
            return this.updateSelectionRange(isForward ? [to, to] : [from, from]);
        }
        this.updateElementState(newElementState, {
            inputType: event.inputType,
            data: null,
        });
        this.updateHistory(newElementState);
    }
    handleInsert(event, data) {
        const initialElementState = this.elementState;
        const { elementState, data: insertedText = data } = this.preprocessor({
            data,
            elementState: initialElementState,
        }, 'insert');
        const maskModel = new MaskModel(elementState, this.options);
        try {
            maskModel.addCharacters(elementState.selection, insertedText);
        }
        catch (_a) {
            return event.preventDefault();
        }
        const [from, to] = elementState.selection;
        const newPossibleValue = initialElementState.value.slice(0, from) +
            data +
            initialElementState.value.slice(to);
        const newElementState = this.postprocessor(maskModel, initialElementState);
        if (newElementState.value.length > this.maxLength) {
            return event.preventDefault();
        }
        if (newPossibleValue !== newElementState.value) {
            event.preventDefault();
            this.updateElementState(newElementState, {
                data,
                inputType: event.inputType,
            });
            this.updateHistory(newElementState);
        }
    }
    handleEnter(event) {
        if (this.isTextArea) {
            this.handleInsert(event, '\n');
        }
    }
}

//export { MASKITO_DEFAULT_ELEMENT_PREDICATE, MASKITO_DEFAULT_OPTIONS, Maskito, maskitoInitialCalibrationPlugin, maskitoPipe, maskitoStrictCompositionPlugin, maskitoTransform, maskitoUpdateElement };
