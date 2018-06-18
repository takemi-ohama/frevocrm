/*+***********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 *************************************************************************************/

Vtiger_Detail_Js("Calendar_PopupDetail_Js",{},{

	calendarView : false,

	calendarfeedDS : {},

	getCalendarView : function() {
		if(this.calendarView == false) {
			this.calendarView = parent.$('#calendarview');
		}
		return this.calendarView;
	},
	
	toDateString : function(date) {
		var d = date.getDate();
		var m = date.getMonth() +1;
		var y = date.getFullYear();
		
		d = (d <= 9)? ("0"+d) : d;
		m = (m <= 9)? ("0"+m) : m;
		return y + "-" + m + "-" + d;
	},
	
	fetchCalendarFeed : function(feedcheckbox, lastevent) {
		var thisInstance = this;

		var type = feedcheckbox.data('calendar-sourcekey');
		thisInstance.calendarfeedDS[type] = function(start, end, callback) {
			if(feedcheckbox.not(':checked').length > 0) {
				callback([]);
				return;
			}
			feedcheckbox.attr('disabled', true);
			var params = {
				module: 'Calendar',
				action: 'Feed',
				start: thisInstance.toDateString(start),
				end: thisInstance.toDateString(end),
				type: feedcheckbox.data('calendar-feed'),
				fieldname: feedcheckbox.data('calendar-fieldname'),
				userid : feedcheckbox.data('calendar-userid'),
				color : feedcheckbox.data('calendar-feed-color'),
				textColor : feedcheckbox.data('calendar-feed-textcolor')
			}
			var customData = feedcheckbox.data('customData');
			if( customData != undefined) {
				params = jQuery.extend(params, customData);
			}

			AppConnector.request(params).then(function(events){
				callback(events);
				feedcheckbox.attr('disabled', false).attr('checked', true);
				if(lastevent) window.parent.jQuery('.externalSite').dialog('close');
			},
            function(error){
                //To send empty events if error occurs
                callback([]);
            });
		}

		thisInstance.getCalendarView().fullCalendar('addEventSource', thisInstance.calendarfeedDS[type]);
	},

	fetchAllCalendarFeeds : function(calendarfeedidx) {
		var thisInstance = this;
		var calendarfeeds = jQuery('[data-calendar-feed]', parent.document);
		var lastevent = false;

		//TODO : see if you get all the feeds in one request

		thisInstance.getCalendarView().fullCalendar('removeEvents');
		calendarfeeds.each(function(index,element){
			var feedcheckbox = jQuery(element, parent.document);
			var disabledOnes = app.cacheGet('calendar.feeds.disabled',[]);
			if (disabledOnes.indexOf(feedcheckbox.data('calendar-sourcekey')) == -1) {
				feedcheckbox.attr('checked',true);
			}
			if(index == calendarfeeds.length -1) lastevent = true;
			thisInstance.fetchCalendarFeed(feedcheckbox, lastevent);
		});
		
	},
	
	allocateColorsForAllUsers : function() {
		var calendarfeeds = jQuery('[data-calendar-feed]', parent.document);
		calendarfeeds.each(function(index,element){
			var feedUserElement = jQuery(element);
			var feedUserLabel = feedUserElement.closest('.addedCalendars').find('.label');
			var sourcekey = feedUserElement.data('calendar-sourcekey');
			var color = feedUserElement.data('calendar-feed-color');
			if(color == '' || typeof color == 'undefined') {
				color = app.cacheGet(sourcekey);
				if(color != null){
				} else {
					color = '#'+(0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6);
					app.cacheSet(sourcekey, color);
				}
				feedUserElement.data('calendar-feed-color',color);
				feedUserLabel.css({'background-color':color});
			}
			var colorContrast = app.getColorContrast(color.slice(1));
			if(colorContrast == 'light') {
				var textColor = 'black'
			} else {
				textColor = 'white'
			}
			feedUserElement.data('calendar-feed-textcolor',textColor);
			feedUserLabel.css({'color':textColor});
		});

	},
	
	getAllUserColors : function() {
		var result = {};
		var calendarfeeds = jQuery('[data-calendar-feed]', parent.document);
		
		calendarfeeds.each(function(index,element){
			var feedcheckbox = jQuery(element);
			var disabledOnes = app.cacheGet('calendar.feeds.disabled',[]); 
			if (disabledOnes.indexOf(feedcheckbox.data('calendar-sourcekey')) == -1) { 
				feedcheckbox.attr('checked',true); 
				var id = feedcheckbox.data('calendar-userid'); 
				result[id] = feedcheckbox.data('calendar-feed-color')+','+feedcheckbox.data('calendar-feed-textcolor'); 
			}
		});
		
		return result;
	},
	
	fetchAllShareEvents : function() {
		var thisInstance = this;
		var result = this.getAllUserColors();
		var params = {
			module: 'Calendar',
			action: 'Feed',
			start: thisInstance.toDateString(thisInstance.getCalendarView().fullCalendar('getView').visStart),
			end: thisInstance.toDateString(thisInstance.getCalendarView().fullCalendar('getView').visEnd),
			type: 'MultipleEvents',
			mapping : result
		}

		AppConnector.request(params).then(function(multipleEvents){
				thisInstance.multipleEvents = multipleEvents;
				thisInstance.fetchAllShareCalendarFeeds();
		},
		function(error){
			
		});
		
		
	},
	
	fetchAllShareCalendarFeeds : function() {
		var thisInstance = this;
		var calendarfeeds = jQuery('[data-calendar-feed]', parent.document);
		var lastevent = false;
		
		thisInstance.getCalendarView().fullCalendar('removeEvents');
		calendarfeeds.each(function(index,element){
			var feedcheckbox = jQuery(element);
			if(index == calendarfeeds.length -1) lastevent = true;
			thisInstance.fetchShareCalendarFeed(feedcheckbox, lastevent);
		});
		
		this.multipleEvents = false;
	},
	
	fetchShareCalendarFeed : function(feedcheckbox, lastevent) {
		var thisInstance = this;
		
		//var type = feedcheckbox.data('calendar-sourcekey');
		this.calendarfeedDS[feedcheckbox.data('calendar-sourcekey')] = function(start, end, callback) {
			if(typeof thisInstance.multipleEvents != 'undefined' && thisInstance.multipleEvents != false){
				var events = thisInstance.multipleEvents[feedcheckbox.data('calendar-userid')];
				if(events !== false) {
					callback(events);
					return;
				}
			}
			
			if(feedcheckbox.not(':checked').length > 0) {
				callback([]);
				return;
			}
			feedcheckbox.attr('disabled', true);
			
			var params = {
				module: 'Calendar',
				action: 'Feed',
				start: thisInstance.toDateString(start),
				end: thisInstance.toDateString(end),
				type: feedcheckbox.data('calendar-feed'),
				userid : feedcheckbox.data('calendar-userid'),
				color : feedcheckbox.data('calendar-feed-color'),
				textColor : feedcheckbox.data('calendar-feed-textcolor')
			}

			AppConnector.request(params).then(function(events){
				callback(events);
				feedcheckbox.attr('disabled', false).attr('checked', true);
			},
            function(error){
                //To send empty events if error occurs
                callback([]);
            });
		}
		this.getCalendarView().fullCalendar('addEventSource', this.calendarfeedDS[feedcheckbox.data('calendar-sourcekey')]);
		if(lastevent) window.parent.jQuery('.externalSite').dialog('close');
		
	},
	
	/**
	 * Function which will register all the events
	 */
    registerEvents : function() {
    	var parentUrl = parent.document.location.href;
    	
		this._super();
		if(parentUrl.indexOf('view=Calendar') != -1) {
			this.fetchAllCalendarFeeds();
		}
		else {
			this.allocateColorsForAllUsers();
			this.fetchAllShareEvents();
		}
	}
})