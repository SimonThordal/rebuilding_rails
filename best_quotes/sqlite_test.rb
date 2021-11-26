require "sqlite3"
require "rulers/sqlite_model"

class MyTable < Rulers::Model::SQLiteModel;
	["title"].each do |method|
		define_method(method) {
			self[method]
		}
		
	end
end
STDERR.puts MyTable.schema.inspect

mt = MyTable.create("title" => "I saw it again!")

mt["title"] = "Ooooh, that is a newer title and it is newer!"

mt.save!

top_id = mt["id"].to_i
(1..top_id).each do |id|
	mt_id = MyTable.find(id)
	puts "Found title #{mt_id.title}."
end