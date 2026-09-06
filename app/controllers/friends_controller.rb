class FriendsController < ApplicationController
  before_action :set_friend, only: %i[ show edit update destroy ]
  #before_action :authenticate_user!, except: [:index, :show]  # if the user is not authenticated dont let them call anything except 'index' and 'show'
  before_action :authenticate_user!   # if user not signed in, redirect to sign in page
  before_action :correct_user, only: [:edit, :update, :destroy]   # make sure its the correct user but only for pages that want to 'edit', 'update', or 'destroy'


  # GET /friends or /friends.json
  def index
    @friends = Friend.all
  end

  # GET /friends/1 or /friends/1.json
  def show
  end

  # GET /friends/new
  def new
    #@friend = Friend.new
    @friend = current_user.friends.build  # modified so each user would have their own friend list
  end

  # GET /friends/1/edit
  def edit
  end

  # POST /friends or /friends.json
  def create
    #@friend = Friend.new(friend_params)
    @friend = current_user.friends.build(friend_params)   # modified so each user would have their own friend list

    respond_to do |format|
      if @friend.save
        format.html { redirect_to @friend, notice: "Friend was successfully created." }
        format.json { render :show, status: :created, location: @friend }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @friend.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /friends/1 or /friends/1.json
  def update
    respond_to do |format|
      if @friend.update(friend_params)
        format.html { redirect_to @friend, notice: "Friend was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @friend }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @friend.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /friends/1 or /friends/1.json
  def destroy
    @friend.destroy!

    respond_to do |format|
      format.html { redirect_to friends_path, notice: "Friend was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def correct_user
    @friend = current_user.friends.find_by(id: params[:id])   # is the current user the one that created this specific friend 
    redirect_to friends_path, notice: "Not Authorized To Edit This Friend" if @friend.nil?  # if not throw error message
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_friend
      @friend = Friend.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def friend_params
      params.expect(friend: [ :first_name, :last_name, :email, :phone, :twitter, :user_id ])
    end
end
