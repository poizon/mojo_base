perl = carton exec perl
morbo = carton exec morbo

.SILENT: run create-user create-superuser init-db show-migrations upgrade-db downgrade-db

run:
	$(morbo) -w lib/ -w tmpl/ -l 'http://0.0.0.0:3030' ./script/app

create-user:
	$(perl) script/manage.pl --create-user=0

create-superuser:
	$(perl) script/manage.pl --create-user=1

init-db:
	$(perl) script/manage.pl --init-db

show-migrations:
	$(perl) script/manage.pl --show-migrations

upgrade-db:
	$(perl) script/manage.pl --upgrade-db

downgrade-db:
	$(perl) script/manage.pl --downgrade-db=1
