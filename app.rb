require 'sinatra'
require 'sinatra/activerecord'
require 'haml'

set :database, 'sqlite3:///shortened_urls.db'

class ShortenedUrl < ActiveRecord::Base
   validates_uniqueness_of :url, :allow_blank => true
   validates_presence_of :url
   validates_format_of :url,
      :with => %r{^(https?|ftp)://.+}i,
      :allow_blank => true,
      :message => "The URL must start with http://, https://, or ftp:// ."
end

get '/' do
   haml :index
end

post '/' do
  @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
  if @short_url.valid?
    haml :success, :locals => { :address => settings.address }
  else
    haml :index
  end
end

get '/:shortened' do
  short_url = ShortenedUrl.find(params[:shortened].to_i(36))
  redirect short_url.url
end