require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

	configure do
		set :views, "app/views"
		enable :sessions
		set :session_secret, "password_security"
	end

	get "/" do
		erb :index
	end

	get "/signup" do
		erb :signup
	end

	post "/signup" do
		user = User.new(:username => params[:username], :password => params[:password])
		#uses has_secure_password as piece of magic in User to ensure the user actually
		#enters a password. Without a password, AR will not be able to save the user.
		#shotgun shows a begin transaction...rollback transaction
		if user.save
			redirect to "/login"
		else
			redirect to "/failure"
		end
	end

	get "/login" do
		erb :login
	end

	#has_secure_password adds #authenticate to Users
	# 1. takes string as arg
	# 2. turns it into a salted, hashed version
	# 3. copares this salted hash to the hashed password (?password_digest?)
	# 4. if matches, returns user instance ELSE false
	post "/login" do
		user = User.find_by(:username => params[:username])
		if user && user.authenticate(params[:password])
			session[:user_id] = user.id
			redirect to "/success"
		else
			redirect to "/failure"
		end
	end

	get "/success" do
		if logged_in?
			erb :success
		else
			redirect "/login"
		end
	end

	get "/failure" do
		erb :failure
	end

	get "/logout" do
		session.clear
		redirect "/"
	end

	helpers do
		def logged_in?
			!!session[:user_id]
		end

		def current_user
			User.find(session[:user_id])
		end
	end

end
