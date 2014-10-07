require 'rake'
include Rake::DSL

module K8S
	def rewrite_config_by_setting(path, setting, output, verbose = false)
		{ 
			:NUM_MINIONS => (setting["node_num"] or 4),
			:ZONE => (setting["zone"] or "asia-east1-b"),
			:MASTER_SIZE => (setting["master_instance_type"] or "g1-small"),
			:MINION_SIZE => (setting["minion_instance_type"] or "g1-small"),
			:MINION_SCOPES => "storage-full"
		}.each do |k, v|
			sh "sed -i.bk 's/#{k}=.*/#{k}=#{v}/g' #{path} && rm #{path}.bk", verbose: verbose
		end
		Dir.chdir(File.dirname path) do |p|
			sh "cp #{path} #{output}", verbose: verbose
			sh "git checkout #{File.basename path}", verbose: verbose
		end
		output
	end
	def do(cmd)
		Dir.chdir(File.dirname(__FILE__)+"/../infra/kubernetes") do |path|
			sh cmd
		end
	end
	module_function :rewrite_config_by_setting, :do
end
