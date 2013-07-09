require Rails.root + 'lib/mobile-fu/lib/mobile_fu_helper.rb'
require Rails.root + 'lib/mobile-fu/lib/mobilized_styles'
require Rails.root + 'lib/mobile-fu/lib/mobile_fu'

ActionView::Base.send(:include, MobileFuHelper)
ActionView::Base.send(:include, MobilizedStyles)
ActionView::Base.send(:alias_method_chain, :stylesheet_link_tag, :mobilization)
