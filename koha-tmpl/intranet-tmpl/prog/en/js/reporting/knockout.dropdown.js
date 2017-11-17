DEBUG = false;
/**
 * Generic utils
 */
var Utils = {
    findItemWithPropertyOfValue: function (array, property, value) {
        for (var i = 0; i < array.length; ++i) {
            if (array[i][property] == value) {
                return array[i];
            }
        }
    }
};

/**
 * Dropdown class handles all logic - it is generic dropdown front for Knockout
 * maps all values to internal items and back - proxies for changing selection and options
 */
var Dropdown = function (options, selected) {
    var self = this;
    var selectedOriginal = selected;
    var createOptionArray = function (array) {
        return $.map(array, function (value) { return value.toDropdownOption(); });
    };
    self.options = ko.observableArray(createOptionArray(options()));
    var firstOption = self.options()[0];
    self.selected = ko.observable(firstOption);
    options.subscribe(function (newValue) {
        self.options.replace(createOptionArray(newValue));
        self.selected(self.options()[0]);
    });

    self.selected.subscribe(function (newValue) {
        var options = self.options();
        var index = options.indexOf(newValue);
        if (index !== -1) {
            selectedOriginal(options[index].original);
            if (DEBUG) console.log('Dropdown', 'selectedItem', 'Found matching item.originalValue for value.', newValue);

        } else {
            if (DEBUG) console.log('Dropdown', 'selectedItem', 'Item with matching originalValue as not found.', newValue);
        }
    });

    var suppressSelectedOriginalUpdate = false;
    selectedOriginal.subscribe(function (newValue) {
        if (suppressSelectedOriginalUpdate) return; suppressSelectedOriginalUpdate = true;
        var option = Utils.findItemWithPropertyOfValue(self.options(), 'original', newValue);
        if (option) {
            self.selected(option);
            if (DEBUG) console.log('Dropdown', 'selectedOriginalValue', 'Found matching item for value.', newValue);

        } else {
            if (DEBUG) console.log('Dropdown', 'selectedOriginalValue', 'Item with matching value as not found.', newValue);
        }
        suppressSelectedOriginalUpdate = false;
    });

    if (DEBUG) console.log('Dropdown', 'init', options, selected);
    if (DEBUG) console.log('Dropdown', 'init', 'Setting selection using selectedOriginal.');
    suppressSelectedOriginalUpdate = true;
    self.selected(Utils.findItemWithPropertyOfValue(self.options(), 'original', selectedOriginal()));
    if (DEBUG) console.log('Dropdown', 'init', 'Complete.');

};

Dropdown.createItem = function (text, value, original) {
    return { text: text, value: value, original: original };
};

ko.bindingHandlers.dropdown = {
    init: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
        var $el = $(element), value = ko.unwrap(valueAccessor);
        var template = '\
            <input type="hidden" />\
            <div class="text" data-bind="text: context().selected().text"></div>\
            <i class="dropdown icon"></i>\
            <div class="menu" data-bind="foreach: context().options()">\
                <div class="item" data-bind="attr: { \'data-value\': $data.value }">\
                    <!-- ko text: $data.text --><!-- /ko -->\
                </div>\
            </div>';

        element.innerHTML = template;
        var innerBindingContext = bindingContext.createChildContext({
            context: valueAccessor
        });
        ko.applyBindingsToDescendants(innerBindingContext, element);
        ko.toJSON();

        $el.dropdown({
            value: value().selected().value,
            onChange: function (newValue, text) {
                var option = Utils.findItemWithPropertyOfValue(value().options(), 'value', newValue);
                if (option) {
                    value().selected(option);
                    if (DEBUG) console.log('ko.dropdown', 'dropdown.onChange', 'Found matching option for value.', newValue);

                } else {
                    if (DEBUG) console.log('ko.dropdown', 'dropdown.onChange', 'Option with matching value was not found.', newValue, value().options());
                }
            }
        });

        var suppressSelectedUpdate = false;
        value().selected.subscribe(function (newValue) {
            if (!suppressSelectedUpdate) return; suppressSelectedUpdate = true;
            $el.dropdown('set value', newValue.value);
            suppressSelectedUpdate = false;
        });

        return { controlsDescendantBindings: true };
    }
};
