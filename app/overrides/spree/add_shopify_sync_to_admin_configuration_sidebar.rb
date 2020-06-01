Deface::Override.new(
    virtual_path: 'spree/admin/shared/sub_menu/_configuration',
    name: 'add_shopify_sync_to_admin_configuration_sidebar',
    insert_bottom: '[data-hook="admin_configurations_sidebar_menu"]',
    text: <<-HTML
    	<% if defined?(current_spree_vendor) && current_spree_vendor %>
    		<%= configurations_sidebar_menu_item Spree.t(:shopify_sync), admin_shopify_sync_path %>
    	<% end %>
    HTML
)
