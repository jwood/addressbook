require 'prawn/labels'

class Group < ActiveRecord::Base
  has_and_belongs_to_many :addresses

  before_destroy :clear_address_associations

  validates_presence_of :name

  def self.find_for_list
    Group.order('name')
  end

  def addresses_not_included
    included_ids = self.address_ids
    if included_ids.blank?
      Address.eligible_for_group
    else
      Address.eligible_for_group.where(['id not in (?)', included_ids])
    end
  end

  def create_labels(label_type)
    Prawn::Labels.render(self.addresses, :type => label_type) do |pdf, a|
      pdf.text a.addressee
      pdf.text a.address1
      pdf.text a.address2 unless a.address2.blank?
      pdf.text a.city + ', ' + a.state + ' ' + a.zip
    end
  end

  private

    def clear_address_associations
      addresses.clear
    end

end
