
draft = draft-ietf-dnsop-dnssec-validator-requirements
name=$(shell awk '/^docname:/{ print $$2}' < $(draft).md)
version=$(patsubst 0%,%,$(lastword $(subst -, ,$(name))))
nextversion=$(shell printf '%02d' $$(( $(version) + 1 )))
OUTPUT = $(draft).txt $(draft).html $(draft).xml
all: $(OUTPUT)

%.xml: %.mkd
	kramdown-rfc2629 --v3 < $< > $@.tmp
	mv $@.tmp $@

%.html: %.xml
	xml2rfc $< --html

%.txt: %.xml
	xml2rfc $< --text

tag:
	git diff --exit-code || ( echo "changes exist, please stash or commit before tagging" && exit 1 )
	git tag -s -m "tagging $(name)" "$(name)"
	sed -r -i 's/^(docname: draft-.*)-[[:digit:]]+$$/\1-$(nextversion)'/ "$(draft).md"
	git commit "$(draft).md" -m 'Preparing for work on version $(nextversion)'

clean:
	-rm -rf $(OUTPUT) *.tmp

.PHONY: clean all tag
