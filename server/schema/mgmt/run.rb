require File.expand_path("../db_migrater", File.dirname(__FILE__))

mig = DBMigrater.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3], File.dirname(__FILE__))
mig.migrate
