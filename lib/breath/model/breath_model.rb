module Breath::Model
  extend ActiveSupport::Concern

  attr_accessor :remember_token

  class_methods do
    # 与えられた文字列のハッシュ値を返す
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def new_token
      SecureRandom.urlsafe_base64
    end

    def attr_breath(attribute)
      class_attribute :auth_attribute, default: attribute
    end
  end

  included do
    has_secure_password
  end

  # 永続的セッションで使用するユーザーをデータベースに記憶する
  def remember
    self.remember_token = self.class.new_token
    update_attribute(:remember_digest, self.class.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def remember?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end
end
