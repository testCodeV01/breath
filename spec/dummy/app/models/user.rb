class User < ApplicationRecord
  include Breath::Model

  attr_breath :email
end
