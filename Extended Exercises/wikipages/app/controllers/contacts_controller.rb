class ContactsController < ApplicationController
  def index
    @contacts = Contact.all

    respond_to do |wants|
      wants.html
      wants.json {render(json: @contacts)}
    end
  end

  def show
    @contact = Contact.find(params[:id])

    respond_to do |wants|
      wants.html
      wants.json {render(json: @contact)}
    end
  end

  def new
    @contact = Contact.new
  end

  def create
    # NOTE: Calling render doesn't leave this method, so all vars available to
    # this method are available to the rendered view.

    @contact = Contact.new(params[:contact])

    if @contact.save
      respond_to do |wants|
        wants.html do
          flash[:notice] = 'Huzzah! Contact created.'
          redirect_to @contact
        end
        wants.json {render(json: @contact, status: 201)}
      end
    else
      respond_to do |wants|
        wants.html {render('new')}
        wants.json {render(json: @contact.errors, status: 422)}
      end
    end
  end

  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    @contact = Contact.find(params[:id])

    if @contact.update(params[:contact])
      respond_to do |wants|
        wants.html do
          flash[:notice] = 'Boo yah! Contact updated.'
          redirect_to @contact
        end
        wants.json {head :no_content}
      end
    else
      respond_to do |wants|
        wants.html {render 'edit'}
        wants.json {render(json: @contact.errors, status: 422)}
      end
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy

    respond_to do |wants|
      wants.html do
        flash[:notice]="Contact deleted."
        redirect_to contacts_path
      end
      wants.json {head :no_content}
    end
  end
end
