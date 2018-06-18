
<style>

.dark-tooltip.dark {
 width:500px;
}

.dark-tooltip.dark a {
 color:white;
}
.dark-tooltip.dark span.c_title {
 font-size:bold;
 margin-right:20px;
 color:#FFC660;
}
</style>
<script>
$(function() {
	$('#full_activity_{$activityid}').darkTooltip({
	  gravity:'{$gravity}',
	  theme:'dark',
	});
});
</script>

{if $activitytype eq ""}
	{assign var=RECORD value=Vtiger_Record_Model::getInstanceById($activityid,"Events")}
	{assign var=activitytype value=""}
	{if $RECORD->getType() eq 'Calendar'}
		{assign var=RECORD value=Vtiger_Record_Model::getInstanceById($activityid,"Calendar")}
		{assign var=activitytype value="Task"}
	{/if}
{elseif $activitytype eq "Task"}
	{assign var=RECORD value=Vtiger_Record_Model::getInstanceById($activityid,"Events")}
{else}
	{assign var=RECORD value=Vtiger_Record_Model::getInstanceById($activityid,"Calendar")}
{/if}

<div id="html_full_activity_{$activityid}" style="display:none;">
{if $activitytype eq "Task"}
	{assign var=RECORD value=Vtiger_Record_Model::getInstanceById($activityid,"Calendar")}
	
	{*<!-- 表題 -->*}
	<span class="c_title">{vtranslate('LBL_SUBJECT',$RECORD->getModuleName())}</span>
	{$RECORD->get("subject")}<br>
	
	{*<!-- 担当 -->*}
	<span class="c_title">{vtranslate('Assigned To',$RECORD->getModuleName())}</span>
	{getUserFullName($RECORD->get("assigned_user_id"))}<br>
	
	{*<!-- 開始日と終了日 -->*}
	<span class="c_title">{vtranslate('Start Date & Time',$RECORD->getModuleName())}</span>
	{Vtiger_Util_Helper::formatDateTimeIntoDayString($RECORD->get("date_start")|cat:" "|cat:$RECORD->get("time_start"))}　～　{Vtiger_Util_Helper::formatDateIntoStrings($RECORD->get("due_date"))}<br>
	
	{*<!-- 活動タイプ -->*}
	<span class="c_title">{vtranslate('LBL_ACTIVITY_TYPES',$RECORD->getModuleName())}</span>
	{vtranslate($RECORD->get("activitytype"),$RECORD->getModuleName())}<br>
	
	{*<!-- ステータス -->*}
	<span class="c_title">{vtranslate('Status',"Vtiger")}</span>
	{vtranslate($RECORD->get("taskstatus"),$RECORD->getModuleName())}<br>
	
	{*<!-- 結果 -->*}
	<span class="c_title">{vtranslate('Description',$RECORD->getModuleName())}</span><br>
	{nl2br($RECORD->get("description"))}<br>
	
{else}
	{assign var=RECORD value=Vtiger_Record_Model::getInstanceById($activityid,"Events")}
	
	{*<!-- お客様リスト作成 -->*}
	{assign var=str_contactlist value=""}
	{foreach item=CONTACT_RECORD from=getContactList($activityid)}
		{assign var=url value='<a href="index.php?module=Contacts&view=Detail&record='|cat:{$CONTACT_RECORD.id}|cat:'" target="_brank">'|cat:{$CONTACT_RECORD.name}|cat:'</a>'}
		{assign var=str_contactlist value=$str_contactlist|cat:"　"|cat:$url}
	{/foreach}
	
	{*<!-- 表題 -->*}
	<span class="c_title">{vtranslate('LBL_SUBJECT',$RECORD->getModuleName())}</span>
	{$RECORD->get("subject")}<br>
	
	{*<!-- 担当 -->*}
	<span class="c_title">{vtranslate('Assigned To',$RECORD->getModuleName())}</span>
	{getUserFullName($RECORD->get("assigned_user_id"))}<br>
	
	{*<!-- 開始日と終了日 -->*}
	<span class="c_title">{vtranslate('Start Date & Time',$RECORD->getModuleName())}</span>
	{Vtiger_Util_Helper::formatDateTimeIntoDayString($RECORD->get("date_start")|cat:" "|cat:$RECORD->get("time_start"))}　～　{Vtiger_Util_Helper::formatDateTimeIntoDayString($RECORD->get("due_date")|cat:" "|cat:$RECORD->get("time_end"))}<br>
	
	{*<!-- 活動タイプ -->*}
	<span class="c_title">{vtranslate('LBL_ACTIVITY_TYPES',"Calendar")}</span>
	{vtranslate($RECORD->get("activitytype"),$RECORD->getModuleName())}<br>
	
	{*<!-- ステータス -->*}
	<span class="c_title">{vtranslate('Status',"Vtiger")}</span>
	{vtranslate($RECORD->get("eventstatus"),$RECORD->getModuleName())}<br>
	
	{*<!-- お客様 -->*}
	<span class="c_title">{vtranslate('Contacts',$RECORD->getModuleName())}</span>
	{$str_contactlist}<br>
	
	{*<!-- 関連 -->*}
	{if $RECORD->get("parent_id") > 0 && !Vtiger_Util_Helper::checkRecordExistance($RECORD->get("parent_id"))}
	{assign var=PARENT_RECORD value=Vtiger_Record_Model::getInstanceById($RECORD->get("parent_id"))}
	{assign var=str_parent_lavel value=$PARENT_RECORD->getName()}
	{assign var=str_parent_module_name value=$PARENT_RECORD->getModuleName()}
	{assign var=str_parent_url value='<a href="index.php?module='|cat:{$str_parent_module_name}|cat:'&view=Detail&record='|cat:{$RECORD->get("parent_id")}|cat:'" target="_brank">'|cat:{$str_parent_lavel}|cat:'</a>'}
	<span class="c_title">{vtranslate($str_parent_module_name)}</span>
	{$str_parent_url}<br>
	{/if}
	
	{*<!-- 結果 -->*}
	<span class="c_title">{vtranslate('Description',$RECORD->getModuleName())}</span><br>
	{nl2br($RECORD->get("description"))}
{/if}
</div>