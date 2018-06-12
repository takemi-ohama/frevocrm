/* ********************************************************************************
 * The content of this file is subject to the Calendar Popup ("License");
 * You may not use this file except in compliance with the License
 * The Initial Developer of the Original Code is VTExperts.com
 * Portions created by VTExperts.com. are Copyright(C) VTExperts.com.
 * All Rights Reserved.
 * ****************************************************************************** */


jQuery(document).ready(function () {
	var push_delete = false;
	jQuery(document).on("click", "a.delete", function(e) {
		push_delete = true;
	});
	jQuery(document).on("click", "a.fc-event,a.add-event", function(e) {
		if( !push_delete ) {
			var orgUrl=jQuery(this).attr('href');
	        if(orgUrl.indexOf('module=Calendar') != -1) {
	        	var url = orgUrl.replace('Detail','PopupEdit') + '';
	        	var iframe = $('<iframe scrolling="auto" id="externalSite" class="externalSite" src="' + url + '" />');
	        	iframe.dialog({
					title: '活動編集',
					autoOpen: true,
					width: "60%",
					height: "500",
					modal: true,
					resizable: false,
					autoResize: false,
					zIndex: 9999,
					close : function(){
						$("#externalSite").remove();
					}
				});
	        	iframe.css('width', '100%');
				e.stopPropagation();
				e.preventDefault();
			    return false;
	        }
		}
		push_delete = false;
	});
	
	$( document ).on( "click", ".ui-widget-overlay", function(){
	    $(this).prev().find(".ui-dialog-content").dialog("close");
	} );

});