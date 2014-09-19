#### server directories
```
 server-+-cert # put developper's public key here. it will use for entering to the containers in both dev & staging/prod env
        +-run # all files for building server container image. 
              +-app 	# files for building app server container
              +-mgmt 	# files for building management server container
              +-db 	# files for building database server container
        +-schema # all files for database schema migration
              +-app     # files for app server database migration
              +-mgmt    # files for management server database migration
        +-src # example. estimate purpose is holding actual source code for app/mgmt server.
```
