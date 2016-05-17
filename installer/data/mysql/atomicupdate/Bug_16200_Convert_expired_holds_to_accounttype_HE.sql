UPDATE accountlines SET accounttype='HE', description=itemnumber WHERE (description REGEXP '^Hold waiting too long [0-9]+') AND accounttype='F';
