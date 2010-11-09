class GroupsController < ApplicationController

  before_filter :load_group, :except => [:new, :create]

  def new
    @group = Group.new
    include_common_data
    render 'edit_group'
  end

  def create
    @group = Group.new(params[:group])
    @saved = @group.save
    @group_list = Group.find_for_list
    include_common_data
    render 'edit_group'
  end

  def show
    include_common_data
    render 'edit_group'
  end

  def update
    @group.attributes = params[:group]
    @group.addresses = (params[:included].blank? ? [] : Address.find(params[:included]))
    @saved = @group.save
    include_common_data
    render 'edit_group'
  end
  
  def destroy
    @group.ergo.destroy
    include_common_data
    render 'delete_group'
  end

  def create_labels
    file_path = @group.create_labels(params[:label_type])
    send_data(File.read(file_path), :filename => 'labels.pdf', :type => 'application/pdf')
    include_common_data
  end
  
  private

    def load_group
      @group = Group.find_by_id(params[:id])
    end

    def include_common_data
      @included = @group.addresses.includes([:contacts, :address_type])
      @not_included = @group.addresses_not_included
      @label_types = Pdf::Label::Batch.all_template_names.sort!
    end

end
