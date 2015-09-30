// <div class="form-control shown-with" rel="[name=other_field]@value">
(function($) {
    var mk_shown_with = curry(function(options, index, obj) {
        var $toggled_elem = $(this);
        var with_parts = $toggled_elem.attr('rel').split('@');
        
        function with_test() {
            var $this = $(this);

            if (with_parts[1]) {
                return $this.val() == with_parts[1];
            }
            else {
                return !! $this.val();
            }
        }

        function showhide() {
            if (with_test.call(this)) {
                $toggled_elem[options.show]();
            }
            else {
                $toggled_elem[options.hide]();
            }
        }

        $(document).on('change', with_parts[0], showhide);

        // Avoid using animations when the page loads.
        if (! with_test.call(this)) {
            $toggled_elem.hide();
        }
    });

    $.fn.shownWith = function(options) {
        var defaults = {
            show: 'show',
            hide: 'hide'
        };
        options = $.extend({}, defaults, options);
        this.each(mk_shown_with(options));
    }
})(jQuery);
