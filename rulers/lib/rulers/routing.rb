module Rulers
	class RouteObject
		def initialize
			@rules = []
		end

		def root *args
			match("/", *args)
		end

		def match url, *args
			options = {}
			options = args.pop if args[-1].is_a?(Hash)
			options[:default] ||= {}

			dest = nil
			dest = args.pop if args.size > 0
			raise "Too many args!" if args.size > 0

			parts = url.split("/")
			parts.select! { |p| !parts.empty? }

			regexp_parts = parts.map do |part|
				if part[0] == ":"
					"(?<#{part[1..-1]}>[a-zA-Z0-9]+)"
				elsif part[0] == "*"
					"(?<#{part[1..-1]}>.*)"
				else
					part
				end
			end

			regexp = regexp_parts.join("/")
			@rules.push({
				regexp: Regexp.new("^/#{regexp}$"),
				dest: dest,
				options: options
			})
		end

		def url_to_parts url
		end

		def check_url url
			@rules.each do |rule|
				match = rule[:regexp].match(url)
				if match
					puts rule
					options = rule[:options]
					params = options[:default].dup
					params.merge!(match.named_captures)
					dest = nil
					if rule[:dest]
						return get_dest(rule[:dest], params)
					else
						controller = params["controller"]
						action = params["action"]
						return get_dest("#{controller}" + "##{action}", params)
					end
				end
			end
			nil
		end

		def get_dest dest, routing_params = {}
			return dest if dest.respond_to? :call
			if dest =~ /^([^#]+)#([^#]+)$/
				name = $1.capitalize
				con = Object.const_get("#{name}Controller")
				return con.action($2, routing_params)
			end
			raise "No destination: #{dest.inspect}!"
		end
	end

	class Application
		def route &block
			@route_obj ||= RouteObject.new
			@route_obj.instance_eval(&block)
		end

		def get_rack_app env
			raise "No routes!" unless @route_obj
			@route_obj.check_url env["PATH_INFO"]
		end
	end
end