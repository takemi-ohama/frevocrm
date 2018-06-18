/*+***********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 *************************************************************************************/


Vtiger_List_Js("Calendar_List_Js",{

	triggerMassEdit : function(massEditUrl) {
		Vtiger_List_Js.triggerMassAction(massEditUrl, function(container){
			var massEditForm = container.find('#massEdit');
			massEditForm.validationEngine(app.validationEngineOptions);
			var listInstance = Vtiger_List_Js.getInstance();
			var editInstance = Vtiger_Edit_Js.getInstance();
			listInstance.registerRecordAccessCheckEvent(massEditForm);
			editInstance.registerBasicEvents(jQuery(container));
			listInstance.postMassEdit(container);
		});
	},

	triggerImportAction : function (importUrl) {
		var progressIndicatorElement = jQuery.progressIndicator();
		AppConnector.request(importUrl).then(
			function(data) {
				progressIndicatorElement.progressIndicator({'mode' : 'hide'});
				if(data) {
					app.showModalWindow(data, function(data){
						jQuery('#ical_import').validationEngine(app.validationEngineOptions);
					});
				}
			}
		);
	},

	triggerExportAction : function (importUrl) {
		var progressIndicatorElement = jQuery.progressIndicator();
		AppConnector.request(importUrl).then(
			function(data) {
				progressIndicatorElement.progressIndicator({'mode' : 'hide'});
				if(data) {
					app.showModalWindow(data, function(data){
					});
				}
			}
		);
	}

},{

    registerHoldFollowupOnEvent : function(){
        var thisInstance = this;
		var listViewContentDiv = this.getListViewContentContainer();
		listViewContentDiv.on('click','.holdFollowupOn',function(e){
			var elem = jQuery(e.currentTarget);
			var recordId = elem.closest('tr').data('id');

            var url = 'index.php?module=Calendar&view=QuickCreateFollowupAjax&record='+recordId;
            var progressIndicatorInstance = jQuery.progressIndicator({});
            AppConnector.request(url).then(
				function(data){
					if(data){
                        progressIndicatorInstance.hide();
                        app.showModalWindow(data, function(data){
                         var createFollowupForm = data.find('form.followupCreateView');
                         createFollowupForm.validationEngine(app.validationEngineOptions);
                         app.registerEventForTimeFields(createFollowupForm);
                         //Form submit
                         createFollowupForm.submit(function(event){
                             var createButton = jQuery(this).find('button.btn-success');
                             createButton.attr('disabled','disabled');
                             progressIndicatorInstance = jQuery.progressIndicator({});
                             event.preventDefault();
                             var result = createFollowupForm.validationEngine('validate');
                             if(!result){
                                 createButton.removeAttr('disabled');
                                 progressIndicatorInstance.hide();
                                 return false;
                             }
                             var moduleName = jQuery(this).find("[name='module']").val();
                             var recordId = jQuery(this).find("[name='record']").val();
                             var followupStartDate = jQuery(this).find("[name='followup_date_start']").val();
                             var followupStartTime = jQuery(this).find("[name='followup_time_start']").val();
                             var action = jQuery(this).find("[name='action']").val();
                             var mode = jQuery(this).find("[name='mode']").val();
                             var defaultCallDuration = jQuery(this).find("[name='defaultCallDuration']").val();
                             var defaultOtherEventDuration = jQuery(this).find("[name='defaultOtherEventDuration']").val();
                             var params = {
                                            module : moduleName,
                                            action : action,
                                            mode : mode,
                                            record : recordId,
                                            followup_date_start : followupStartDate,
                                            followup_time_start : followupStartTime,
                                            defaultOtherEventDuration : defaultOtherEventDuration,
                                            defaultCallDuration : defaultCallDuration
                                        }
                                        AppConnector.request(params).then(function(data){
                                            app.hideModalWindow();
                                            progressIndicatorInstance.hide();
                                            if(data['result'] && data['result'].created){
                                                //Update listview and pagination
                                                  var orderBy = jQuery('#orderBy').val();
                                                  var sortOrder = jQuery("#sortOrder").val();
                                                  var urlParams = {
                                                    "orderby": orderBy,
                                                    "sortorder": sortOrder
                                                }
                                                jQuery('#recordsCount').val('');
                                                jQuery('#totalPageCount').text('');
                                                thisInstance.getListViewRecords(urlParams).then(function(){
                                                    thisInstance.updatePagination();
                                                });
                                            }
                                        });
                         });
                    });
                    }
                    else{
                        progressIndicatorInstance.hide();
                        Vtiger_Helper_Js.showPnotify(app.vtranslate('JS_NO_EDIT_PERMISSION'));
                    }
				});
			e.stopPropagation();
		});
    },

    registerMarkAsHeldEvent : function(){
        var thisInstance = this;
		var listViewContentDiv = this.getListViewContentContainer();
		listViewContentDiv.on('click','.markAsHeld',function(e){
            var elem = jQuery(e.currentTarget);
			var recordId = elem.closest('tr').data('id');
            var message = app.vtranslate('JS_CONFIRM_MARK_AS_HELD');
            Vtiger_Helper_Js.showConfirmationBox({'message' : message}).then(
			function(e) {
                var params = {
                                module : "Calendar",
                                action : "SaveFollowupAjax",
                                mode : "markAsHeldCompleted",
                                record : recordId
                            }
                            AppConnector.request(params).then(function(data){
                                if(data['error']){
                                    var param = {text:app.vtranslate('JS_PERMISSION_DENIED')};
                                    Vtiger_Helper_Js.showPnotify(param);
                                }
                                else if(data['result'].valid && data['result'].markedascompleted){
                                    //Update listview and pagination
                                    var orderBy = jQuery('#orderBy').val();
                                    var sortOrder = jQuery("#sortOrder").val();
                                    var urlParams = {
                                        "orderby": orderBy,
                                        "sortorder": sortOrder
                                    }
                                    jQuery('#recordsCount').val('');
                                    jQuery('#totalPageCount').text('');
                                    thisInstance.getListViewRecords(urlParams).then(function(){
                                        thisInstance.updatePagination();
                                    });
                                    if(data['result'].activitytype == 'Task')
                                        var param = {text:app.vtranslate('JS_TODO_MARKED_AS_COMPLETED')};
                                    else
                                        var param = {text:app.vtranslate('JS_EVENT_MARKED_AS_HELD')};
                                    Vtiger_Helper_Js.showMessage(param);
                                }
                                else{
                                    var param = {text:app.vtranslate('JS_FUTURE_EVENT_CANNOT_BE_MARKED_AS_HELD')};
                                    Vtiger_Helper_Js.showPnotify(param);
                                }
                            });
            },
            function(error, err){
                return false;
			});
            e.stopPropagation();
        });
    },
    findKey : function (arr, keySearch) {
        var thisInstance = this;
        var ret = false;
        $.each(arr,function (index,elem) {
            if(elem === keySearch){
                ret = true;
                return false;
            }
            else{
                if ($.isArray(elem) && thisInstance.findKey(elem, keySearch)){
                    ret = true;
                    return false;
                }
                ret = false;
            }
        })
        return ret;
    },
    deleteKey: function (arr, keySearch) {
        var thisInstance = this;
        $.each(arr,function (index,elem) {
            if(elem === keySearch){
                arr = [];
            }
            else{
                if ($.isArray(elem)){
                    arr[index] = thisInstance.replaceKey(elem,keySearch);
                }
            }
        })
        return arr;
    },
    replaceKey: function (arr, data) {
        var thisInstance = this;
        $.each(arr,function (index,elem) {
            if(elem === data[0]){
                arr = data;
            }
            else{
                if ($.isArray(elem)){
                    arr[index] = thisInstance.replaceKey(elem,data)
                }
            }
        })
        return arr;
    },
    pullKey: function (arr,keySearch) {
        var thisInstance = this;
        var ret = [];
        $.each(arr[0],function (index,elem) {
            if(elem[0] === keySearch){
                ret = elem;
                return false;
            }
        })
        return ret;
    },
    deleteSearchParams: function (arr, keySearch) {
        var thisInstance = this;
        if(thisInstance.findKey(arr,keySearch)){
            arr = thisInstance.deleteKey(arr,keySearch);
        }
        return arr;
    },
    insertSearchParams: function (arr, data) {
        var thisInstance = this;
        if(thisInstance.findKey(arr,data[0])){
            arr = thisInstance.replaceKey(arr,data);
        }
        else{
            arr[0].push(data);
        }
        return arr;
    },
    insertUserName: function (arr,username) {
        var thisInstance = this;
        var currentUserList = thisInstance.pullKey(arr,'assigned_user_id');
        if(currentUserList.length != 0){
            var currentUserArray = currentUserList[2].split(',');
            var temp = $.inArray(username,currentUserArray);
            if(temp != -1){
                return arr;
            }
            else{
                currentUserArray.push(username);
                var prm = ['assigned_user_id','e',currentUserArray.join()];
                return thisInstance.insertSearchParams(arr,prm);
            }
        }
        else{
            var prm = ['assigned_user_id','e',username.toString()];
            return thisInstance.insertSearchParams(arr,prm);
        }
    },
    deleteUserName: function (arr,username) {
        var thisInstance = this;
        var currentUserList = thisInstance.pullKey(arr,'assigned_user_id');
        if(currentUserList.length != 0){
            var currentUserArray = currentUserList[2].split(',');
            var temp = $.inArray(username,currentUserArray);
            if(temp != -1){
                currentUserArray.splice(temp,1);
                if(currentUserArray.length == 0){
                    return thisInstance.deleteSearchParams(arr,'assigned_user_id');
                }
                else{
                    var prm = ['assigned_user_id','e',currentUserArray.join()];
                    return thisInstance.insertSearchParams(arr,prm);
                }
            }
            else{
                return arr;
            }
        }
        else{
            return arr;
        }
    },
      parseDate: function(baseDate){
	var dateTime = baseDate.split(' ');
	var time = dateTime[1];
	var date = dateTime[0].split('-');
	var newDate = new Date();
	newDate.setFullYear(date[0]);
	newDate.setMonth(date[1]);	
	newDate.setDate(date[2]);

	//newDate.setTime(time);
	
	//var newDate = baseDate.replace('-','/');
	return newDate;
      },
    registerViewRangeChange :function(){
        var thisInstance = this;
        //var startDate = this.parseDate(jQuery('#startDate').val());
        var stdt = this.parseDate(jQuery('#startDate').val());
        var eddt = this.parseDate(jQuery('#startDate').val());
        var range = parseInt(jQuery('#range').val());
        eddt.setDate(eddt.getDate()+range-1);
        if(range == 1){
            jQuery('#rangeWeek').css('background','#F3F3F3');
            jQuery('#rangeDay').css('background','#b3b3b3');
        }
        else if(range == 7){
            jQuery('#rangeWeek').css('background','#b3b3b3');
            jQuery('#rangeDay').css('background','#F3F3F3');
        }
        else{
            jQuery('#rangeWeek').css('background','#F3F3F3');
            jQuery('#rangeDay').css('background','#F3F3F3');
        }
        //var usersList = jQuery('[id=userList]');
        var usersList = $('[id^="userList"]').map(function () { return $(this).val(); }).get();
        var usersCheckList = jQuery('[id="userCheckList"]');
        $.each(usersCheckList,function () {
            var username = $(this).attr('data-calendar-username');
            if($.inArray(username,usersList) != -1){
                $(this).prop("checked", true);
            }else{
                $(this).prop("checked", false);
            }
        })
        // style
        var bgStyle = 'display: none;' +
            'width: 100%;' +
            'height: 2000px;' +
            'position: fixed;' +
            'top: 0;' +
            'left: 0;' +
            'z-index: 9999;' +
            'background: #333;';

        var wrapStyle = 'display: none;' +
            'width: 90%;' +
            'height:' + ($(window).height() * 0.5) + 'px;' +
            'margin: 0 0 0 0px;' +
            'position: fixed;' +
            'top: 40px;' +
            'left: 5%;' +
            'z-index: 9999;' +
            'background: #fff;';

        var btnStyle = 'display: none;' +
            'width: 40px;' +
            'height: 40px;' +
            'position: fixed;' +
            'top: 20px;' +
            'right: 20px;' +
            'z-index: 9999;' +
            'background: #999;' +
            'border-radius: 50%;' +
            'cursor: pointer;' +
            'line-height: 40px;' +
            'text-align: center;' +
            'color: #fff';

        var html = '<div id="iframe-bg" style="' + bgStyle + '"></div>' +
            '<div id="iframe-wrap" style="' + wrapStyle + '"></div>' +
            '<div id="iframe-btn" style="' + btnStyle + '">X</div>';

        // add element
        $(html).appendTo('body');
        //jQuery('.quickWidget').hide();
        jQuery('#goToToday').on({
            'click': function(){
                stdt = new Date();
                eddt = new Date();
                eddt.setDate(eddt.getDate()+range-1);
                jQuery('#baseDate').text(stdt.getFullYear() + '-' + ("0"+(stdt.getMonth()+1)).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2));
                var paramsArray = [];
                var url = location.href;
                parameters = url.split("#");
                if( parameters.length > 1 ) {
                    url = parameters[0];
                }
                parameters = url.split("?");
                if( parameters.length > 1 ) {
                    var params   = parameters[1].split("&");
                    for ( i = 0; i < params.length; i++ ) {
                        var paramItem = params[i].split("=");
                        paramsArray[paramItem[0]] = paramItem[1];
                    }
                }
                var params = paramsArray ;
                if(params['search_params']){
                    var prevSearchParams =  JSON.parse(decodeURIComponent(params['search_params']));
                }
                else{
                    var prevSearchParams = [[]];
                }
                var prm = ['due_date','bw',stdt.getFullYear() + '-' + ("0"+(stdt.getMonth()+1)).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2)+' 00:00,'+eddt.getFullYear() + '-' + ("0"+(eddt.getMonth()+1)).slice(-2) + '-' + ("0"+eddt.getDate() ).slice(-2)+' 23:59'];
                var currentSearchParams = thisInstance.insertSearchParams(prevSearchParams,prm);
                params['search_params'] = encodeURIComponent(JSON.stringify(currentSearchParams));
                //params['search_params'] = encodeURIComponent( '[[[\"due_date\"\,\"bw\"\,\"'+stdt.getFullYear() + '-' + ("0"+(stdt.getMonth()+1)).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2)+','+eddt.getFullYear() + '-' + ("0"+(eddt.getMonth()+1)).slice(-2) + '-' + ("0"+eddt.getDate() ).slice(-2)+'\"]]]' );
                params['range'] = range;
                params['page'] = 1;
                var resurl = location.href.replace(/\?.*$/,"");
                for ( key in paramsArray ) {
                    resurl += (resurl.indexOf('?') == -1) ? '?':'&';
                    resurl += key + '=' + paramsArray[key];
                }
                window.location.href = resurl;
            },
            'mousedown': function(){
                jQuery('#goToToday').css('background','#777');
            },
            'mouseover': function(){
                jQuery('#goToToday').css('background','#777');
            },
            'mouseup': function(){
                jQuery('#goToToday').css('background','#F3F3F3');
            },
            'mouseout': function(){
                jQuery('#goToToday').css('background','#F3F3F3');
            },
            'touchstart':function(){
                jQuery('#goToToday').css('background','#777');
            },
            'touchmove':function(){
                jQuery('#goToToday').css('background','#777');
            },
            'touchend':function(){
                jQuery('#goToToday').css('background','#F3F3F3');
            }
        });
        jQuery('#goToNext').on({
            'click': function(){
                stdt.setDate(stdt.getDate()+range);
                eddt.setDate(eddt.getDate()+range);
                jQuery('#baseDate').text(stdt.getFullYear() + '-' + ("0"+(stdt.getMonth())).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2));
                var paramsArray = [];
                var url = location.href;
                parameters = url.split("#");
                if( parameters.length > 1 ) {
                    url = parameters[0];
                }
                parameters = url.split("?");
                if( parameters.length > 1 ) {
                    var params   = parameters[1].split("&");
                    for ( i = 0; i < params.length; i++ ) {
                        var paramItem = params[i].split("=");
                        paramsArray[paramItem[0]] = paramItem[1];
                    }
                }
                var params = paramsArray ;
                if(params['search_params']){
                    var prevSearchParams =  JSON.parse(decodeURIComponent(params['search_params']));
                }
                else{
                    var prevSearchParams = [[]];
                }
                var prm = ['due_date','bw',stdt.getFullYear() + '-' + ("0"+(stdt.getMonth())).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2)+' 00:00,'+eddt.getFullYear() + '-' + ("0"+(eddt.getMonth())).slice(-2) + '-' + ("0"+eddt.getDate() ).slice(-2)+' 23:59'];
                var currentSearchParams = thisInstance.insertSearchParams(prevSearchParams,prm);
                params['search_params'] = encodeURIComponent(JSON.stringify(currentSearchParams));
                //params['search_params'] = encodeURIComponent( '[[[\"due_date\"\,\"bw\"\,\"'+stdt.getFullYear() + '-' + ("0"+(stdt.getMonth())).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2)+','+eddt.getFullYear() + '-' + ("0"+(eddt.getMonth())).slice(-2) + '-' + ("0"+eddt.getDate() ).slice(-2)+'\"]]]' );
                params['range'] = range;
                params['page'] = 1;
                var resurl = location.href.replace(/\?.*$/,"");
                for ( key in paramsArray ) {
                    resurl += (resurl.indexOf('?') == -1) ? '?':'&';
                    resurl += key + '=' + paramsArray[key];
                }
                window.location.href = resurl;
            },
            'mousedown': function(){
                jQuery('#goToNext').css('background','#777');
            },
            'mouseover': function(){
                jQuery('#goToNext').css('background','#777');
            },
            'mouseup': function(){
                jQuery('#goToNext').css('background','#F3F3F3');
            },
            'mouseout': function(){
                jQuery('#goToNext').css('background','#F3F3F3');
            },
            'touchstart':function(){
                jQuery('#goToNext').css('background','#777');
            },
            'touchmove':function(){
                jQuery('#goToNext').css('background','#777');
            },
            'touchend':function(){
                jQuery('#goToNext').css('background','#F3F3F3');
            }
        });
        jQuery('#goToPrev').on({
            'click': function(){
                stdt.setDate(stdt.getDate()-range);
                eddt.setDate(eddt.getDate()-range);
                jQuery('#baseDate').text(stdt.getFullYear() + '-' + ("0"+(stdt.getMonth())).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2));
                var paramsArray = [];
                var url = location.href;
                parameters = url.split("#");
                if( parameters.length > 1 ) {
                    url = parameters[0];
                }
                parameters = url.split("?");
                if( parameters.length > 1 ) {
                    var params   = parameters[1].split("&");
                    for ( i = 0; i < params.length; i++ ) {
                        var paramItem = params[i].split("=");
                        paramsArray[paramItem[0]] = paramItem[1];
                    }
                }
                var params = paramsArray ;
                if(params['search_params']){
                    var prevSearchParams =  JSON.parse(decodeURIComponent(params['search_params']));
                }
                else{
                    var prevSearchParams = [[]];
                }
                var prm = ['due_date','bw',stdt.getFullYear() + '-' + ("0"+(stdt.getMonth())).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2)+' 00:00,'+eddt.getFullYear() + '-' + ("0"+(eddt.getMonth())).slice(-2) + '-' + ("0"+eddt.getDate() ).slice(-2)+' 23:59'];
                var currentSearchParams = thisInstance.insertSearchParams(prevSearchParams,prm);
                params['search_params'] = encodeURIComponent(JSON.stringify(currentSearchParams));
                //params['search_params'] = encodeURIComponent( '[[[\"due_date\"\,\"bw\"\,\"'+stdt.getFullYear() + '-' + ("0"+(stdt.getMonth())).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2)+','+eddt.getFullYear() + '-' + ("0"+(eddt.getMonth())).slice(-2) + '-' + ("0"+eddt.getDate() ).slice(-2)+'\"]]]' );
                params['range'] = range;
                params['page'] = 1;
                var resurl = location.href.replace(/\?.*$/,"");
                for ( key in paramsArray ) {
                    resurl += (resurl.indexOf('?') == -1) ? '?':'&';
                    resurl += key + '=' + paramsArray[key];
                }
                window.location.href = resurl;

            },
            'mousedown': function(){
            jQuery('#goToPrev').css('background','#777');
            },
            'mouseover': function(){
                jQuery('#goToPrev').css('background','#777');
            },
            'mouseup': function(){
                jQuery('#goToPrev').css('background','#F3F3F3');
            },
            'mouseout': function(){
                jQuery('#goToPrev').css('background','#F3F3F3');
            },
            'touchstart':function(){
                jQuery('#goToPrev').css('background','#777');
            },
            'touchmove':function(){
                jQuery('#goToPrev').css('background','#777');
            },
            'touchend':function(){
                jQuery('#goToPrev').css('background','#F3F3F3');
            }
        });
        jQuery('#rangeDay').on({
            'click':function(){
                range = 1;
                eddt.setDate(stdt.getDate()+range-1);
                var paramsArray = [];
                var url = location.href;
                parameters = url.split("#");
                if( parameters.length > 1 ) {
                    url = parameters[0];
                }
                parameters = url.split("?");
                if( parameters.length > 1 ) {
                    var params   = parameters[1].split("&");
                    for ( i = 0; i < params.length; i++ ) {
                        var paramItem = params[i].split("=");
                        paramsArray[paramItem[0]] = paramItem[1];
                    }
                }
                var params = paramsArray ;
                if(params['search_params']){
                    var prevSearchParams =  JSON.parse(decodeURIComponent(params['search_params']));
                }
                else{
                    var prevSearchParams = [[]];
                }
                var prm = ['due_date','bw',stdt.getFullYear() + '-' + ("0"+(stdt.getMonth())).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2)+' 00:00,'+eddt.getFullYear() + '-' + ("0"+(eddt.getMonth())).slice(-2) + '-' + ("0"+eddt.getDate() ).slice(-2)+' 23:59'];
                var currentSearchParams = thisInstance.insertSearchParams(prevSearchParams,prm);
                params['search_params'] = encodeURIComponent(JSON.stringify(currentSearchParams));
                //params['search_params'] = encodeURIComponent( '[[[\"due_date\"\,\"bw\"\,\"'+stdt.getFullYear() + '-' + ("0"+(stdt.getMonth())).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2)+','+eddt.getFullYear() + '-' + ("0"+(eddt.getMonth())).slice(-2) + '-' + ("0"+eddt.getDate() ).slice(-2)+'\"]]]' );
                params['range'] = range;
                params['page'] = 1;
                var resurl = location.href.replace(/\?.*$/,"");
                for ( key in paramsArray ) {
                    resurl += (resurl.indexOf('?') == -1) ? '?':'&';
                    resurl += key + '=' + paramsArray[key];
                }
                window.location.href = resurl;
            },
            'mousedown': function(){
                if(range == 1){
                    jQuery('#rangeDay').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeDay').css('background','#777');
                }
            },
            'mouseover': function(){
                if(range == 1){
                    jQuery('#rangeDay').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeDay').css('background','#777');
                }
            },
            'mouseup': function(){
                if(range == 1){
                    jQuery('#rangeDay').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeDay').css('background','#F3F3F3');
                }
            },
            'mouseout': function(){
                if(range == 1){
                    jQuery('#rangeDay').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeDay').css('background','#F3F3F3');
                }
            },
            'touchstart': function(){
                if(range == 1){
                    jQuery('#rangeDay').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeDay').css('background','#777');
                }
            },
            'touchmove': function(){
                if(range == 1){
                    jQuery('#rangeDay').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeDay').css('background','#777');
                }
            },
            'touchend': function(){
                if(range == 1){
                    jQuery('#rangeDay').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeDay').css('background','#F3F3F3');
                }
            }
        });
        jQuery('#userListModal').on({
            'click':function(){
                var url = $(this).attr('href');

                $('#iframe-wrap').html("<iframe src='" + url + "' width='100%' height='100%'>");
                $('#iframe-bg').fadeTo('normal', 0.8);

                $('#iframe-wrap iframe').load(function () {

                    $('#iframe-wrap').fadeIn();
                    $('#iframe-btn').fadeIn();
                    $('#iframe-wrap iframe').contents().find('#setUserList').val(usersList);
                    var popupUsersList = usersList.toString().split(',');
                    var popupUsersCheckList = $('#iframe-wrap iframe').contents().find('[id="popupUserSelect"]');
                    $.each(popupUsersCheckList,function () {
                        var popupUsername = $(this).attr('data-calendar-username');
                        if ($.inArray(popupUsername, popupUsersList) != -1) {
                            $(this).prop("checked", true);
                        }
                        else {
                            $(this).prop("checked", false);
                        }
                    })
                });

                return false;
            }
        });
        $('#iframe-btn').click(function () {
            var usersListArray = $('#iframe-wrap iframe').contents().find('#setUserList').val().split(',');
            usersListArray = $.grep(usersListArray, function(e){return e !== "";});
            // var usersCheckList = jQuery('[id="userCheckList"]');
            // $.each(usersCheckList,function () {
            //     var username = $(this).attr('data-calendar-username');
            //     if($.inArray(username,usersListModal) != -1){
            //         $(this).prop("checked", true).trigger('change');
            //     }
            //     else{
            //         $(this).prop("checked", false).trigger('change');
            //     }
            // })
            var paramsArray = [];
            var url = location.href;
            parameters = url.split("#");
            if( parameters.length > 1 ) {
                url = parameters[0];
            }
            parameters = url.split("?");
            if( parameters.length > 1 ) {
                var params   = parameters[1].split("&");
                for ( i = 0; i < params.length; i++ ) {
                    var paramItem = params[i].split("=");
                    paramsArray[paramItem[0]] = paramItem[1];
                }
            }
            var params = paramsArray ;
            if(params['search_params']){
                var prevSearchParams =  JSON.parse(decodeURIComponent(params['search_params']));
            }
            else{
                var prevSearchParams = [[]];
            }
            var prm = ['assigned_user_id','e',usersListArray.join()];
            var currentSearchParams = thisInstance.insertSearchParams(prevSearchParams,prm);
            params['search_params'] = encodeURIComponent(JSON.stringify(currentSearchParams));
            var resurl = location.href.replace(/\?.*$/,"");
            for ( key in paramsArray ) {
                resurl += (resurl.indexOf('?') == -1) ? '?':'&';
                resurl += key + '=' + paramsArray[key];
            }
            window.location.href = resurl;

            $('#iframe-bg, #iframe-btn, #iframe-wrap').fadeOut();


        });
        $('#sendUser').click(function () {
            $('#iframe-bg, #iframe-btn, #iframe-wrap').fadeOut();
        });
        jQuery('#rangeWeek').on({
            'click':function(){
                range = 7;
                eddt.setDate(stdt.getDate()+range-1);
                var paramsArray = [];
                var url = location.href;
                parameters = url.split("#");
                if( parameters.length > 1 ) {
                    url = parameters[0];
                }
                parameters = url.split("?");
                if( parameters.length > 1 ) {
                    var params   = parameters[1].split("&");
                    for ( i = 0; i < params.length; i++ ) {
                        var paramItem = params[i].split("=");
                        paramsArray[paramItem[0]] = paramItem[1];
                    }
                }
                var params = paramsArray ;
                if(params['search_params']){
                    var prevSearchParams =  JSON.parse(decodeURIComponent(params['search_params']));
                }
                else{
                    var prevSearchParams = [[]];
                }
                //var prevSearchParams =  JSON.parse(decodeURIComponent(params['search_params']));
                var prm = ['due_date','bw',stdt.getFullYear() + '-' + ("0"+(stdt.getMonth())).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2)+' 00:00,'+eddt.getFullYear() + '-' +("0"+(eddt.getMonth())).slice(-2) + '-' + ("0"+eddt.getDate() ).slice(-2)+' 23:59'];
                var currentSearchParams = thisInstance.insertSearchParams(prevSearchParams,prm);
                params['search_params'] = encodeURIComponent(JSON.stringify(currentSearchParams));
                //params['search_params'] = encodeURIComponent( '[[[\"due_date\"\,\"bw\"\,\"'+stdt.getFullYear() + '-' + ("0"+(stdt.getMonth())).slice(-2) + '-' + ("0"+stdt.getDate() ).slice(-2)+','+eddt.getFullYear() + '-' +("0"+(eddt.getMonth())).slice(-2) + '-' + ("0"+eddt.getDate() ).slice(-2)+'\"]]]' );
                params['range'] = range;
                params['page'] = 1;
                var resurl = location.href.replace(/\?.*$/,"");
                for ( key in paramsArray ) {
                    resurl += (resurl.indexOf('?') == -1) ? '?':'&';
                    resurl += key + '=' + paramsArray[key];
                }
                window.location.href = resurl;
            },
            'mousedown': function(){
                if(range == 7){
                    jQuery('#rangeWeek').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeWeek').css('background','#777');
                }
            },
            'mouseover': function(){
                if(range == 7){
                    jQuery('#rangeWeek').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeWeek').css('background','#777');
                }
            },
            'mouseup': function(){
                if(range == 7){
                    jQuery('#rangeWeek').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeWeek').css('background','#F3F3F3');
                }
            },
            'mouseout': function(){
                if(range == 7){
                    jQuery('#rangeWeek').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeWeek').css('background','#F3F3F3');
                }
            },
            'touchstart': function(){
                if(range == 7){
                    jQuery('#rangeWeek').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeWeek').css('background','#777');
                }
            },
            'touchmove': function(){
                if(range == 7){
                    jQuery('#rangeWeek').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeWeek').css('background','#777');
                }
            },
            'touchend': function(){
                if(range == 7){
                    jQuery('#rangeWeek').css('background','#b3b3b3');
                }
                else{
                    jQuery('#rangeWeek').css('background','#F3F3F3');
                }
            }
        });

    },
    registerPageNavigationEvents : function(){
        var thisInstance = this;
        jQuery('#listViewNextPageButton').on('click',function(){
            var pageLimit = jQuery('#pageLimit').val();
            var noOfEntries = jQuery('#noOfEntries').val();
            if(noOfEntries == pageLimit){
                var paramsArray = [];
                var url = location.href;
                parameters = url.split("#");
                if( parameters.length > 1 ) {
                    url = parameters[0];
                }
                parameters = url.split("?");
                if( parameters.length > 1 ) {
                    var params   = parameters[1].split("&");
                    for ( i = 0; i < params.length; i++ ) {
                        var paramItem = params[i].split("=");
                        paramsArray[paramItem[0]] = paramItem[1];
                    }
                }
                var params = paramsArray ;
                var pageNumber = jQuery('#pageNumber').val();
                var nextPageNumber = parseInt(parseFloat(pageNumber)) + 1;
                params['page'] = nextPageNumber;
                var resurl = location.href.replace(/\?.*$/,"");
                for ( key in paramsArray ) {
                    resurl += (resurl.indexOf('?') == -1) ? '?':'&';
                    resurl += key + '=' + paramsArray[key];
                }
                window.location.href = resurl;
            }
        });
        jQuery('#listViewPreviousPageButton').on('click',function(){
            var pageNumber = jQuery('#pageNumber').val();
            if(pageNumber > 1){
                var paramsArray = [];
                var url = location.href;
                parameters = url.split("#");
                if( parameters.length > 1 ) {
                    url = parameters[0];
                }
                parameters = url.split("?");
                if( parameters.length > 1 ) {
                    var params   = parameters[1].split("&");
                    for ( i = 0; i < params.length; i++ ) {
                        var paramItem = params[i].split("=");
                        paramsArray[paramItem[0]] = paramItem[1];
                    }
                }
                var params = paramsArray ;
                params['page'] = parseInt(parseFloat(pageNumber)) - 1;
                var resurl = location.href.replace(/\?.*$/,"");
                for ( key in paramsArray ) {
                    resurl += (resurl.indexOf('?') == -1) ? '?':'&';
                    resurl += key + '=' + paramsArray[key];
                }
                window.location.href = resurl;
            }
        });

        jQuery('#listViewPageJump').on('click',function(e){
            if(typeof Vtiger_WholeNumberGreaterThanZero_Validator_Js.invokeValidation(jQuery('#pageToJump'))!= 'undefined') {
                var pageNo = jQuery('#pageNumber').val();
                jQuery("#pageToJump").val(pageNo);
            }
            jQuery('#pageToJump').validationEngine('hideAll');
            var element = jQuery('#totalPageCount');
            var totalPageNumber = element.text();
            if(totalPageNumber == ""){
                var totalCountElem = jQuery('#totalCount');
                var totalRecordCount = totalCountElem.val();
                if(totalRecordCount != '') {
                    var recordPerPage = jQuery('#pageLimit').val();
                    if(recordPerPage == '0') recordPerPage = 1;
                    pageCount = Math.ceil(totalRecordCount/recordPerPage);
                    if(pageCount == 0){
                        pageCount = 1;
                    }
                    element.text(pageCount);
                    return;
                }
                element.progressIndicator({});
                thisInstance.getPageCount().then(function(data){
                    var pageCount = data['result']['page'];
                    totalCountElem.val(data['result']['numberOfRecords']);
                    if(pageCount == 0){
                        pageCount = 1;
                    }
                    element.text(pageCount);
                    element.progressIndicator({'mode': 'hide'});
                });
            }
        });

        jQuery('#listViewPageJumpDropDown').on('click','li',function(e){
            e.stopImmediatePropagation();
        }).on('keypress','#pageToJump',function(e){
            if(e.which == 13){
                e.stopImmediatePropagation();
                var element = jQuery(e.currentTarget);
                var response = Vtiger_WholeNumberGreaterThanZero_Validator_Js.invokeValidation(element);
                if(typeof response != "undefined"){
                    element.validationEngine('showPrompt',response,'',"topLeft",true);
                } else {
                    element.validationEngine('hideAll');
                    var currentPageElement = jQuery('#pageNumber');
                    var currentPageNumber = currentPageElement.val();
                    var newPageNumber = parseInt(jQuery(e.currentTarget).val());
                    var totalPages = parseInt(jQuery('#totalPageCount').text());
                    if(newPageNumber > totalPages){
                        var error = app.vtranslate('JS_PAGE_NOT_EXIST');
                        element.validationEngine('showPrompt',error,'',"topLeft",true);
                        return;
                    }
                    if(newPageNumber == currentPageNumber){
                        var message = app.vtranslate('JS_YOU_ARE_IN_PAGE_NUMBER')+" "+newPageNumber;
                        var params = {
                            text: message,
                            type: 'info'
                        };
                        Vtiger_Helper_Js.showMessage(params);
                        return;
                    }
                    currentPageElement.val(newPageNumber);
                    thisInstance.getListViewRecords().then(
                        function(data){
                            thisInstance.updatePagination();
                            element.closest('.btn-group ').removeClass('open');
                        },
                        function(textStatus, errorThrown){
                        }
                    );
                }
                return false;
            }
        });
        jQuery('#calendarview-feeds').on('change', '[data-calendar-feed]', function (e) {
			var currentTarget = $(e.currentTarget);
			var type = currentTarget.data('calendar-sourcekey');
			var username = currentTarget.data('calendar-username');
			if (currentTarget.is(':checked')) {
				var paramsArray = [];
				var url = location.href;
				parameters = url.split("#");
				if( parameters.length > 1 ) {
					url = parameters[0];
				}
				parameters = url.split("?");
				if( parameters.length > 1 ) {
					var params   = parameters[1].split("&");
					for ( i = 0; i < params.length; i++ ) {
						var paramItem = params[i].split("=");
						paramsArray[paramItem[0]] = paramItem[1];
					}
				}
				var params = paramsArray ;
				// params['search_params'] = encodeURIComponent( '[[[\"assigned_user_id\"\,\"c\"\,\"'+username+'\"]]]' );
                if(params['search_params']){
                    var prevSearchParams =  JSON.parse(decodeURIComponent(params['search_params']));
                }
                else{
                    var prevSearchParams = [[]];
                }
                var currentSearchParams = prevSearchParams;
                var usersCheckedList = jQuery('[id="userCheckList"]:checked');
                $.each(usersCheckedList,function () {
                    var username = $(this).attr('data-calendar-username');
                    currentSearchParams = thisInstance.insertUserName(currentSearchParams,username);
                })
                //var currentSearchParams = thisInstance.insertUserName(prevSearchParams,username);
                //var prm = ['assigned_user_id','c',username.toString()];
                //var currentSearchParams = thisInstance.insertSearchParams(prevSearchParams,prm);
                params['search_params'] = encodeURIComponent(JSON.stringify(currentSearchParams));
				var resurl = location.href.replace(/\?.*$/,"");
				for ( key in paramsArray ) {
					resurl += (resurl.indexOf('?') == -1) ? '?':'&';
					resurl += key + '=' + paramsArray[key];
				}
				window.location.href = resurl;

			} else {

                var paramsArray = [];
                var url = location.href;
                parameters = url.split("#");
                if( parameters.length > 1 ) {
                    url = parameters[0];
                }
                parameters = url.split("?");
                if( parameters.length > 1 ) {
                    var params   = parameters[1].split("&");
                    for ( i = 0; i < params.length; i++ ) {
                        var paramItem = params[i].split("=");
                        paramsArray[paramItem[0]] = paramItem[1];
                    }
                }
                var params = paramsArray ;
                // params['search_params'] = encodeURIComponent( '[[[\"assigned_user_id\"\,\"c\"\,\"'+username+'\"]]]' );
                if(params['search_params']){
                    var prevSearchParams =  JSON.parse(decodeURIComponent(params['search_params']));
                }
                else{
                    var prevSearchParams = [[]];
                }
                var currentSearchParams = thisInstance.deleteUserName(prevSearchParams,username);
                //var prm = ['assigned_user_id','c',username.toString()];
                //var currentSearchParams = thisInstance.insertSearchParams(prevSearchParams,prm);
                params['search_params'] = encodeURIComponent(JSON.stringify(currentSearchParams));
                var resurl = location.href.replace(/\?.*$/,"");
                for ( key in paramsArray ) {
                    resurl += (resurl.indexOf('?') == -1) ? '?':'&';
                    resurl += key + '=' + paramsArray[key];
                }
                window.location.href = resurl;
			}
		});
    },

    registerEvents : function(){
        this._super();
        this.registerHoldFollowupOnEvent();
        this.registerMarkAsHeldEvent();
        this.registerViewRangeChange();
        this.registerPageNavigationEvents();
    }

});
