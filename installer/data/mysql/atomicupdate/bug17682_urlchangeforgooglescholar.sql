UPDATE systempreferences set value =  replace(value, "http://www.", "https://") where variable = 'OPACSearchForTitleIn';
