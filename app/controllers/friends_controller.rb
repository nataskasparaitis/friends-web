class FriendsController < ApplicationController
  before_action :authenticate_user!                                    # every action requires a signed-in user
  before_action :set_friend, only: %i[ show edit update destroy ]      # and every record is looked up through that user

  # GET /friends or /friends.json
  def index
    @query   = params[:q].to_s.strip
    @friends = current_user.friends.search(@query).order(:first_name, :last_name)
  end

  # GET /friends/1 or /friends/1.json
  def show
  end

  # GET /friends/new
  def new
    @friend = current_user.friends.build
  end

  # GET /friends/1/edit
  def edit
  end

  # POST /friends or /friends.json
  def create
    @friend = current_user.friends.build(friend_params)

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

  private
    # Scoping the lookup to current_user.friends means someone else's record is
    # simply not found, so show, edit, update and destroy are all protected by
    # the same query rather than by a separate ownership check.
    def set_friend
      @friend = current_user.friends.find_by(id: params[:id])
      return if @friend

      respond_to do |format|
        format.html { redirect_to friends_path, alert: "That friend was not found in your list.", status: :see_other }
        format.json { head :not_found }
      end
    end

    # user_id is deliberately not permitted: ownership comes from current_user.
    def friend_params
      params.expect(friend: [ :first_name, :last_name, :email, :phone, :twitter ])
    end
end
