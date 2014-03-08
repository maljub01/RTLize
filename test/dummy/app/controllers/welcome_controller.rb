class WelcomeController < ApplicationController
  def index
    render :layout => "application", :inline => ""
  end
end
