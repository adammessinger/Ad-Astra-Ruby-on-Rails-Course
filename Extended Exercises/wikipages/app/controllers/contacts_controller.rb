class ContactsController < ApplicationController
  def index
    # get data from model
    @contacts = Contact.all
    #render view
    render('contacts/index.html.erb')
  end
end
