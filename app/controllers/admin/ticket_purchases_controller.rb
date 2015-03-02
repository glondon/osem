module Admin
  class TicketPurchasesController < Admin::BaseController
    load_resource :conference, find_by: :short_title
    load_and_authorize_resource through: :conference

    def update
      if @ticket_purchase.update(ticket_purchase_params)
        if request.xhr?
          render js: 'show'
        else
          flash[:notice] = 'Successfully updated ticket purcase!'
          redirect_back_or_to admin_conference_ticket_path(@conference.short_title, @ticket_purchase.ticket)
        end
      else
        flash[:error] = 'Cound not update ticket purchase'
        redirect_back_or_to admin_conference_ticket_path(@conference.short_title, @ticket_purchase.ticket)
      end
    end

    private

    def ticket_purchase_params
      params.require(:ticket_purchase).permit(:paid)
    end
  end
end
