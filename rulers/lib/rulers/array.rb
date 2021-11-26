class Array
	def sum(start = 0)
		inject(start, &:+)
	end

	def dot()
		inject(0) { |sum, i|
			sum + i**2
		}
	end
end