require 'json'

module GCloud
	module Util
		def myip
			(JSON.parse `curl ipinfo.io`)["ip"]
		end
		module_function :myip
	end
	module Auth
		include Rake::DSL
		def login
			auth = JSON.parse `gcloud auth list --format json`
			p auth
			if auth and auth[0] and (not auth[0].empty?) then
				return true
			else
				sh "gcloud auth login"
				return false
			end
		end
		def list
			JSON.parse `gcloud auth list --format json`
		end
		def logout
			sh "gcloud auth revoke"
		end
		module_function :login, :list, :logout
	end
	module Firewall
		include Rake::DSL
		def allow(port_desc, proto = "tcp", prefix = "my-fw-rule")
			sh "gcloud compute firewall-rules create #{prefix}-#{proto}-#{port_desc} --allow #{proto}:#{port_desc}"
		end
		def cleanup(prefix = "my-fw-rule")
			(JSON.parse `gcloud compute firewall-rules list --format json`).each do |fw|
				if fw["name"].start_with? prefix then
					sh "gcloud compute firewall-rules delete #{fw["name"]}"
				end 
			end
		end
		module_function :allow, :cleanup
	end
	module Storage
		def create(name, loc = "ASIA-EAST1")
			return if ls(name) 
			sh "gsutil mb -l #{loc} gs://#{name}"
		end
		def ls(path)
			ret = `gsutil ls gs://#{path}`
			return $?.success? ? ret : nil
		end
		module_function :create, :ls
	end
	module Compute
		include Rake::DSL
		module Instance
			def list
				JSON.parse `gcloud compute instances list --format json`
			end
			def has(pattern)
				Instance.list.each do |elem|
					return true if elem["name"] =~ pattern
				end
				return false
			end
			module_function :list, :has
		end
		module Disk
			def create(name)
				sh "gcloud compute disks create #{name}"
				return true
			rescue
				return false
			end
			def delete(name)
				sh "gcloud compute disks delete #{name}"
			end
			def list
				JSON.parse `gcloud compute disks list --format json`
			end
			module_function :create, :delete, :list
		end
	end
	module SQL
		include Rake::DSL
		def create(name, app, password = nil, tier = nil, pricing_plan = nil)
			sh "gcloud sql instances create #{name} --tier=#{tier or "D0"} --assign-ip "
			if password then
				sh "gcloud sql instances set-root-password #{name} -p #{password}"
			end
			SQL.get name
		end
		def delete(name)
			sh "gcloud sql instances delete #{name}"
		end
		def get(name)
			JSON.parse `gcloud sql instances get #{name} --format json`
		rescue
			return nil
		end
		def list
			(JSON.parse `gcloud sql instances list --format json`)["items"]
		rescue
			return nil
		end
		def update_grant_instances(name)
			ips = []
			Compute::Instance.list.each do |elem|
				ips.push(elem["networkInterfaces"][0]["accessConfigs"][0]["natIP"]+"/32")
			end
			ips.push(Util.myip+"/32")
			sh "gcloud sql instances patch #{name} --authorized-networks #{ips.join(' ')}"
		end
		def has?(name)
			(`gcloud sql instances list`).split('\n').each do |line|
				return true if line =~ /.*?:#{name}/
			end 
			return false
		end
		module_function :create, :delete, :get, :list, :update_grant_instances
	end
end
