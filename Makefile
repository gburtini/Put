install: deploy/put.rb deploy/destinations
	cp -r deploy/destinations /var/put
	cp deploy/put.rb /usr/bin/put
	chmod +x /usr/bin/put
