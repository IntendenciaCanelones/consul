class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :authenticate_scope!, only: [:edit, :update!, :destroy, :finish_signup, :do_finish_signup]
  before_action :configure_permitted_parameters

  before_action :restrict_presential_signups_by_ip, only: :create

  invisible_captcha only: [:create], honeypot: :address, scope: :user

  def new
    super do |user|
      user.use_redeemable_code = true if params[:use_redeemable_code].present?
    end
  end

  def create
    build_resource(sign_up_params)
    if resource.valid?
      super
    else
      render :new
    end
  end

  def delete_form
    build_resource({})
  end

  def delete
    current_user.erase(erase_params[:erase_reason])
    sign_out
    redirect_to root_path, notice: t("devise.registrations.destroyed")
  end

  def success
  end

  def finish_signup
    current_user.registering_with_oauth = false
    current_user.email = current_user.oauth_email if current_user.email.blank?
    current_user.validate
  end

  def do_finish_signup
    current_user.registering_with_oauth = false
    if current_user.update(sign_up_params)
      current_user.send_oauth_confirmation_instructions
      sign_in_and_redirect current_user, event: :authentication
    else
      render :finish_signup
    end
  end

  def check_username
    if User.find_by username: params[:username]
      render json: { available: false, message: t("devise_views.users.registrations.new.username_is_not_available") }
    else
      render json: { available: true, message: t("devise_views.users.registrations.new.username_is_available") }
    end
  end

  private

    def sign_up_params
      params[:user].delete(:redeemable_code) if params[:user].present? && params[:user][:redeemable_code].blank?
      params.require(:user).permit(:username, :email, :email_confirmation, :password,
                                   :password_confirmation, :terms_of_service, :terms_of_declaration, :locale,
                                   :redeemable_code, :document_number, :date_of_birth, :gender, :domicilio, :phone_number, :geozone_id, :geozones_area_id)
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:account_update, keys: [:email])
    end

    def erase_params
      params.require(:user).permit(:erase_reason)
    end

    def after_inactive_sign_up_path_for(resource_or_scope)
      users_sign_up_success_path
    end

    # ------------------------------------------------------------
    # Restricción de registros "presenciales" por IP de origen
    # ------------------------------------------------------------
    require "ipaddr"

    PRESENTIAL_EMAIL_DOMAIN = "decide.canelones.gub.uy".freeze

    PRESENTIAL_ALLOWED_CIDRS = [
      "10.254.0.227/32"
      #"10.0.0.0/8",        # Intranet   (Esto es para la instancia de testing. Para la instancia en producción cambiar por "10.254.0.227/32", que es la ip con la que llegan enmascarados los hosts desde intranet)
      #"192.168.0.0/16"     # Tablets VPN  (Esto es para la instancia de testing. Para la instancia en producción esta línea directamente NO VA, porque este rango también va a salir enmascarado con la ip anterior)
    ].map { |c| IPAddr.new(c) }.freeze

    def restrict_presential_signups_by_ip
      email = params.dig(:user, :email).to_s.downcase.strip
      return if email.blank?

      # Si NO es dominio institucional, no se restringe
      presential = email.end_with?("@#{PRESENTIAL_EMAIL_DOMAIN}")
      return unless presential

      ip = request.remote_ip.to_s

      unless ip_allowed_for_presential?(ip)
        flash[:alert] = "Los registros para usuarios presenciales (@decide.canelones.gub.uy) solo están habilitado desde la red interna."
        redirect_to new_user_registration_path
      end
    end

    def ip_allowed_for_presential?(ip_string)
      ip = IPAddr.new(ip_string)
      PRESENTIAL_ALLOWED_CIDRS.any? { |cidr| cidr.include?(ip) }
    rescue IPAddr::InvalidAddressError
      false
    end
end
