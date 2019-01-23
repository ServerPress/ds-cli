(function($){
//	$('.dev-sites tr').hover(function() {
//		$(this).find('.ds-site-actions-container').show();
//	}, function() {
//		$(this).find('.ds-site-actions-container').hide();
//	});

	$('.dev-sites .btn-group .ds-cli').on('click', function(e) {
		e.preventDefault();
		$.post($(this).attr('href'), {
			domain: $(this).data('domain')
		});
	});
})(jQuery);
