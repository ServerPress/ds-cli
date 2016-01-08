(function($){
    $(function(){
        $('li#wp-admin-bar-ds-cli a').click(function() {
            $.post(
                ds_cli.ajaxurl, {
                    action : 'ds-cli-submit',
                    nonce : ds_cli.nonce
                }
            );
        });
    });
})(jQuery);