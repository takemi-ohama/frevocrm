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
<html>
<head>
	<title>ユーザー選択</title>
	<script type="text/javascript" src="libraries/jquery/jquery.min.js"></script>
	<!--[if IE]>
	<script type="text/javascript" src="libraries/html5shim/html5.js"></script>
	<script type="text/javascript" src="libraries/html5shim/respond.js"></script>
	<![endif]-->
	<script type="text/javascript">var csrfMagicToken = "sid:ca6ebe23803d3f4396d18f1e799bc70d62cc64ae,1497928675";var csrfMagicName = "__vtrftk";</script>
	<script src="libraries/csrf-magic/csrf-magic.js" type="text/javascript"></script>
</head＞
<BODY>
<div name='calendarViewTypes'>
    {assign var=SHARED_USER_INFO value= Zend_Json::encode($SHAREDUSERS_INFO)}
    {assign var=CURRENT_USER_ID value= $CURRENTUSER_MODEL->getId()}
	<div id="calendarview-feeds" style="margin-left:10px;">

		<input type="hidden" class="sharedUsersInfo" value= {Zend_Json::encode($SHAREDUSERS_INFO)} />
		<input type="text" id="userSearchBox" />
		<div class="userLabel">
		<label class="checkbox addedCalendars" style="text-shadow: none">
			<input id="popupUserSelect" type="checkbox" data-calendar-sourcekey="Events33_{$CURRENT_USER_ID}" data-calendar-feed="Events"
				   data-calendar-userid="{$CURRENT_USER_ID}" data-calendar-feed-color="{$SHAREDUSERS_INFO[$CURRENT_USER_ID]['color']}" data-calendar-username="{getUserFullName($CURRENT_USER_ID)}" >
				&nbsp;<span class="label" style="text-shadow: none; background-color: {$SHAREDUSERS_INFO[$CURRENT_USER_ID]['color']};">{vtranslate('LBL_MINE',$MODULE)}</span>
			&nbsp;<i class="icon-pencil editCalendarColor cursorPointer actionImage" title="{vtranslate('LBL_EDIT_COLOR',$MODULE)}"></i>
		</label>
		</div>
        {assign var=INVISIBLE_CALENDAR_VIEWS_EXISTS value='false'}
        {foreach key=ID item=USER from=$SHAREDUSERS}
            {if $SHAREDUSERS_INFO[$ID]['visible'] != '0'}
				<div class="userLabel">
				<label class="checkbox addedCalendars">
					<input id="popupUserSelect" type="checkbox" data-calendar-sourcekey="Events33_{$ID}" data-calendar-feed="Events" data-calendar-userid="{$ID}" data-calendar-feed-color="{$SHAREDUSERS_INFO[$ID]['color']}"data-calendar-username="{getUserFullName($ID)}">
						&nbsp;<span class="label" style="text-shadow: none; background-color: {$SHAREDUSERS_INFO[$ID]['color']};">{$USER}</span>
				</label>
				</div>
            {else}
                {assign var=INVISIBLE_CALENDAR_VIEWS_EXISTS value='true'}
            {/if}
        {/foreach}
		<input type="hidden" class="invisibleCalendarViews" value="{$INVISIBLE_CALENDAR_VIEWS_EXISTS}" />


	</div>
	<input type="hidden" id="setUserList" value="">
</div>
{/strip}


<script type="text/javascript">
    jQuery('#calendarview-feeds').on('change', '[data-calendar-feed]', function (e) {
        var currentTarget = $(e.currentTarget);
        var type = currentTarget.data('calendar-sourcekey');
        var username = currentTarget.data('calendar-username');
        if (currentTarget.is(':checked')) {
            var popupUsersList = $('#setUserList').val().split(',');
            popupUsersList.push(username);
        }
        else{
            var popupUsersList = $('#setUserList').val().split(',');
            popupUsersList.some(function(v, i){
                if (v===username) popupUsersList.splice(i,1);
            });
        }
        $('#setUserList').val(popupUsersList.join(','));
    });
searchWord = function(){
	var searchResult,
        searchText = $(this).val(),
        targetText;
    $('.userLabel').hide();
    if (searchText != '') {
        $('.userLabel').each(function() {
            targetText = $(this).find('#popupUserSelect').data('calendar-username');
            if (targetText.indexOf(searchText) != -1) {
                $(this).show();
            }
        });
    }
	};

	// searchWordの実行
	$('#userSearchBox').on('input', searchWord);
</script>
<!-- Added in the end since it should be after less file loaded -->
<script type="text/javascript" src="libraries/bootstrap/js/less.min.js"></script></div><script type="text/javascript">CsrfMagic.end();</script>
</body>
</html>
