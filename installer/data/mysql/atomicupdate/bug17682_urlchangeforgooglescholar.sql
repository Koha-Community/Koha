UPDATE systempreferences set value =  replace(value, "http://www.scholar", "https://scholar") where variable = 'OPACSearchForTitleIn';
