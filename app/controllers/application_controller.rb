class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_filter :require_signin_permission!
  before_filter :require_action_enabled!

  protect_from_forgery

  def error_400; error 400; end
  def error_404; error 404; end
  def error_501(unavailable_error)
    render status: 501, text: unavailable_error.to_s
  end

  rescue_from ActiveRecord::RecordNotFound, with: :error_404
  rescue_from Transition::FeatureUnavailableError, with: :error_501

  protected

  def find_site
    @site = Site.find(params[:site_id])
  end

  private

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end

  def require_action_enabled!
    return unless DISABLE_EDITING
    gds_sso_controllers = [Api::UserController, AuthenticationsController]
    return if gds_sso_controllers.detect { |skippable| self.is_a?(skippable) }

    enabled_actions = ['show', 'index', 'hits_download']
    unless enabled_actions.include?(params[:action])
      raise Transition::FeatureUnavailableError.new(params[:controller], params[:action])
    end
  end
end
