require "models/quote"

class QuotesController < Rulers::Controller
	def index
		@quotes = Quote.all
		render :index
	end

	def show
		 @obj = Quote.find(params["id"])
		render :quote
	end

	def exception
		raise "Ruh-roh, something went wrong!"
	end

	def create
		attrs = {
			"submitter" => "Azu",
			"quote" => "Maybe if I stay near my body long enough...",
			"attribution" => "Someone else"
		}
		@obj = Quote.create(attrs)
		render :quote
	end

	def update
		if !self.request.post?
			return "Does not respond to that verb"
		end

		@obj = Quote.find(params["id"])
		attrs = {submitter: "Me!"}
		@obj.update(attrs)
		self.quote_1
	end
end