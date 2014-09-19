base_modile_server
==================

basic mobile server CI/deploy structure.

#### directories
```
 /-+-ci		# continuous integration
   +-client	# place for client project
   +-data 	# local mysql data directory (if docker container down, data is never lost)
   +-infra	# cloud controller by kubernetes
   +-rakefile	# various commands for server dev/deploy is unified as rake command.
   +-server	# files for server build. all files which required by server image build process, have to be in here.
   +-util	# utility code for (mainly) rakefile.
   +-setting.json.tmpl # project setting template.
   +-README.md	# this file
```

