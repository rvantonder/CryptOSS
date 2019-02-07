all:
	jbuilder build @install @DEFAULT

site:
	./site_html_generator.exe -dir .

server:
	./server.exe -v -d -p 3333

install:
	jbuilder install

test:
	jbuilder runtest

clean:
	jbuilder clean

uninstall:
	jbuilder uninstall

.PHONY: all site server install test clean uninstall
