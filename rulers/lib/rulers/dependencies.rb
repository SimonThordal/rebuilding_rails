class Object
	def self.const_missing c
		if @calling_const_missing
			return nil
		end
		@calling_const_missing = true
		require Rulers.to_underscore(c.to_s)
		klass = Object.const_get(c)
		@calling_const_missing = false
		klass
	end
end