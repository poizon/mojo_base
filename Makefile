perl = carton exec perl
morbo = carton exec morbo

.SILENT: run create-user create-superuser show-migrations db-upgrade db-downgrade

run:
	$(morbo) -w lib/ -w tmpl/ -l 'http://0.0.0.0:3030' ./script/app

create-user:
	$(perl) script/manage.pl --create-user=0

create-superuser:
	$(perl) script/manage.pl --create-user=1

show-migrations:
	$(perl) script/manage.pl --show-migrations

db-upgrade:
	$(perl) script/manage.pl --db-upgrade

db-downgrade:
	$(perl) script/manage.pl --db-downgrade=1
