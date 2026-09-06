class HomeController < ApplicationController

  def index
  end

  def about
    @about_me = "My name is Natas Kasparaitis"  # @ means instance variable
  end
  
end
