class PhonesController < ApplicationController
  before_action :load_contact

  def new
    @phone = @contact.phones.new
  end

  def create
    @phone = @contact.phones.create(params[:phone])
    if @phone.save
      redirect_to @contact
    else
      render('new')
    end
  end

private
  def load_contact
    @contact = Contact.find(params[:contact_id])
  end
end
