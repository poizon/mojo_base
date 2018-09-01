#!/bin/sh

TIDY="perltidy -pro=t/.perltidyrc -b"
# TIDY=${TIDY:-"carton exec perltidy -pro=t/.perltidyrc -b"}

# if [ type "carton" &> /dev/null ]; then
# 	TIDY="perltidy -pro=t/.perltidyrc -b"
# fi

# Если на вход ничего не подали - форматируем код всего проекта (lib/ script/)
if [ -z "$1" ]; then
    echo "Preparing lib/..."
	find lib/. -type f -name *.pm -exec $TIDY {} \;
	
	echo "Preparing script/..."
	find script/ -type f -name *.pl -exec $TIDY {} \;

	echo "Removing backups..."
	find lib/ -type f -name *.bak -exec rm -f {} \;
	find script/ -type f -name *.bak -exec rm -f {} \;
else
	echo "Preparing $1 ..."

	# Проверяем что нам передали: директорию или файл
	if [ -d "$1" ]; then
		find $1 -type f -name *.pm -o -name *.pl -exec $TIDY {} \;
		find $1 -type f -name *.bak -exec rm -f {} \;
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
