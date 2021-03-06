class Linkedin

	@@consumer 		 = OAuth::Consumer.new(ENV['linkedin_api_key'], ENV['linkedin_secret_key'])
	@@access_token = OAuth::AccessToken.new(@@consumer, ENV['linkedin_oauth_token'], ENV['linkedin_oauth_secret'])

	@@fields 			 = ["company-type",
										"email-domains",
										"employee-count-range",
										"id",
										"locations:(contact-info:(phone1))",
										"industries",
										"name",
										"status",
										"website-url"]

	# Getter methods for class variables.

	def self.fields
		@@fields
	end

	def self.consumer
		@@consumer
	end

	def self.access_token
		@@access_token
	end

	# Helper methods.

	def self.field_string
		"(" + fields.join(",") + ")"
	end

	def self.collect_data(hash)
		count 		= hash["company"]["employee_count_range"]["name"]
		industry 	= hash["company"]["industries"]["industry"]["name"]
		name 			= hash["company"]["name"]
		status 		= hash["company"]["status"]["name"]
		type 			= hash["company"]["company_type"]["name"]
		url 			= hash["company"]["website_url"]

		email 		= parse_email(hash)
		phone 		= parse_phone(hash)

		return [count,email,industry,name,phone,status,type,url]
	end

	def self.parse_email(hash)
		email = hash["company"]["email_domains"]["email_domain"]
		email.is_a?(Array) ? email.join(", ") : email
	end

	def self.parse_phone(hash)
		if (hash["company"]["locations"]["location"].is_a?(Array))
			hash["company"]["locations"]["location"][0]["contact_info"]["phone1"] 
		else
			hash["company"]["locations"]["location"]["contact_info"]["phone1"] 
		end
	end

	# Search API for LinkedIn.

	def self.get_search_ids(company_name)
		body = access_token.get("http://api.linkedin.com/v1/company-search?keywords=#{company_name}.com&sort=relevance&count=10").body
		hash = Hash.from_xml(body)

		info  = hash["company_search"]["companies"]["company"]
		info.collect{ |hash| hash["id"]}
	end

	def self.get_company_result(company_id)
		body = access_token.get("http://api.linkedin.com/v1/companies/#{company_id}:#{field_string}").body
		Hash.from_xml(body)
	end

	def self.get_search_results(search_ids)
		search_ids.collect do |id|
      company_info = get_company_result(id)
      parse_search_info(company_info)
  	end
	end

	def self.parse_search_info(hash)
		name_search	= hash["company"]["name"]
		url_search	= hash["company"]["website_url"]
		id_search		= hash["company"]["id"]

		return [name_search,url_search,id_search]
	end

end