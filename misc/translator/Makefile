all: translator_doc.txt

%.txt: %.html
	set -x; sed -e 's/<blockquote>/&<table border=0 width="100%"><tr><td nowrap><pre>/g' -e 's/<\/blockquote>/<\/pre><\/table>&/g' $<|LANG=C w3m -T text/html -cols 80 | sed -e 's/  *$$//g' | cat -s > $@

clean:
	rm translator_doc.txt
