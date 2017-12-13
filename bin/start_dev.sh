#!/bin/sh

carton exec morbo -w lib/ -w tmpl/ -l 'http://127.0.0.1:3030' ./script/app
