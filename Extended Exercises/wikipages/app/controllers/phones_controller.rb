class PhonesController < ApplicationController
  before_action :load_contact

  def new
    @phone = @contact.phones.new
  end

  def create
    @phone = @contact.phones.create(number: params[:number])
    if @phone.save
      redirect_to @contact
    else
      # render('phones/new.html.erb')
      render('new')
    end
  end

private
  def load_contact
    @contact = Contact.find(params[:contact_id])
  end
end
