class Users::ApplicationController < ApplicationController
  include Breath::ApplicationControllerHelper
  before_action :authenticate!

  crsf_protect false

  def render_422(res)
    Rails.logger.info("TEST")

    super
  end

  def render_401(res)
    Rails.logger.info("TEST2")

    super
  end
end
