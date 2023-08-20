module Breath
  module ApplicationControllerHelper
    extend ActiveSupport::Concern

    class AuthenticationError < StandardError; end

    included do
      target_class = to_s.split("::")[-2].singularize.constantize
      target_name = target_class.to_s.underscore
      current_target = "current_#{target_name}"

      define_method :authenticate! do
        raise AuthenticationError unless cookies.key?("#{target_name}_id".to_sym)
        raise AuthenticationError if send(current_target).nil?
        raise AuthenticationError unless send(current_target).remember?(cookies[:remember_token])

        target = target_class.enabled.find_by(id: cookies.signed["#{target_name}_id".to_sym])

        raise AuthenticationError if target.nil?
      rescue StandardError => e
        render_401 e
      end

      define_method current_target do
        @current_target ||= target_class.enabled.find_by(id: cookies.signed["#{target_name}_id".to_sym])
      end
    end
  end
end
