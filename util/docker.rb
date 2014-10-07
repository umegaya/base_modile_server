module Docker 
	module OS
		def OS.windows?
			(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
		end
		def OS.mac?
			(/darwin/ =~ RUBY_PLATFORM) != nil
		end
		def OS.unix?
			!OS.windows?
		end
		def OS.linux?
			OS.unix? and not OS.mac?
		end
	end	
	# following modules are for docker container which base image is phusion/baseimage
	class Container
		include Rake::DSL
		attr_accessor :id
		attr_accessor :image
		def initialize(id, image = nil)
			@id = id
			@image = image
		end
		def ssh_ipaddr 
			if OS.windows? or OS.mac? then
				if ENV['DOCKER_HOST'].match(/tcp:\/\/([^\/:]+)/) then
					return $1
				end
			else
				"localhost"
			end
		end
				
		def ssh(opts = nil, cmd = nil)
			if cmd then
				cmdl = (cmd.is_a?(Array) ? cmd.join(' ') : cmd.to_s)
				`ssh #{opts or ""} root@#{ssh_ipaddr} #{cmdl}`
			else
				sh "ssh #{opts or ""} root@#{ssh_ipaddr}"
			end
		end
		def value(key)
			`docker inspect -f "{{ #{key} }}" #{@id} 2>/dev/null`
		end
		def ipaddr
			value '.NetworkSettings.IPAddress'
		end
		def self.exists?(name)
			not Container.new(name).value('.NetworkSettings.IPAddress').chop.empty?
		end
	end

	def launch(image, name, opts = nil)
		if name and Container.exists?(name) then
			p "already"
			return Container.new(name, image)
		end
		if opts then
			puts "launch:docker run -d --name #{name} #{opts} #{image}"
			system("docker run -d --name #{name} #{opts} #{image}")
		else
			system("docker run -d --name #{name} #{image}")
		end
		return Container.new(name, image)
	end
	def run(name, opts, cmd)
		p "run #{cmd} at #{name}"
		Container.new(name).ssh opts, cmd
	end
	def ssh(name, opts)
		Container.new(name).ssh opts, nil
	end
	def start(image, name, cmd, opts = nil)
		system("docker run --name #{name} #{opts or ""} #{image} #{cmd}")
		return $?.success?
	end
	def exists?(name)
		Container.exists? name
	end
	def kill(name)
		system("docker kill #{name}")
		system("docker rm #{name}")
	end
	def restart(name)
		system("docker restart #{name}")
	end
	def build(image, dockerfile, force = false)
		p "docker build -t #{image} #{force ? "--no-cache" : ""} #{dockerfile}"
		system("docker build -t #{image} #{force ? "--no-cache" : ""} #{dockerfile}")
	end
	def push(image)
		system("docker push #{image}")
		return $?.success?
	end
	def create_private_registry(port, image_bucket, force = false)
		unless (Docker::Container.exists? "docker-registry") and (not force) then
			Docker::kill("gcloud-config")
			Docker::kill("docker-registry")
			Docker::start("google/cloud-sdk", "gcloud-config", "gcloud auth login", "-ti -e CLOUDSDK_CONFIG=/.config/gcloud")
			Docker::launch("google/docker-registry", "docker-registry", "-e GCS_BUCKET=#{image_bucket} -p 5000:#{port} --volumes-from gcloud-config")
		else
			Docker::restart("docker-registry")
		end
		return Docker::Container.new("docker-registry").ssh_ipaddr
	end

	module_function :run, :kill, :launch, :start, :restart, :build, :push, :ssh, :exists?, :create_private_registry

	module Service
		def run_devsv(image_name, cwd, ssh_ports, service = nil, boot = {})
			db_hostname_env="DB_HOSTNAME=`docker inspect -f {{.NetworkSettings.IPAddress}} db`"
			cmds = {
				:db => "-v #{cwd}/data:/var/lib/mysql -v #{cwd}/server:/tmp/server -p 3306:3306",
				:app => "-v #{cwd}/server:/tmp/server -e #{db_hostname_env} -e BATCH_MODE=1 -p 8090:80",
				:mgmt => "-v #{cwd}/server:/tmp/server -e #{db_hostname_env} -p 8091:80",
			}
			if service then
				depslist = {
					:app => [:db],
					:mgmt => [:db],
				}
				deps = depslist[service.to_sym]
				if deps then
					deps.each do |dep|
						sv = dep.to_sym
						next if boot[sv]
						boot[sv] = true
						Service.run_devsv image_name, cwd, ssh_ports, sv, boot
					end
				end
				if Docker::Container.exists? service then
					Docker::restart(service)
				else
					full_image_name = "#{image_name}:#{service}.dev.latest"
					cmdl = cmds[service.to_sym] + " -p #{ssh_ports[service.to_sym]}:22"
					Docker::launch(full_image_name, service, cmdl)
				end
			else
				cmds.each do |k,v|
					sv = k.to_sym
					next if boot[sv]
					boot[sv] = true
					Service.run_devsv image_name, cwd, ssh_ports, sv, boot
				end
			end
		end
		module_function :run_devsv
	end
end
