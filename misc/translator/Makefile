all: translator_doc.txt

%.txt: %.html
	LANG=C w3m $< > $@
