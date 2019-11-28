```sh
____        _              ____
|  _ \ _   _| |__  _   _   / ___| ___ _ __ ___  ___
| |_) | | | | '_ \| | | | | |  _ / _ \ '_ ` _ \/ __|
|  _ <| |_| | |_) | |_| | | |_| |  __/ | | | | \__ \
|_| \_\\__,_|_.__/ \__, |  \____|\___|_| |_| |_|___/
                   |___/
```
[![License](https://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)

This project is built on top of [Geminabox](https://github.com/geminabox/geminabox) and provide the follwoing featuers for the gem server.

- Protecting upload/delete web requests using ldap authentication.
- Generating API keys for the users.
- Protecting api call using ldap authentication or  api keys.
- Manage ussers in three groups admin, maintainer and developer.
  - developer is the default group and it has only read access.
  - maintainer allow the users to push and delete their own gems only.
  - admin allow users to push delete all gems.

# Development Setup

  - Start the server

  ```sh
  $> bundle install
  $> STORE_FORMAT=yaml RACK_ENV=production rackup
  ```

  - Start rack console

  ```sh
  $> STORE_FORMAT=yaml RACK_ENV=production bin/console
  ```

# Ldap configs
  ldap configs can be found under config/ldap.yml, you can either modfify the file or manage the configs using enviornment variables.

  ```
  production: &ldap_defaults
  hostname: <%= ENV.fetch('LDAP_HOST', '127.0.0.1') %>
  basedn:   <%= ENV.fetch('LDAP_BASEDN', 'dc=shihadeh,dc=cloud') %>
  rootdn:   <%= ENV.fetch('LDAP_ROOTDN', 'cn=admin,dc=shihadeh,dc=cloud') %>
  passdn:   <%= ENV.fetch('LDAP_PASSDN', 'test1234') %>
  scope: :subtree
  auth: true
  port:                   <%= ENV.fetch('LDAP_PORT', '389') %>
  username_ldap_attribut: <%= ENV.fetch('LDAP_USERNAME_LDAP_ATTRIBUT', 'givenName') %>
  ldap_group_base:        <%= ENV.fetch('LDAP_LDAP_GROUP_BASE', 'ou=Groups,dc=shihadeh,dc=cloud') %>
  ldap_group_filter:      <%= ENV.fetch('LDAP_LDAP_GROUP_FILTER', '(&(objectClass=groupOfNames)(member={dn}))') %>
  ldaps: false
  starttls: false
  tls_options: nil
  ```

# Enviornment variables
 - GEM_DATA_DIR_PATH : path to the data folder.
 - STORE_FORMAT: either yaml or text (YAML::Store, PStore).
 - LDAP_HOST: ldap ip or hostname
 - LDAP_BASEDN
 - LDAP_ROOTDN
 - LDAP_PASSDN
 - LDAP_PORT
 - LDAP_USERNAME_LDAP_ATTRIBUT
 - LDAP_LDAP_GROUP_BASE
 - LDAP_LDAP_GROUP_FILTER
 - RACK_ENV
 - WEB_CONCURRENCY
 - MAX_THREADS
 - PORT

# Middleware
- HealthCheck : Middleware for supporting health check endpoints under `http://host/health`.
- SignUp : Middleware for supporting signup endpoints under `http://host/signup`. The user need to provide ldap credintails and as a result of vaild credintails an api key will be gnerated for the user.
- ApiKey: Middleware for supporting api_key endpoint under `http://host//api/v1/api_key` This is used by the `gem signin` command line.The user need to provide ldap credintails and as a result of vaild credintails an api key will be gnerated for the user. and it wiill be stored in `~/.gem/credentials`.
- ApiGem : Middleware for validation and control api requests to `/api/v1/gems` (push gems) and `/api/v1/gems/yank` (yank a gem). The Middleware checks if the api key used is allowed to do the operations and take care of updaing/collect the gems metadata.
- WebRequestsLdapAuth: Middleware for validation and control web requests upload and delete gems form the ui. The Middleware checks if the user is allowed to do the operations and take care of updaing/collect the gems metadata.

# Docker

- Build docker image

```
$> IMAGE_TAG=latest make build
```

- Start compleate stack (ldap server, admin ui and gems server) with docker-compose

```
docker-compose up -d
```