class AccountController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  load_and_authorize_resource class: "User"

  def show
   geo = @account.geozones_area_id
   if geo.blank? || geo==0
   flash[:alert] = "Debe seleccionar el barrio para continuar"
  end
 end
  def update
    if @account.update!(account_params)
      redirect_to account_path, notice: t("flash.actions.save_changes.notice")
    else
      @account.errors.messages.delete(:organization)
      render :show
    end
  end

  private

    def set_account
      @account = current_user
    end

    def account_params
      attributes = if @account.organization?
                     [:phone_number, :email_on_comment, :email_on_comment_reply, :newsletter,
                      organization_attributes: [:name, :responsible_name]]
                   else
                     [:username, :public_activity, :public_interests, :email_on_comment,
                      :email_on_comment_reply, :email_on_direct_message, :email_digest, :newsletter,
                      :official_position_badge, :recommended_debates, :recommended_proposals, :geozones_area_id]
                   end
      params.require(:account).permit(*attributes)
    end
end
