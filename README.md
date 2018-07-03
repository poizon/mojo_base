# mojo_base

A set of basic components for developing typical web projects based on the Mojolicious framework.

The goal of this project is to have at your fingertips a software solution for rapid deployment and further development of a typical web-project based on the Perl/Mojo stack, with a minimum number of dependencies.

WARNING! At the moment the project is in deep development.

In future versions it is planned to implement the functionality for: admin part, content pages, news feed, image galleries (with minimalistic crop), accounts management, statistics and outer api.

## Used software

Server side:
* Mojolicious==7.85
* JSON::XS==3.04
* Time::Moment==0.44
* DBI==1.641
* DBD::SQLite==1.58
* Geo::IP2Location::Lite==0.11

Client side:
* JQuery v3.2.1
* Bootstrap v4.1.1

## Install

```shell
$ git clone git@github.com:ChaoticEvil/mojo_base.git
$ cd mojo_base
$ cpan i Carton
$ carton install
```

## Usage

- `make run` - start development web server (morbo)
- `make create-user` - add new regular user
- `make create-superuser` - add new admin user
- `make show-migrations` - show all applied sql migrations
- `make db-upgrade` - find and aplly all new sql migrations
- `make db-downgrade` - revert last applied sql migration
