require "multi_json"

module Rulers
	module Model
		class FileModel
			@@model_cache = {}
			
			def initialize(filename)
				@filename = filename

				basename = File.split(filename)[-1]
				@id = File.basename(basename, ".json").to_i

				obj = File.read(filename)
				@hash = MultiJson.load(obj)
			end

			def [](name)
				@hash[name.to_s]
			end

			def []=(name, value)
				@hash[name.to_s] = value
			end

			def update attrs
				@hash = @hash.merge(attrs)
				save
			end

			def save
				File.open("db/quotes/#{@id}.json", "w") do |f|
					f.write MultiJson.dump(@hash)
					@@model_cache[@id] = self
				end
				self
			end

			def method_missing method_name, *args, &block
				
				find_all_by_pat = /^find_all_by_(.*)/
				if method_name.match(find_all_by_pat)
					attribute = method_name.match(find_all_by_pat)[1]
					self.find_all_by(attribute, *args)
				end

			end

			def self.all
				files = Dir["db/quotes/*.json"]
				files.map { |f| FileModel.new f }
			end

			def self.find id
				begin
					if @@model_cache.key?(id)
						@@model_cache[id]
					else
						model = FileModel.new("db/quotes/#{id}.json")
						@@model_cache[id] = model
						model
					end
				rescue
					return nil
				end
			end

			def self.find_all_by attr, value
				self.all.filter do |model|
					model[attr] == value
				end
			end

			def self.create attrs
				hash = {}
				hash["submitter"] = attrs[:submitter] || ""
				hash["quote"] = attrs[:quote] || ""
				hash["attribution"] = attrs[:attribution] || ""

				files = Dir["db/quotes/*.json"]
				names = files.map { |f| File.split(f)[-1] }
				highest = names.map { |b| b.to_i }.max
				id = highest + 1

				File.open("db/quotes/#{id}.json", "w") do |f|
					f.write MultiJson.dump(hash)
				end
				FileModel.new "db/quotes/#{id}.json"
			end
		end
	end
end