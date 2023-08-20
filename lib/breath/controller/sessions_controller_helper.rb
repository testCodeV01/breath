module Breath
  module SessionsControllerHelper
    extend ActiveSupport::Concern

    class InvalidPasswordConfirmation < StandardError; end
    class TargetNotFound < StandardError; end
    class InvalidPassword < StandardError; end

    included do
      target_class = to_s.split("::")[-2].singularize.constantize
      target_name = target_class.to_s.underscore
      current_target = "current_#{target_name}"

      skip_before_action :authenticate!, only: %i[new login logout]

      # GET /schedule_kun/target
      define_method :new do
        render status: 200
      end

      # POST /schedule_kun/target/login
      define_method :login do
        raise InvalidPasswordConfirmation if sessions_params[:password] != sessions_params[:password_confirmation]

        object = target_class.enabled.find_by(**{ "#{target_class.auth_attribute}": sessions_params[target_class.auth_attribute.to_sym] })
        raise TargetNotFound if object.nil?
        raise InvalidPassword unless object.authenticate(sessions_params[:password])

        object.remember
        cookies.permanent.signed["#{target_name}_id".to_sym] = object.id
        cookies.permanent[:remember_token] = object.remember_token

        render status: 200
      rescue StandardError => e
        render_401 e.to_s
      end

      # DELETE /schedule_kun/target/logout
      define_method :logout do
        send(current_target).forget
        @current_target = nil

        cookies.delete("#{target_name}_id".to_sym)
        cookies.delete(:remember_token)

        render statud: 200
      end

      define_method :sessions_params do
        params.require(:sessions).permit(target_class.auth_attribute.to_sym, :password, :password_confirmation)
      end
    end
  end
end
