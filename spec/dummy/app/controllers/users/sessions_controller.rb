class Users::SessionsController < Users::ApplicationController
  include Breath::SessionsControllerHelper

  # GET /users/test
  def test
    render status: 200
  end
end
