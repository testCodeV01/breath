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

      # GET /schedule_kun/target/login
      define_method :new do
        render status: 200
      end

      # POST /schedule_kun/target/login
      define_method :login do
        object = target_class.enabled.find_by(**{ "#{target_class.auth_attribute}": sessions_params[target_class.auth_attribute.to_sym] })
        raise TargetNotFound if object.nil?
        raise InvalidPassword unless object.authenticate(sessions_params[:password])

        object.remember
        write_cookie(target_name, object)

        render status: 200
      rescue StandardError => e
        send :render_401, e.to_s
      end

      # DELETE /schedule_kun/target/logout
      define_method :logout do
        send(current_target)&.forget
        @current_target = nil

        cookies.delete("#{target_name}_id".to_sym)
        cookies.delete(:remember_token)

        render status: 200
      end

      define_method :sessions_params do
        params.require(:sessions).permit(target_class.auth_attribute.to_sym, :password, :password_confirmation)
      end
    end

    def write_cookie(target_name, object)
      if Rails.application.config.respond_to? :breath_expires
        cookies.signed["#{target_name}_id".to_sym] = { value: object.id, expires: Rails.application.config.breath_expires }
        cookies[:remember_token] = { value: object.remember_token, expires: Rails.application.config.breath_expires }
      else
        cookies.permanent.signed["#{target_name}_id".to_sym] = object.id
        cookies.permanent[:remember_token] = object.remember_token
      end
    end
  end
end
