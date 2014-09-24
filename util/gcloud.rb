require 'json'

module GCloud
	module Auth
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
		module_function :login
	end
	module Firewall
		def allow(port_desc, proto = "tcp", prefix = "my_fw_rule")
			sh "gcloud compute firewall-rules create #{pfx}_#{proto}_#{port_desc} --allow #{proto}:#{port_desc}"
		end
		def cleanup(prefix = "my_fw_rule")
			(JSON.parse `gcloud compute firewall-rules list --format json`).each do |fw|
				if fw["name"].start_with? prefix then
					sh "gcloud compute firewall-rules delete #{fw["name"]}"
				end 
			end
		end
		module_function :allow, :cleanup
	end
	module Compute
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
	end
	module SQL
		def create(name, tier = nil, pricing_plan = nil)
			sh "gcloud sql instances create #{name} --tier=#{tier or "D0"} --assign-ip --pricing_plan=#{pricing_plan or "PER_USE"}"
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
		def has?(name)
			(`gcloud sql instances list`).split('\n').each do |line|
				return true if line =~ /.*?:#{name}/
			end 
			return false
		end
		module_function :create, :delete, :get, :list
	end
end
