#!/bin/sh

TIDY=${TIDY:-"carton exec perltidy -pro=t/.perltidyrc -b"}

if [ type "carton" &> /dev/null ]; then
	TIDY="perltidy -pro=t/.perltidyrc -b"
fi

# Если на вход ничего не подали - перлтидим весь проект целиком
if [ -z "$1" ]; then
    echo "Preparing lib/..."
	find lib/ -name *.pm -o -name *.pl -type f -exec $TIDY {} \;
	
	echo "Preparing script/..."
	find script/ -name *.pm -o -name *.pl -type f -exec $TIDY {} \;

	echo "Removing backups..."
	find lib/ -name *.pm.bak -o -name *.pl.bak -type f -exec rm -f {} \;
	find script/ -name -name *.pm.bak -o -name *.pl.bak -type f -exec rm -f {} \;
else
	echo "Preparing $1 ..."

	# Проверяем что нам передали: директорию или файл
	if [ -d "$1" ]; then
		find $1 -name *.pm -o -name *.pl -type f -exec $TIDY {} \;
		find $1 -name *.pm.bak -o -name *.pl.bak -type f -exec rm -f {} \;
	elif [ -f "$1" ]; then
		$TIDY $1
		rm -f "$1.bak"
	else
		echo "Invalid argument: $1"
		exit 1
	fi
fi

echo "Done"
exit 0
