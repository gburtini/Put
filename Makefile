install: deploy/put.rb deploy/destinations
	gem install net-sftp dropbox json rest-client
	cp -r deploy/destinations /var/put
	cp deploy/put.rb /usr/bin/put
	chmod +x /usr/bin/put
