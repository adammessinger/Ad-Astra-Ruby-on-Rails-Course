class PhonesController < ApplicationController
  before_action :load_contact

  def new
    @phone = @contact.phones.new
    # render('phones/new.html.erb')
  end

  def create
    @phone = @contact.phones.create(number: params[:number])
    if @phone.save
      redirect_to("/contacts/#{params[:contact_id]}")
      # NOTE: the following requires the magical auto-routing Jarrett prefers
      # redirect_to @contact
    else
      render('phones/new.html.erb')
    end
  end

private
  def load_contact
    @contact = Contact.find(params[:contact_id])
  end
end
