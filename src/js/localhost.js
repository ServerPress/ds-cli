(function($){
	$('.dev-sites tr').hover(function() {
		$(this).find('.ds-site-actions-container').show();
	}, function() {
		$(this).find('.ds-site-actions-container').hide();
	});

	$('.dev-sites .ds-site-actions-container .ds-action.ds-cli').on('click', function(e) {
		e.preventDefault();
		$.post($(this).attr('href'), {
			domain: $(this).data('domain')
		});
	});
})(jQuery);