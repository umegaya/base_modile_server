
class DBMigrater
	def initialize(dbname, user, password, hostname, dir = ".")
		@dbname = dbname
		@user = user
		@password = password
		@hostname = hostname
		@dir = dir
	end

	# mysqlに何かするときに使う汎用的なコマンド部分を返す
	def mysql_base_command(add_dbname = true)
		"mysql -u #{@user} #{@password ? ("-p" + @password) : ""} #{@hostname ? ("-h" + @hostname) : ""} #{add_dbname ? @dbname : ""}"
	end

	# すでにdb versionが存在するか調べ、なければ初期化する。現在のdbのバージョンを返す。
	def check_or_add_db_version
		out = `#{mysql_base_command} -e "select * from version"`
		if out =~ /\s([0-9]+)\s/ then
			return $1.to_i
		else
			p `#{mysql_base_command} < #{@dir}/1_add_db_version.sql`
			return 1
		end
	end

	def create_db_if_not_exist
		out = `#{mysql_base_command} -e "show tables"`
		if out.empty? then
			p "create database: #{@dbname}"
			p `#{mysql_base_command false} -e "create database #{@dbname}"`
			p `#{mysql_base_command} < #{@dir}/0_init.sql`
		end
	end		

	# ファイル名の頭に付いている番号を使ってディレクトリ以下に存在するmigrate SQLファイルを番号順に並べた配列を返す
	def make_migrater_list
		r = []
		last = 1
		Dir::foreach(File.expand_path(@dir, File.dirname(__FILE__))) do |f|
			if f =~ /(^[0-9]+)_.*?\.(sql|rb)/ then
				v = $1.to_i
				p "#{f} : sql for #{v}th migration"
				r[v] = [f, $2]
				last = ((not last or last > v) ? v : last)
			end
		end
		[1..last].each do |i|
			raise "#{i}th migrater should exist" if not r[i]
		end
		return r
	end

	# migrateの本体
	def migrate 
		create_db_if_not_exist
		version = check_or_add_db_version
		last_version = version
		list = make_migrater_list
		list.each_index do |idx|
			info = list[idx]
			next if not info
			mig = info[0]
			if idx <= last_version then
				p "migrate #{idx} already applied. skip"
				next
			end
			ext = info[1]
			p "apply #{idx} => #{mig}"
			case ext
			when 'rb' then
				system("ruby #{@dir}/#{mig} #{@dbname} #{@user} #{@password}")
			when 'sql' then
				p `#{mysql_base_command} < #{@dir}/#{mig}`
			else
				raise "invalid ext : #{ext}"
			end
			last_version = idx
		end
		# update db version
		p `#{mysql_base_command} -e "update version set number=#{last_version}"`
		p "now database version => #{last_version}"
	end
end

