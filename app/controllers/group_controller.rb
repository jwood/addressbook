class GroupController < ApplicationController
  require 'rubygems'
  require 'pdf/label'

  def edit_group
    @group = params[:id] && Group.find_by_id(params[:id]) || Group.new
    if request.post?
      new_group = true if params[:id].nil?
      @group.attributes = params[:group]
      if @group.save
        @saved = true
      else
        logger.error("Edit group failed: #{@group.errors.full_messages}")
      end
    end
    @group_list = Group.find_for_list if new_group
    include_common_data
  end
  
  def delete_group
    @group = Group.find_by_id(params[:id])
    @group.destroy if @group
    include_common_data
  end

  def add_address_to_group
    address = Address.find_by_id(params[:id])
    @group = Group.find_by_id(params[:group_id])
    @group.addresses << address unless @group.addresses.include?(address)
    include_common_data
    render(:action => 'update_address_group_lists')
  end

  def remove_address_from_group
    address = Address.find_by_id(params[:id])
    @group = Group.find_by_id(params[:group_id])
    @group.addresses.delete(address)
    include_common_data
    render(:action => 'update_address_group_lists')
  end
  
  def remove_all_addresses
    @group = Group.find_by_id(params[:id])
    @group.addresses.clear
    include_common_data
    render(:action => 'update_address_group_lists')
  end
  
  def add_all_addresses
    @group = Group.find_by_id(params[:id])
    @group.addresses = Address.find_all_eligible_for_group
    include_common_data
    render(:action => 'update_address_group_lists')
  end
  
  def create_labels
    @group = Group.find_by_id(params[:id])
    p = Pdf::Label::Batch.new(params[:label_type].sub(' ', '  '))

    pos = 0
    @group.addresses.each do |a|
      label_text =  a.addressee + "\n"
      label_text += a.address1 + "\n"
      label_text += a.address2 + "\n" unless a.address2.blank?
      label_text += a.city + ", " + a.state + " " + a.zip
      p.add_label(:text => label_text,
        :position => pos,
        :font_size => 10,
        :justification => :center)
      pos = pos.next
    end

    app_root = File::join RAILS_ROOT, "public"
    p.save_as("#{app_root}/mailing_labels.pdf")
    include_common_data
    redirect_to('/mailing_labels.pdf')
  end
  
  private

    def get_not_included_addresses
      addresses = Address.find_all_eligible_for_group
      included_addresses = @group.addresses
      included_addresses.each { |a| addresses.delete(a) }
      addresses
    end

    def include_common_data
      @included = @group.addresses
      @not_included = get_not_included_addresses
      @label_types = Pdf::Label::Batch.all_template_names.sort!
    end

end
