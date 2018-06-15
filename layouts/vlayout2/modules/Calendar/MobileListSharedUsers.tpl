{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the vtiger CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  vtiger CRM Open Source
   * The Initial Developer of the Original Code is vtiger.
   * Portions created by vtiger are Copyright (C) vtiger.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
{strip}
<div name='calendarViewTypes'>
	{assign var=SHARED_USER_INFO value= Zend_Json::encode($SHAREDUSERS_INFO)}
	{assign var=CURRENT_USER_ID value= $CURRENTUSER_MODEL->getId()}
	<div id="calendarview-feeds" style="margin-left:10px;">
		<!--Adding or Editing Users Modal in Shared Calendar-->
		<div class="modal addViewsToCalendar hide">
			<div class="modal-header contentsBackground">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h3>{vtranslate('LBL_ADD_CALENDAR_VIEW', $MODULE)}</h3>
			</div>
			<div class="modal-body">
				<form class="form-horizontal">
					<input type="hidden" class="selectedUser" value="" />
					<input type="hidden" class="selectedUserColor" value="" />
					<input type="hidden" class="userCalendarMode" value="" />
					<div class="control-group addCalendarViewsList">
						<label class="control-label">{vtranslate('LBL_SELECT_USER_CALENDAR', $MODULE)}</label>
						<div class="controls">
							<select class="select2" name="usersCalendarList" style="min-width: 250px;">
								{foreach key=USER_ID item=USER_NAME from=$SHAREDUSERS}
									{if $SHAREDUSERS_INFO[$USER_ID]['visible'] == '0'}
										<option value="{$USER_ID}">{$USER_NAME}</option>
									{/if}
								{/foreach}
							</select>
						</div>
					</div>
					<div class="control-group editCalendarViewsList">
						<label class="control-label">{vtranslate('LBL_EDITING_CALENDAR_VIEW', $MODULE)}</label>
						<div class="controls">
							<select class="select2" name="editingUsersList" style="min-width: 250px;">
								<option value="{$CURRENT_USER_ID}" data-user-color="{$SHAREDUSERS_INFO[$CURRENT_USER_ID]['color']}">{vtranslate('LBL_MINE',$MODULE)}</option>
								{foreach key=USER_ID item=USER_NAME from=$SHAREDUSERS}
									{if $SHAREDUSERS_INFO[$USER_ID]['visible'] != '0'}
										<option value="{$USER_ID}">{$USER_NAME}</option>
									{/if}
								{/foreach}
							</select>
						</div>
					</div>
					<div class="control-group">
						<label class="control-label">{vtranslate('LBL_SELECT_CALENDAR_COLOR', $MODULE)}</label>
						<div class="controls">
							<p class="calendarColorPicker"></p>
						</div>
					</div>
				</form>
			</div>
			{include file='ModalFooter.tpl'|@vtemplate_path:$MODULE}
		</div>
		<!--Adding or Editing Users Modal in Shared Calendar-->
		
		<div class="labelModal hide">
			<label class="checkbox addedCalendars" style="text-shadow: none">
				<input type="checkbox" />
				&nbsp;<span class="label" style="text-shadow: none"></span>
				&nbsp;<i class="icon-pencil editCalendarColor cursorPointer actionImage" title="{vtranslate('LBL_EDIT_COLOR',$MODULE)}"></i>
				&nbsp;<i class="icon-trash cursorPointer actionImage deleteCalendarView" title="{vtranslate('LBL_DELETE_CALENDAR',$MODULE)}"></i>
			</label>
		</div>
		
		<input type="hidden" class="sharedUsersInfo" value= {Zend_Json::encode($SHAREDUSERS_INFO)} />
		<label class="checkbox addedCalendars" style="text-shadow: none">
			<input type="checkbox" id="userCheckList" data-calendar-sourcekey="Events33_{$CURRENT_USER_ID}" data-calendar-feed="Events"
				   data-calendar-userid="{$CURRENT_USER_ID}" data-calendar-feed-color="{$SHAREDUSERS_INFO[$CURRENT_USER_ID]['color']}" data-calendar-username="{getUserFullName($CURRENT_USER_ID)}" >
			&nbsp;<span class="label" style="text-shadow: none; background-color: {$SHAREDUSERS_INFO[$CURRENT_USER_ID]['color']};">{vtranslate('LBL_MINE',$MODULE)}</span>
			&nbsp;<i class="icon-pencil editCalendarColor cursorPointer actionImage" title="{vtranslate('LBL_EDIT_COLOR',$MODULE)}"></i>
		</label>
		{assign var=INVISIBLE_CALENDAR_VIEWS_EXISTS value='false'}
		{foreach key=ID item=USER from=$SHAREDUSERS}
			{if $SHAREDUSERS_INFO[$ID]['visible'] != '0'}
				<label class="checkbox addedCalendars">
					<input type="checkbox" id="userCheckList" data-calendar-sourcekey="Events33_{$ID}" data-calendar-feed="Events" data-calendar-userid="{$ID}" data-calendar-feed-color="{$SHAREDUSERS_INFO[$ID]['color']}" data-calendar-username="{getUserFullName($ID)}">
					&nbsp;<span class="label" style="text-shadow: none; background-color: {$SHAREDUSERS_INFO[$ID]['color']};">{$USER}</span>
					&nbsp;<i class="icon-pencil editCalendarColor cursorPointer actionImage" title="{vtranslate('LBL_EDIT_COLOR',$MODULE)}"></i>
					&nbsp;<i class="icon-trash cursorPointer actionImage deleteCalendarView" title="{vtranslate('LBL_DELETE_CALENDAR',$MODULE)}"></i>
				</label>
			{else}
				{assign var=INVISIBLE_CALENDAR_VIEWS_EXISTS value='true'}
			{/if}
		{/foreach}
		<input type="hidden" class="invisibleCalendarViews" value="{$INVISIBLE_CALENDAR_VIEWS_EXISTS}" />
	</div>
</div>
{/strip}
<script type="text/javascript">
	{literal}
	jQuery(document).ready(function() {
		Vtiger_List_Js.getInstance().registerEvents();
	});
//	jQuery(document).ready(function() {
//		var thisInstance = this;
//		jQuery('#calendarview-feeds').on('change', '[data-calendar-feed]', function (e) {
//			var currentTarget = $(e.currentTarget);
//			var type = currentTarget.data('calendar-sourcekey');
//			var username = currentTarget.data('calendar-username');
//			if (currentTarget.is(':checked')) {
//				var paramsArray = [];
//				var url = location.href;
//				parameters = url.split("#");
//				if( parameters.length > 1 ) {
//					url = parameters[0];
//				}
//				parameters = url.split("?");
//				if( parameters.length > 1 ) {
//					var params   = parameters[1].split("&");
//					for ( i = 0; i < params.length; i++ ) {
//						var paramItem = params[i].split("=");
//						paramsArray[paramItem[0]] = paramItem[1];
//					}
//				}
//				var params = paramsArray ;
//				params['search_params'] = encodeURIComponent( '[[[\"assigned_user_id\"\,\"c\"\,\"'+username+'\"]]]' );
//				var resurl = location.href.replace(/\?.*$/,"");
//				for ( key in paramsArray ) {
//					resurl += (resurl.indexOf('?') == -1) ? '?':'&';
//					resurl += key + '=' + paramsArray[key];
//				}
//				window.location.href = resurl;
//
//			} else {
//
//
//			}
//		});
//	});
	{/literal}

</script>