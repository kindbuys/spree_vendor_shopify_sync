$(function() {
  $('#import-shopify-btn').click(function(){
  	if (confirm('Are you sure?  This will deactivate all of your existing products.')) {
      $.ajax({
		url: '/admin/shopify_sync/import_products',
	  }).done(function() {
		$('#import-shopify-btn').hide();
		$('#import-confirmation').slideDown();
	  }).fail(function() {
		$('#import-shopify-btn').hide();
		$('#import-error').slideDown();
	  });
    }
  })
})