require 'sinatra'
require 'sinatra/activerecord'
require 'haml'

set :database, 'sqlite3:///shortened_urls.db'

class ShortenedUrl < ActiveRecord::Base
   # Validates whether the value of the specified attributes are unique across the system.
   validates_uniqueness_of :url, :custom_url, :allow_blank => true
   # Validates that the specified attributes are not blank
   validates_presence_of :url
   #validates_format_of :url, :with => /.*/
   validates_format_of :url, 
      :with => %r{^(https?|ftp)://.+}i,
      :allow_blank => true, 
      :message => "The URL must start with http://, https://, or ftp:// ."
end

get '/' do
   haml :index
end

post '/' do
   if params[:custom].empty?
      @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
   else
      @short_url = ShortenedUrl.find_or_create_by_url_and_custom_url(params[:url], params[:custom])
   end
   if @short_url.valid?
      haml :success
   else
      haml :index
   end
end

get '/showall' do
   haml :showall, :locals => { :k => ShortenedUrl.all }
end

get '/search_abr' do
   haml :search_abr
end

post '/search_abr' do
   begin
      search_url = ShortenedUrl.find(params[:abr].to_i(36))
   rescue
      search_url = ShortenedUrl.find_by_custom_url(params[:abr])
   end
   haml :result_search_abr, :locals => { :u => search_url }
end

get '/search_url' do
   haml :search_url
end

post '/search_url' do
   search_abr = ShortenedUrl.find_by_url!("#{params[:ur]}")
   haml :result_search_url, :locals => { :v => search_abr }
end

get '/:shortened' do
   if params[:shortened] =~ /[0-9]+/
      short_url = ShortenedUrl.find(params[:shortened].to_i(36))
      redirect short_url.url, 301
   end
end
