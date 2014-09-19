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
				ipaddr
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
		self.launch(image, name, opts).ssh cmd
	end
	def exists?(name)
		Container.exists? name
	end
	def kill(name)
		system("docker kill #{name}")
		system("docker rm #{name}")
	end
	def build(image, dockerfile)
		system("docker build -t #{image} #{dockerfile}")
	end
	def push(image)
		system("docker push #{image}")
	end

	module_function :run
	module_function :kill
	module_function :launch
	module_function :start
	module_function :build
	module_function :push
	module_function :ssh
	module_function :exists?
end
