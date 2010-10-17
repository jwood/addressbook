class GroupController < ApplicationController

  def edit_group
    @group = Group.find_by_id(params[:id]) || Group.new

    if request.post?
      new_group = true if params[:id].nil?
      @group.attributes = params[:group]
      @group.addresses = (params[:included].blank? ? [] : Address.find(params[:included]))
      @saved = @group.save
    end

    @group_list = Group.find_for_list if new_group
    include_common_data
  end
  
  def delete_group
    @group = Group.find_by_id(params[:id])
    @group.ergo.destroy
    include_common_data
  end

  def create_labels
    @group = Group.find_by_id(params[:id])
    file_path = @group.create_labels(params[:label_type])
    send_data(File.read(file_path), :filename => "labels.pdf", :type => "application/pdf")
    include_common_data
  end
  
  private

    def include_common_data
      @included = @group.addresses.includes([:contacts, :address_type])
      @not_included = @group.addresses_not_included
      @label_types = Pdf::Label::Batch.all_template_names.sort!
    end

end
