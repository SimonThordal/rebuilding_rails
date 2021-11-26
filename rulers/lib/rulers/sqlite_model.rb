require "sqlite3"
require "rulers/util"
require 'webrick'

DB = SQLite3::Database.new "test.db"

module Rulers
	module Model
		class SQLiteModel
			def initialize hash={}
				@hash = hash.transform_keys(&:to_sym)
			end

			def self.table
				Rulers.to_underscore name
			end

			def self.schema
				return @schema if @schema
				@schema = {}
				DB.table_info(table) do |row|
					@schema[row["name"]] = row["type"]
				end
				@schema
			end

			def self.create values
				values.delete("id")
				keys = schema.keys - ["id"]
				sqlized_vals = keys.map do |key|
					values[key] ? to_sql(values[key]) : "null"
				end
				DB.execute %Q(
					INSERT INTO #{table} (#{keys.join(",")})
					VALUES (#{sqlized_vals.join(",")});
				)
				raw_vals = keys.map { |k| values[k] }
				data = Hash[keys.zip(raw_vals)]
				sql = "SELECT last_insert_rowid();"
				data["id"] = DB.execute(sql)[0][0]
				self.new(data)
			end

			def self.count
				query = %Q(
					SELECT COUNT(*) FROM #{table}
				)
				DB.execute(query)[0][0]
			end

			def self.all
				query = %Q(
					SELECT #{schema.keys.join ","} FROM #{table}
				)
				rows = DB.execute(query)
				rows.map do |row|
					data = Hash[schema.keys.zip row]
					self.new(data)
				end
			end

			def self.find id
				query = %Q(
					SELECT #{schema.keys.join ","} FROM #{table}
					WHERE id = #{id};
				)
				row = DB.execute(query)
				data = Hash[schema.keys.zip row[0]]
				self.new(data)
			end

			def method_missing method_name, *args, &block
				if @hash.has_key? method_name.to_sym
					self.set_accessor(method_name)
					self.send(method_name)
				end
			end

			def respond_to_missing? method_name, include_private=false
				if @hash.has_key? method_name.to_sym
					true
				end
			end

			def save!
				unless @hash["id"]
					self.class.create
					return true
				end
				fields = @hash.map do |k, v|
					"#{k}=#{self.class.to_sql(v)}"
				end.join(",")
				query = %Q(
					UPDATE #{self.class.table}
					SET #{fields}
					WHERE id = #{@hash["id"]}
				)
				DB.execute(query)
				true
			end

			def save
				self.save! rescue false
			end

			def [](name)
				@hash[name.to_sym]
			end

			def []=(name, value)
				@hash[name.to_sym] = value
			end

			def self.to_sql val
				case val
				when NilClass
					"null"
				when Numeric
					val.to_s
				when String
					"'#{val}'"
				else
					raise "Can't cast #{val.class} to SQL"
				end
			end

			def set_accessor method_name
				class_eval do
					define_method(method_name.to_sym) {
						self[method_name]
					}
				end
			end
		end
	end
end