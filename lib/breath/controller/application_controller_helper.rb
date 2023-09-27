module Breath
  module ApplicationControllerHelper
    extend ActiveSupport::Concern

    class AuthenticationError < StandardError; end

    included do
      rescue_from StandardError, with: :render_500
      rescue_from ActionController::InvalidAuthenticityToken, with: :render_422


      target_class = to_s.split("::")[-2].singularize.constantize
      target_name = target_class.to_s.underscore
      current_target = "current_#{target_name}"

      include ActionController::Cookies
    
      define_method :authenticate! do
        raise AuthenticationError unless cookies.key?("#{target_name}_id".to_sym)
        raise AuthenticationError if send(current_target).nil?
        raise AuthenticationError unless send(current_target).remember?(cookies[:remember_token])

        target = target_class.enabled.find_by(id: cookies.signed["#{target_name}_id".to_sym])

        raise AuthenticationError if target.nil?
      rescue StandardError => e
        send :render_401, e
      end

      define_method current_target do
        @current_target ||= target_class.enabled.find_by(id: cookies.signed["#{target_name}_id".to_sym])
      end
    end

    class_methods do
      def crsf_protect(value)
        if value
          # include ActionController::HttpAuthentication::Token::ControllerMethods
          include ActionController::RequestForgeryProtection
          protect_from_forgery with: :exception
          after_action :set_csrf_token_header

          define_method :set_csrf_token_header do
            response.header["X-CSRF-Token"] = form_authenticity_token
          end
        end
      end
    end

    def render_400(res)
      Rails.logger.error error_message(res)
  
      render json: res, status: 400
    end
  
    def render_401(res)
      Rails.logger.error error_message(res)
  
      render json: res, status: 401
    end
  
    def render_404(res)
      Rails.logger.error error_message(res)
  
      render json: res, status: 404
    end
  
    def render_409(res)
      Rails.logger.error error_message(res)
  
      render json: res, status: 409
    end

    def render_422(res)
      Rails.logger.error error_message(res)
  
      render json: res, status: 422
    end
  
    def render_500(res)
      Rails.logger.error error_message(res)
  
      render json: res, status: 500
    end
  
    def error_message(error)
      "[ERROR] #{error.to_s}"
    end
  end
end
