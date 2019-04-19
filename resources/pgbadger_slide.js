
jQuery(function (){
	jQuery('#pgbadger-brand').tooltip();

	jQuery("#pop-infos").popover('hide');
	jQuery('.slide').hide();
	jQuery('.active-slide').show();

	/* Go to specific slide and report from external link call */
	var activeMenu = location.hash;
	if (activeMenu) {
		activeMenu = activeMenu.substring(1);
		var lkobj = document.getElementById(activeMenu);
		var liId = jQuery(lkobj).parent().attr("id");
		if (liId != undefined) {
			var slideId = '#'+liId;
			jQuery('#main-container li.slide').removeClass('active-slide').hide();
			jQuery(slideId).addClass("active-slide").fadeIn();
			window.location.hash = '#'+activeMenu;
		}
	}

	jQuery('.navbar li.dropdown').click(function() {
		var id = jQuery(this).attr("id");
		id = id.substring(5);
		var slideId = '#'+id+'-slide';
		var currentSlide = jQuery('#main-container .active-slide').attr("id");
		currentSlide = '#'+currentSlide;

		if(slideId != currentSlide) {
			jQuery('#main-container li.slide').removeClass('active-slide').hide();
			jQuery(slideId).addClass("active-slide").fadeIn();
		}
		scrollTo(0,0);
		draw_charts();
	});

	jQuery('.navbar li ul li').click(function() {
		var liId = jQuery(this).parent().parent().attr("id");
		var id = liId.substring(5);
		var slideId = '#'+id+'-slide';
		jQuery('#main-container li.slide').removeClass('active-slide').hide();
		jQuery(slideId).addClass("active-slide").fadeIn();
		draw_charts();
	});

	draw_charts();
});

jQuery(document).ready(function () {
    jQuery('.sql').dblclick(function () {
        if (this.style == undefined || this.style.whiteSpace == 'pre') {
            this.style.whiteSpace ='normal';
        } else {
            this.style.whiteSpace = 'pre';
        }
    });
    jQuery('.icon-copy').click(function () {
        var obj = $(this).parent()[0];
        if (window.getSelection) {
            var sel = window.getSelection();
            sel.removeAllRanges();
            var range = document.createRange();
            range.selectNodeContents(obj);
            sel.addRange(range);
        } else if (document.selection) {
            var textRange = document.body.createTextRange();
            textRange.moveToElementText(obj);
            textRange.select();
        }
    });

	function shiftWindow() {
		scrollBy(0, -50);
	}

	if (location.hash) {
		shiftWindow();
	}
	window.addEventListener("hashchange",shiftWindow);
});

