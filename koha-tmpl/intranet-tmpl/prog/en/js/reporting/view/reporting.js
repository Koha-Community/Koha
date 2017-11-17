
function Report(){
    var self = this;
    self.name = ko.observable('');
    self.description = ko.observable('');
    self.group = ko.observable('');
    self.groupings = ko.observableArray([]);
    self.filters = ko.observableArray();
    self.filtersHash = {};
    self.orderings = ko.observableArray([]);
    self.orderingsHash = {};
    self.visibleOrderings = ko.observableArray([]);
    self.selectedOrdering = ko.observable('');
    self.selectedDirection = ko.observable('asc');
    self.limit = ko.observable('');
    self.hasTopLimit = ko.observable(0);
    self.renderedReport = ko.observable('');;
    self.selectedReportType = ko.observable('html');

    self.formatDate = function(date){
        var dateFormat = "dd.MM.yyyy";
        var formatedDate = date.toString(dateFormat);
        return formatedDate;
    };

    self.renderReport = function(){
        var table = document.getElementById('reporting-rendered-report');
        table.innerHTML = self.renderedReport;
    }

    self.resetSelections = function(){
            var filters = self.filters();
            var filtersLength = filters.length;
            for (var i = 0; i < filtersLength; i++) {
                var filter = filters[i];
                filter.resetSelections();
            }

            var groupings = self.groupings();
            var groupingsLength = groupings.length;
            for (var j = 0; j < groupingsLength; j++) {
                var grouping = groupings[j];
                grouping.resetSelections();
            }

            var orderings = self.orderings();
            var orderingsLength = orderings.length;
            for (var k = 0; k < orderingsLength; k++) {
                var ordering = orderings[k];
                ordering.resetSelections();
            }

            self.resetDateFilter();
            self.selectedOrdering('');
            self.visibleOrderings([]);
    };

    self.toJSON = function() {
        var report = ko.toJS(self);
        if(report.hasOwnProperty('filters') && report.filters.length > 0){
            var filtersLength = report.filters.length;
            var filters = report.filters;
            report.filters = [];
            report.renderedReport = '';
            for (var i = 0; i < filtersLength; i++) {
                var filter = filters[i];
                if(filter && filter.selectedOptions.length > 0 || filter.selectedValue1  || filter.selectedValue2 ){
                    var optionsLength = filter.selectedOptions.length;
                    for (var m = 0; m < optionsLength; m++) {
                        var option = filter.selectedOptions[m];
                        if(option.hasOwnProperty('linkedFilter')){
                            option.linkedFilter.selectAllOption = false;
                            option.linkedFilter.options = [];
                            option.linkedFilter.allOptions = [];
                            option.linkedFilterOptions = [];
                        }
                        option.linkedFilterOptions = [];
                        option.filter = false;
                        option.translator = false;
                    }
                    if(filter.selectedValue1 && typeof filter.selectedValue1 === 'object' && filter.selectedValue1.hasOwnProperty('name') ){
                        var name = filter.selectedValue1.name;
                        filter.selectedValue1 = name;
                    }
                    filter.selectAllOption = false;
                    filter.options = [];
                    filter.allOptions = [];
                    filter.hideFilters = undefined;
                    report.filters.push(filter);
                }
            }
        }
        if(report.hasOwnProperty('groupings') && report.groupings.length > 0){
            var groupingsLength = report.groupings.length;
            var groupings = report.groupings;
            report.groupings = [];
            for (var j = 0; j < groupingsLength; j++) {
                var grouping = groupings[j];
                if(grouping && grouping.selectedValue == true ){
                    report.groupings.push(grouping);
                }
            }
        }
        return report;
    }

    self.toDropdownOption = function () {
        return { text: self.description(), value: self.name(), original: self };
    };

    self.resetDateFilter = function(){
        var dateFilter = self.dateFilter();
        if(dateFilter){
            dateFilter.from(self.formatDate(self.startDate));
            dateFilter.to(self.formatDate(self.endDate));
        }
    };

    var date = new Date();
    self.startDate = new Date(date.getFullYear(), date.getMonth(), 1);
    self.endDate = new Date(date.getFullYear(), date.getMonth() + 1, 0);

    self.dateFilter = ko.observable({
        'useTo': ko.observable(1) ,
        'useFrom': ko.observable(1),
        'showPrecision': ko.observable(0),
        'from': ko.observable(self.formatDate(self.startDate)),
        'to': ko.observable(self.formatDate(self.endDate)),
        'precision': ko.observable('month')
    });
};

function Filter(){
    var self = this;
    self.name = ko.observable();
    self.description = ko.observable();
    self.name2 = ko.observable('');
    self.description2 = ko.observable('');
    self.type;
    self.options = ko.observableArray([]);
    self.allOptions = ko.observableArray([]);
    self.selectedOptions = ko.observableArray([]);
    self.selectedValue1 = ko.observable('');
    self.selectedValue2 = ko.observable('');
    self.hasLinks = ko.observable(false);
    self.allSelected = ko.observable(0);
    self.resetAll = ko.observable(0);
    self.selectAllOption;
    self.hideSelector = ko.observable(0);
    self.translator;

    self.resetOptions = function(){
        var options = self.options();
        for (var i = 0; i < options.length; i++) {
            var option = options[i];
            option._destroy = false;
        }
        this.options.valueHasMutated();
        return 1;
    };

    self.resetSelections = function(){
        self.selectedOptions([]);
        self.allSelected(0);
        self.resetAll(0);
        if(self.hasOwnProperty('selectAllOption') && self.selectAllOption.hasOwnProperty('description')){
            self.selectAllOption.description(self.translator.translate('Select All'));
        }
        self.resetOptions();
        self.selectedValue1('');
        self.selectedValue2('');
    };

    self.selectorVisible = function(){
        var result = 1;
        if(self.type == 'multiselect'){
            var options = self.options();
            var optionsLength = options.length;
            for (var j = 0; j < optionsLength; j++) {
                var valueElement = options[j];
                if(!valueElement.hasOwnProperty('_destroy') || valueElement._destroy == false){
                   result = 1;
                   break;
                }
                else if(valueElement.hasOwnProperty('_destroy') && valueElement._destroy == true){
                    result = 0;
                }
            }
        }

        if(self.hideSelector() === 1){
            result = 0;
        }

        return result;
    };

    self.viewSelectClass = function(){
        var result = 0;
        if(self.type == 'select'){
            var selectedOptions = self.selectedOptions()
            var selectedOptionsLength = selectedOptions.length;

            if(selectedOptionsLength == 1){
                for (var j = 0; j < selectedOptionsLength; j++) {
                    var selectedValue = selectedOptions[j];
                    if(selectedValue.hasOwnProperty('name') && selectedValue.name != 'nothing_selected' && selectedValue.name != 'no'){
                        result = 1;
                    }
                }
            }
        }
        return result;
    };

    self.options.extend({ rateLimit: { notify: 'always', timeout: 500, method: "notifyWhenChangesStop" } });

    self.selectedOptions.subscribe(function(oldvalue) {
        self.selectedOptions.previousValue = oldvalue;
        self.selectedOptions.previousHash = {};
        var valueElements = oldvalue;
        if(valueElements && valueElements.length > 0){
            var elementsLength = valueElements.length;
            for (var j = 0; j < elementsLength; j++) {
                var valueElement = valueElements[j];
                self.selectedOptions.previousHash[valueElement['name']] = valueElement;
            }
        }
    }, null, "beforeChange");

    self.hideCallback = function(){};
}

function FilterOption(){
    var self = this;
    self.translator;
    self.translate = function(string){
        if(self.translator){
            string = self.translator.translate(string);
        }
        return string;
    }
    self.name;
    self.description = ko.observable('');
    self.filter;
    self.callback = function(action){
        var result = 0;
        if(action == 'itemSelected' && self.hasOwnProperty('itemSelected')){
            self.itemSelected();
        }
        else if(action == 'destroyLinked' && self.hasOwnProperty('destroyLinked')){
            result = self.destroyLinked();
        }
        else if(action == 'itemRemoved' && self.hasOwnProperty('itemRemoved')){
            self.itemRemoved();
        }
        else if(action == 'selectAll' && self.hasOwnProperty('selectAll')){
            self.selectAll();
        }
        else if(action == 'removeAll' && self.hasOwnProperty('removeAll')){
            self.removeAll();
        }
        else if(action = 'hideLinked'){
            self.filter.hideCallback(self);
        }
        return result;
    };

    self.itemSelected = function(){
        if(self.linkedFilter && self.linkedFilterOptions.length > 0){
            for (var i = 0; i < self.linkedFilterOptions.length ; i++){
                var linkedFilterOption = self.linkedFilterOptions[i];
                linkedFilterOption._destroy = false;
            }
            self.linkedFilter.options.valueHasMutated();
        }
    };

    self.destroyLinked = function(){
        var result = 0;
        if(self.linkedFilter){
            self.linkedFilter.options.destroyAll();
            result = 1;
        }
        return result;
    };

    self.itemRemoved = function(){
        if(self.linkedFilter && self.linkedFilterOptions.length > 0){
            for (var i = 0; i < self.linkedFilterOptions.length ; i++){
                var linkedFilterOption = self.linkedFilterOptions[i];
                self.linkedFilter.options.destroy(linkedFilterOption);
            }
        }
    };

    self.selectAll = function(){
        self.selecting = true;
        if(self.filter.allSelected() == 0){
            var allOptions = self.filter.options();
            self.filter.selectedOptions(allOptions);
            self.filter.allSelected(1);
            self.filter.selectAllOption.description(self.translate('Remove All'));
            var allLength = allOptions.length;
            var destoroyed = 0;
            for (var i = 0; i < allLength ; i++){
                var linkedFilterOption = allOptions[i];
                if(destoroyed == 0 && linkedFilterOption.hasOwnProperty('name') && linkedFilterOption.name !== 'select_all'){
                    var result = linkedFilterOption.callback('destroyLinked');
                    if(result){
                        destoroyed = 1;
                    }
                }
                linkedFilterOption.callback('itemSelected');
            }

        }
        self.filter.selectedOptions.valueHasMutated();
        self.selecting = false;
    };

    self.removeAll = function(){
        var allOptions = self.filter.options();
        var allLength = allOptions.length;
        var reseted = 0;
        for (var i = 0; i < allLength ; i++){
            var linkedFilterOption = allOptions[i];
            var result = 0;
            if(reseted == 0 && linkedFilterOption.hasOwnProperty('name') && linkedFilterOption.name !== 'select_all'){
                if(linkedFilterOption && linkedFilterOption.hasOwnProperty('linkedFilter')){
                    result = linkedFilterOption.linkedFilter.resetOptions();
                }
                if(result){
                    break;
                }
            }
        }

        self.filter.selectedOptions.removeAll();
        self.filter.resetAll(0);
        self.filter.allSelected(0);
        if(self.filter.hasOwnProperty('selectAllOption') && self.filter.selectAllOption.hasOwnProperty('description')){
            self.filter.selectAllOption.description(self.translate('Select All'));
        }
    };

    self.reset = function(){
        if(self.linkedFilter){
            self.linkedFilter.resetOptions();
        }
    };

    self.linkedFilter;
    self.linkedFilterOptions = [];
    self.selecting = false;
}


function Grouping(){
    var self = this;
    self.name = ko.observable();
    self.description = ko.observable();
    self.selectedValue = ko.observable(false);
    self.selectedOptions = ko.observable('');
    self.showOptions = ko.observable(0);

    self.resetSelections = function(){
        self.selectedValue(false);
        self.selectedOptions('');
    };
}

function Ordering(){
    var self = this;
    self.name = ko.observable();
    self.selected = ko.observable();

    self.resetSelections = function(){
        self.selected(false);
    };

}

function ReportingView() {
    var self = this;
    self.formId = 'reporting-main-form';
    var translator = new Translator();
    self.reportFactory = new ReportFactory();
    self.reportFactory.translator = translator;
    self.reports = ko.observableArray([]);
    self.reportGroups = ko.observableArray([]);
    self.selectedReportGroup = ko.observable();
    self.selectedReport = ko.observable({filters: ko.observableArray([{type : 'text'}])});
    self.htmlSpinnerVisible = ko.observable(0);
    self.csvSpinnerVisible = ko.observable(0);
    self.reportSubmit = function(){
       if(self.selectedReport().selectedReportType() == 'html'){
           self.renderReport();
       }
       else{
           var requestJson = self.generateRequestJson();

           if(!$('#request_json').length){
               var input = $("<input id='request_json' name='request_json' type='hidden'>");
               $('#reporting-main-form').append(input);
           }

           $('#request_json').val(requestJson);
           $('#reporting-main-form').submit();
       }
    };

    self.generateRequestJson = function(){
        var report = self.selectedReport();
        var jsonData = ko.toJSON(report);
        return jsonData;
    };

    self.reportSubmitHtml = function(){
        self.htmlSpinnerVisible(1);
        self.selectedReport().selectedReportType('html');
        self.reportSubmit();
    };

    self.reportSubmitCsv = function(){
        self.selectedReport().selectedReportType('csv');
        self.reportSubmit();
    };

    self.reportEmptySelections = function(){
            var reportGroups = self.reportGroups();
            var reportGroupsLength = reportGroups.length;
            for (var i = 0; i < reportGroupsLength; i++) {
                var group = reportGroups[i];
                var reports = group.reports();
                var reportsLength = reports.length;
                for (var j = 0; j < reportsLength; j++) {
                    var report = reports[j];
                    report.resetSelections();
                }
            }
    };

    self.renderReport = function(){
        var requestJson = self.generateRequestJson();
        var response = '';
        jQuery.ajax({
           url: 'request.pl',
           data: {
                'request_json': requestJson
           },
           type: "POST",

           success: function( ajaxResponse ) {
               self.htmlSpinnerVisible(0);
               self.selectedReport().renderedReport(ajaxResponse);
           },
           error: function( xhr, status, errorThrown ) {
               console.log(status);
               self.htmlSpinnerVisible(0);
               response = xhr.responseText;
               self.selectedReport().renderedReport(response);
           },
           complete: function( xhr, status ) {

           }
        });
    };

    self.groupByChecked = function(grouping){
        if(grouping && grouping.hasOwnProperty('name')){
            var name = grouping.name();
            var report = self.selectedReport();
            var isChecked = grouping.selectedValue();
            var visibleOrdering = self.getVisibleOrderingByName(name, report);

            if(visibleOrdering && isChecked == false){
               report.visibleOrderings.remove(visibleOrdering);
            }
            else if(!visibleOrdering && report.orderingsHash.hasOwnProperty(name) && isChecked == true){
               var index = report.orderingsHash[name];
               var ordering = report.orderings()[index];
               report.visibleOrderings.push(ordering);
            }
        }

        return true;
    };

    self.getVisibleOrderingByName = function(name, report){
        var ordering;
        var orderingsLength = report.visibleOrderings().length;
        if(name && orderingsLength > 0){
            for (var i = 0; i < orderingsLength; i++) {
               var tmpOrdering = report.visibleOrderings()[i];
               if(tmpOrdering.name() == name){
                  ordering = tmpOrdering;
                  break;
               }
            }
        }
        return ordering;
    };

    self.filterClear = function(index){
        var length = index + 1;
        var result = false;
        if(length != 0 && length %3 == 0){
            result = true;
        }
        return result;
    }

    self.init = function(){
        self.initDatePicker();
        var groups = self.reportFactory.createReportsFromJson();
        if(groups){
           self.reportGroups(groups);
        }
        self.selectedReportGroup(self.reportGroups()[0]);
        self.selectedReport(self.selectedReportGroup().reports()[0]);
    };

    self.initDatePicker = function() {
        $( function() {
        var dateFormat = "dd.mm.yy",
        from = $( "#from" ).datepicker({
            dateFormat: dateFormat,
            changeMonth: true,
            numberOfMonths: 1,
            firstDay: 1
        }).on( "change", function() {
          to.datepicker( "option", "minDate", getDate( this ) );
        }),
        to = $( "#to" ).datepicker({
            dateFormat: dateFormat,
            changeMonth: true,
            numberOfMonths: 1,
            firstDay: 1
        })
        .on( "change", function() {
            from.datepicker( "option", "maxDate", getDate( this ) );
        });

        function getDate( element ) {
            var date;
            try {
                date = $.datepicker.parseDate( dateFormat, element.value );
            } catch( error ) {
                date = null;
            }
            return date;
        }
        } );
    }

    self.init();

    self.orderLimitVisible = ko.computed(function() {
        var result = false;
        var visibleOrderings = self.selectedReport().visibleOrderings();
        if(visibleOrderings.length > 0 || self.selectedReport().hasTopLimit() == '1'){
            result = true;
        }
        return result;
    }, self);

};

function Translator(){
    var self = this;
    self.translations = {};
    self.initTranslations = function(){
        self.translations = reportingTranslations;
    };
    self.isInited = false;

    self.translate = function(string){
        if(!self.isInited){
            self.initTranslations();
            self.isInited = true;
        }
        if(string && self.translations.hasOwnProperty(string)){
            string = self.translations[string];
        }
        return string;
    }
}


function ReportFactory(){
    var self = this;
    self.translator;
    self.translate = function(string){
        if(self.translator){
            string = self.translator.translate(string);
        }
        return string;
    }

    self.createReportsFromJson = function(){
        var json = JSON.parse(reportDataJson);
        var jsonLength = json.length;
        var reportGroups = [];
        var reportGroupsHash = {};
        if(json && jsonLength > 0){
            for (var i = 0; i < jsonLength; i++) {
                var reportData = json[i];
                var report = new Report();
                if(reportData.hasOwnProperty('name')){
                    report.name(reportData['name']);
                }
                if(reportData.hasOwnProperty('description')){
                    report.description(self.translate(reportData['description']));
                }
                if(reportData.hasOwnProperty('use_date_from')){
                    report.dateFilter().useFrom(reportData['use_date_from']);
                }
                if(reportData.hasOwnProperty('use_date_to')){
                    report.dateFilter().useTo(reportData['use_date_to']);
                }
                if(reportData.hasOwnProperty('has_top_limit')){
                    report.hasTopLimit(reportData['has_top_limit']);
                }
                if(report.hasTopLimit() && reportData.hasOwnProperty('default_limit')){
                    report.limit(reportData['default_limit']);
                }

                if(reportData.hasOwnProperty('groupings')){
                    var groupingsLength = reportData.groupings.length;
                    if(groupingsLength > 0){
                        for (var k = 0; k < groupingsLength; k++) {
                            var grouping = new Grouping();
                            var groupingData = reportData.groupings[k];
                            if(groupingData.hasOwnProperty('name')){
                                grouping.name(groupingData['name']);
                            }
                            if(groupingData.hasOwnProperty('description')){
                                grouping.description(self.translate(groupingData['description']));
                            }
                            if(groupingData.hasOwnProperty('show_options')){
                                grouping.showOptions(groupingData['show_options']);
                            }
                            report.groupings.push(grouping);
                        }
                    }
                }
                if(reportData.hasOwnProperty('filters')){
                    var filtersLength = reportData.filters.length;
                    var filtersHash = {};
                    var filterOptionsHash = {};
                    if(filtersLength > 0){
                        for (var j = 0; j < filtersLength; j++) {
                            var filter = new Filter();
                            filter.translator = self.translator;
                            var filterData = reportData.filters[j];
                            if(filterData.hasOwnProperty('name')){
                                filter.name(filterData['name']);
                            }
                            if(filterData.hasOwnProperty('description')){
                                filter.description(self.translate(filterData['description']));
                            }
                            if(filterData.hasOwnProperty('name2')){
                                filter.name2(filterData['name2']);
                            }
                            if(filterData.hasOwnProperty('description2')){
                                filter.description2(self.translate(filterData['description2']));
                            }
                            if(filterData.hasOwnProperty('type')){
                                filter.type = filterData['type'];
                            }
                            if(filterData.hasOwnProperty('options')){
                                var filtersOptionsLength = filterData.options.length;
                                if(filtersOptionsLength > 0){
                                    var filterOptions = filterData['options'];
                                    for (var m = 0; m < filtersOptionsLength; m++) {
                                        var filterOptionData = filterOptions[m];
                                        var filterOption = new FilterOption();
                                        filterOption.translator = self.translator;
                                        if(filterOptionData.hasOwnProperty('name')){
                                            filterOption.name = filterOptionData['name'];
                                        }
                                        if(filterOptionData.hasOwnProperty('description')){
                                            filterOption.description(self.translate(filterOptionData['description']));
                                        }
                                        if(filterOptionData.hasOwnProperty('linked_filter')){
                                            filterOption.linkedFilter = filterOptionData['linked_filter'];
                                            filter.hasLinks(true);
                                        }
                                        if(filterOptionData.hasOwnProperty('linked_options')){
                                            filterOption.linkedFilterOptions = filterOptionData['linked_options'];
                                        }
                                        if(filterOption.name == 'select_all'){
                                            filter.selectAllOption = filterOption;
                                        }

                                        filterOption.filter = filter;
                                        filter.allOptions.push(filterOption)
                                        filter.options.push(filterOption);
                                        if(!filterOptionsHash[filter.name()]){
                                            filterOptionsHash[filter.name()] = {};
                                        }
                                        filterOptionsHash[filter.name()][filterOption.name] = filterOption;
                                    }
                                }
                            }
                            filtersHash[filter.name()] = filter;
                            report.filters.push(filter);
                        }
                        var allFilters = report.filters();
                        var allFiltersLength = report.filters().length;
                        for (var p = 0; p < allFiltersLength; p++) {
                            var aFilter = allFilters[p];
                            if(aFilter.hasOwnProperty('hasLinks') && aFilter.hasLinks() === true && aFilter.options().length > 0 ){
                                var aFilterOptions = aFilter.options();
                                var aFilterOptionsLength = aFilter.options().length;
                                for (var q = 0; q < aFilterOptionsLength; q++) {
                                    var aOption = aFilterOptions[q];
                                    if(aOption.hasOwnProperty('linkedFilter')){
                                        var aLinkedFilter = filtersHash[aOption.linkedFilter];
                                        if(aOption.hasOwnProperty('linkedFilterOptions') && aOption.linkedFilterOptions.length > 0 && filtersHash.hasOwnProperty(aOption.linkedFilter)){
                                            var aLinkedFilter = filtersHash[aOption.linkedFilter];
                                            var aLinkedFilterOptionNames = aOption.linkedFilterOptions;
                                            aOption.linkedFilterOptions = [];
                                            var aLinkedFilterOptionNamesLength = aLinkedFilterOptionNames.length;
                                            for (var r = 0; r < aLinkedFilterOptionNamesLength; r++) {
                                                 var aLinkedFilterOptionName = aLinkedFilterOptionNames[r];
                                                 if(filterOptionsHash.hasOwnProperty(aOption.linkedFilter) && filterOptionsHash[aOption.linkedFilter].hasOwnProperty(aLinkedFilterOptionName)){
                                                     var aLinkedOption = filterOptionsHash[aOption.linkedFilter][aLinkedFilterOptionName];
                                                     aOption.linkedFilterOptions.push(aLinkedOption);
                                                 }
                                            }
                                        }
                                        aOption.linkedFilter = aLinkedFilter;
                                    }
                                }
                            }
                            if(aFilter.name() === 'is_first_acquisition'){
                                aFilter.hideFilters = {};
                                if(filtersHash.hasOwnProperty('branch_category_forced')){
                                    aFilter.hideFilters['branch_category_forced'] = filtersHash['branch_category_forced'];
                                }
                                if(filtersHash.hasOwnProperty('branch_category')){
                                    aFilter.hideFilters['branch_category'] = filtersHash['branch_category'];
                                }
                                if(filtersHash.hasOwnProperty('branch')){
                                    aFilter.hideFilters['branch'] = filtersHash['branch'];
                                }
                                aFilter.hideCallback = function(option){
                                    var value = '';
                                    if(option.hasOwnProperty('name')){
                                        value = option.name;
                                    }
                                    var previousValue;
                                    if(option.filter.hasOwnProperty('prev_value')){
                                        previousValue = option.filter.prev_value;
                                    }

                                    if(previousValue && previousValue == value){
                                        return;
                                    }
                                    else{
                                        option.filter.prev_value = value;
                                    }

                                    if(this.hideFilters.hasOwnProperty('branch_category')){
                                        this.hideFilters['branch_category'].selectedOptions([]);
                                    }
                                    if(this.hideFilters.hasOwnProperty('branch')){
                                        this.hideFilters['branch'].selectedOptions([]);
                                        this.hideFilters['branch'].resetOptions();
                                    }
                                    if(value == 'yes'){
                                       if(this.hideFilters.hasOwnProperty('branch_category_forced')){
                                           this.hideFilters['branch_category_forced'].hideSelector(0);
                                           this.hideFilters['branch_category_forced'].selectedOptions.valueHasMutated();
                                       }
                                       if(this.hideFilters.hasOwnProperty('branch_category')){
                                           this.hideFilters['branch_category'].hideSelector(1);
                                       }
                                    }
                                    else if(value = 'no'){
                                       if(this.hideFilters.hasOwnProperty('branch_category_forced')){
                                           this.hideFilters['branch_category_forced'].hideSelector(1);
                                       }
                                       if(this.hideFilters.hasOwnProperty('branch_category')){
                                           this.hideFilters['branch_category'].hideSelector(0);
                                       }
                                    }
                                };
                            }
                        }
                    }
                }
                if(reportData.hasOwnProperty('orderings')){
                    var orderingsLength = reportData.orderings.length;
                    if(orderingsLength > 0){
                        for (var l = 0; l < orderingsLength; l++) {
                            var orderingData = reportData.orderings[l];
                            var ordering = new Ordering();
                            ordering.name(orderingData['name']);
                            report.orderings.push(ordering);
                            var index = report.orderings().length -1;
                            report.orderingsHash[ordering.name()] = index;
                        }
                    }
                }
                if(reportData.hasOwnProperty('group')){
                    report.group(reportData['group']);
                    var reportGroup;
                    if(reportGroupsHash.hasOwnProperty(report.group())){
                        reportGroup = reportGroups[reportGroupsHash[report.group()]];
                    }
                    else{
                        reportGroup = {name:report.group(), reports:ko.observableArray()};
                        reportGroups.push(reportGroup);
                        reportGroupsHash[report.group()] = reportGroups.length -1;
                    }

                    reportGroup.reports.push(report);
                }
            }
        }
        return reportGroups;
    }
};

 ko.bindingHandlers.selectPicker = {
     self: this,
     after: ['options'],
     init: function (element, valueAccessor, allBindingsAccessor) {
         if ($(element).is('select')) {
             if (ko.isObservable(valueAccessor())) {
                 if ($(element).prop('multiple') && $.isArray(ko.utils.unwrapObservable(valueAccessor()))) {
                     // in the case of a multiple select where the valueAccessor() is an observableArray, call the default Knockout selectedOptions binding
                     ko.bindingHandlers.selectedOptions.init(element, valueAccessor, allBindingsAccessor);
                 } else {
                     ko.bindingHandlers.selectedOptions.init(element, valueAccessor, allBindingsAccessor);

                     // regular select and observable so call the default value binding
//                     ko.bindingHandlers.value.init(element, valueAccessor, allBindingsAccessor);
                 }
             }
             $(element).addClass('selectpicker').selectpicker();
             var filter = ko.dataFor(element);
             if(filter && $(element).prop('multiple')){
                translator = filter.translator;
                if(translator){
                    $(element).prop('title', translator.translate('Nothing selected'));
                }
             }

         }
     },
     update: function (element, valueAccessor, allBindingsAccessor) {
         if ($(element).is('select')) {
            var selectPickerOptions = allBindingsAccessor().selectPickerOptions;
            if (typeof selectPickerOptions !== 'undefined' && selectPickerOptions !== null) {
                 var options = selectPickerOptions.optionsArray,
                     optionsText = selectPickerOptions.optionsText,
                     optionsValue = selectPickerOptions.optionsValue,
                     optionsCaption = selectPickerOptions.optionsCaption,
                     isDisabled = selectPickerOptions.disabledCondition || false,
                     resetOnDisabled = selectPickerOptions.resetOnDisabled || false;
                 if (ko.utils.unwrapObservable(options).length > 0) {
                     // call the default Knockout options binding
                     ko.bindingHandlers.options.update(element, options, allBindingsAccessor);
                 }
                 if (isDisabled && resetOnDisabled) {
                     // the dropdown is disabled and we need to reset it to its first option
                     $(element).selectpicker('val', $(element).children('option:first').val());
                 }
                 $(element).prop('disabled', isDisabled);
             }
             if(ko.isObservable(valueAccessor()) && $(element).prop('multiple') && $.isArray(ko.utils.unwrapObservable(valueAccessor()))){
                 var valueElements = valueAccessor();
                 var previousElements = [];
                 if(allBindingsAccessor && allBindingsAccessor().hasOwnProperty('optionsValue')){
                     var filter = allBindingsAccessor().optionsValue;
                     if(filter && filter.hasOwnProperty('selectedOptions') && filter.selectedOptions.hasOwnProperty('previousHash') && filter.selectedOptions.hasOwnProperty('previousValue')){
                         previousElementsHash = filter.selectedOptions.previousHash;
                         var elementsLength = valueElements().length;
                         var newElements = [];
                         var removedElements  = [];
                         var existingNames = {};
                         var allSelected = 0;
                         var allRemoved = 0;
                         for (var i = 0; i < elementsLength; i++) {
                             var valueElement = valueElements()[i];
                             if(valueElement && valueElement.hasOwnProperty('name') && !previousElementsHash.hasOwnProperty(valueElement['name'])){
                                 newElements.push(valueElement);
                             }
                             else if(valueElement && valueElement.hasOwnProperty('name') && previousElementsHash.hasOwnProperty(valueElement['name'])){
                                 existingNames[valueElement['name']] = valueElement;
                             }
                         }

                         var previousElements = filter.selectedOptions.previousValue;
                         var previousLength = previousElements.length;
                         for (var j = 0; j < previousLength; j++) {
                             var previousElement = previousElements[j];
                             if(previousElement && previousElement.hasOwnProperty('name') && !existingNames.hasOwnProperty(previousElement['name'])){
                                 removedElements.push(previousElement);
                             }
                         }

                         var newLength = newElements.length;
                         for (var k = 0; k < newLength; k++) {
                             var valueElement = newElements[k];
                             if(valueElement && valueElement.hasOwnProperty('callback')){
                                 if(valueElement.hasOwnProperty('name') && valueElement.name == 'select_all'){
                                     allSelected = 1;
                                     valueElement.callback('selectAll');
                                     break;
                                 }
                                 if(previousLength == 0){
                                     valueElement.callback('destroyLinked');
                                 }
                                 valueElement.callback('itemSelected');
                             }
                         }

                         var removedLength = removedElements.length;
                         for (var l = 0; l < removedLength; l++) {
                             var valueElement = removedElements[l];
                             if(valueElement && valueElement.hasOwnProperty('callback')){
                                 if(valueElement.hasOwnProperty('name') && ( valueElement.name == 'select_all' || Object.keys(existingNames).length <= 0)){
                                     allRemoved = 1;
                                     valueElement.callback('removeAll');
                                     break;
                                 }
                                 valueElement.callback('itemRemoved');
                             }
                         }

                         if(allSelected !== 1 && allRemoved !== 1){
                             for (var key in existingNames) {
                                 if (!existingNames.hasOwnProperty(key)){
                                     continue;
                                 }
                                 var valueElement = existingNames[key];
                                 if(valueElement.hasOwnProperty('name') && valueElement.name == 'select_all'){
                                     continue;
                                 }
                                 else{
                                     valueElement.callback('itemSelected');
                                 }
                             }
                         }
                     }
                 }
             }
             else{
                 var valueElements = valueAccessor();
                 if(allBindingsAccessor && allBindingsAccessor().hasOwnProperty('optionsValue')){
                     var filter = allBindingsAccessor().optionsValue;
                     var valueElements = valueElements();
                     var elementsLength = valueElements.length;
                     for (var i = 0; i < elementsLength; i++) {
                         valueElement = valueElements[i];
                         if(filter.name() != 'is_first_acquisition'){
                             valueElement.callback('destroyLinked');
                         }
                         valueElement.callback('itemSelected');
                         valueElement.callback('hideLinked');
                     }
                 }
             }
             if (ko.isObservable(valueAccessor())) {
                 if ($(element).prop('multiple') && $.isArray(ko.utils.unwrapObservable(valueAccessor()))) {
                     // in the case of a multiple select where the valueAccessor() is an observableArray, call the default Knockout selectedOptions binding
                     ko.bindingHandlers.selectedOptions.update(element, valueAccessor);
                 } else {
                     // call the default Knockout value binding
                 //    ko.bindingHandlers.value.update(element, valueAccessor);
                       ko.bindingHandlers.selectedOptions.update(element, valueAccessor);
                 }
             }

             $(element).selectpicker('refresh');
         }
     }
 };
