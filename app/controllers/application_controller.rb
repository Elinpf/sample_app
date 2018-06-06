class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

	# 因为Sessions模块会用在很多Controller中，所以在这个地方统一include
	include SessionsHelper
end
