require 'sinatra/base'
require './app/data_mapper_setup.rb'
require 'pry'
require 'tilt/erb'
require 'rack-flash'

class BookmarkManager < Sinatra::Base

  set :views, proc { File.join('app/views') }
  run! if app_file == $0
  enable :sessions
  set :sessions_secret, 'super secret'
  use Rack::Flash

  get '/links' do

    @links = Link.all

    erb :'links/index'
  end

  get '/links/new' do
    erb :'links/new'
  end

  post '/links' do
    link = Link.new( title: params[:title],
                     url:   params[:url  ] )
    tag_adder params[:tags], link
    link.save

    redirect to '/links'
  end

  get '/tags/:name' do
    
    tag = Tag.first name: params[:name]
    @links = tag ? tag.links : []

    erb :'links/index'
  end

  get '/users/new' do
    @user = User.new
    
    erb :'users/new'
  end

  post '/users' do
    @user = User.new( email:                 params[:email],
                      password:              params[:password],
                      password_confirmation: params[:password_confirmation] )
    if @user.save
      session[:user_id] = @user.id

      redirect to '/links'
    else
      flash.now[:notice] = 'Password and confirmation password do not match'
     
      erb :'users/new'
    end
    
  end

  helpers do

    def tag_adder params, link
      if params
        params.split.each { |tag| link.tags << Tag.create( name: tag ) }
      end
      
      link
    end

    def current_user
      @user ||= User.get session[:user_id] 
    end

  end

end
