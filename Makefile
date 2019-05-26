all:
	dune build @install @DEFAULT

site:
	./site_html_generator.exe -dir .

server:
	./server.exe -v -d -p 3333

install:
	dune install

test:
	dune runtest

clean:
	dune clean

uninstall:
	dune uninstall

.PHONY: all site server install test clean uninstall
