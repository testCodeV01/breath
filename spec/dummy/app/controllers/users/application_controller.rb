class Users::ApplicationController < ApplicationController
  include Breath::ApplicationControllerHelper
  before_action :authenticate!

  crsf_protect false
end
