# Require all Ruby gems located in Gemfile.
require 'bundler'
Bundler.require

# Include all models in lib/*/ folders.
require_relative 'environment'

module Rinku
  class App < Sinatra::Application

    # Configure Options
    # => set default paths of application.

    configure do
      set :root, File.dirname(__FILE__)
      set :public_folder, 'public'
    end

    # Database
    # => delete if not needed.

    set :database, "sqlite3:///database.db"

    # Filters
    # => add route filters if necessary.

    # Routes
    # => define controller actions for application.

    get '/' do
      erb :index
    end

    post '/' do
      @company_name = params[:company_name]
      @company_id   = Linkedin.get_company_id(@company_name.downcase.gsub(" ","%20"))
      @company_info = Linkedin.get_company_info(@company_id)

      erb :index
    end

    # Helpers
    # => define helper methods for application.

    helpers do
      def partial(file_name)
        erb file_name, :layout => false
      end
    end

  end
end