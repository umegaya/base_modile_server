require 'rake'
require 'json'

include Rake::DSL

cwd = File.dirname(__FILE__)

require "#{cwd}/../../util/gcloud"
config = JSON.parse File.open("#{cwd}/../../setting.json").read
unless (GCloud::Auth.login and ARGV[0] != 'reset') then
	project = config['project']
	zone = config['zone']
	sh "gcloud config set project #{project}"
	sh "gcloud config set compute/zone #{zone or "asia-east1-b"}"
end

GCloud::Storage.create config['image_bucket']
