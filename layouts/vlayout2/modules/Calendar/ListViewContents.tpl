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
	<input type="hidden" id="view" value="{$VIEW}" />
	<input type="hidden" id="pageStartRange" value="{$PAGING_MODEL->getRecordStartRange()}" />
	<input type="hidden" id="pageEndRange" value="{$PAGING_MODEL->getRecordEndRange()}" />
	<input type="hidden" id="previousPageExist" value="{$PAGING_MODEL->isPrevPageExists()}" />
	<input type="hidden" id="nextPageExist" value="{$PAGING_MODEL->isNextPageExists()}" />
	<input type="hidden" id="alphabetSearchKey" value= "{$MODULE_MODEL->getAlphabetSearchField()}" />
	<input type="hidden" id="Operator" value="{$OPERATOR}" />
	<input type="hidden" id="alphabetValue" value="{$ALPHABET_VALUE}" />
	<input type="hidden" id="totalCount" value="{$LISTVIEW_COUNT}" />
	<input type='hidden' value="{$PAGE_NUMBER}" id='pageNumber'>
	<input type='hidden' value="{$PAGING_MODEL->getPageLimit()}" id='pageLimit'>
	<input type="hidden" value="{$LISTVIEW_ENTRIES_COUNT}" id="noOfEntries">

	{assign var = ALPHABETS_LABEL value = vtranslate('LBL_ALPHABETS', 'Vtiger')}
	{assign var = ALPHABETS value = ','|explode:$ALPHABETS_LABEL}

	<div id="selectAllMsgDiv" class="alert-block msgDiv noprint">
		<strong><a id="selectAllMsg">{vtranslate('LBL_SELECT_ALL',$MODULE)}&nbsp;{vtranslate($MODULE ,$MODULE)}&nbsp;(<span id="totalRecordsCount"></span>)</a></strong>
	</div>
	<div id="deSelectAllMsgDiv" class="alert-block msgDiv noprint">
		<strong><a id="deSelectAllMsg">{vtranslate('LBL_DESELECT_ALL_RECORDS',$MODULE)}</a></strong>
	</div>
	<div class="contents-topscroll noprint">
		<div class="topscroll-div">
			&nbsp;
		</div>
	</div>
	<div class="listViewEntriesDiv contents-bottomscroll">
		<div class="bottomscroll-div">
			<input type="hidden" value="due_date" id="orderBy">
			<input type="hidden" value="DESC" id="sortOrder">
			<span class="listViewLoadingImageBlock hide modal noprint" id="loadingListViewModal">
		<img class="listViewLoadingImage" src="{vimage_path('loading.gif')}" alt="no-image" title="{vtranslate('LBL_LOADING', $MODULE)}"/>
		<p class="listViewLoadingMsg">{vtranslate('LBL_LOADING_LISTVIEW_CONTENTS', $MODULE)}........</p>
	</span>
			{assign var=PREV_START_DATE value=''}
			{assign var=WIDTHTYPE value=$CURRENT_USER_MODEL->get('rowheight')}
			{foreach item=LISTVIEW_ENTRY from=$LISTVIEW_ENTRIES name=listview}
				{assign var=CURRENT_USER_ID value=$CURRENT_USER_MODEL->getId()}
				{assign var=RAWDATA value=$LISTVIEW_ENTRY->getRawData()}
				{assign var=OWNER_ID value=$RAWDATA['smownerid']}
				{assign var=DETAIL_VIEW_URL value=$LISTVIEW_ENTRY->getDetailViewUrl()}
				{assign var=FULL_DETAIL_VIEW_URL value=$LISTVIEW_ENTRY->getFullDetailViewUrl()}
				{assign var=EDIT_VIEW_URL value=$LISTVIEW_ENTRY->getEditViewUrl()}
				{assign var=START_DATETIME value=" "|explode:$LISTVIEW_ENTRY->get('start_datetime')}
				{assign var=START_DATE value=$START_DATETIME[0]}
				{assign var=START_TIME value=$START_DATETIME[1]}
				{assign var=DUE_DATETIME value=" "|explode:$LISTVIEW_ENTRY->get('due_datetime')}
				{assign var=DUE_DATE value=$DUE_DATETIME[0]}
				{assign var=DUE_TIME value=$DUE_DATETIME[1]}
				{assign var=IS_NOT_PAST value=$LISTVIEW_ENTRY->get('is_not_past')}
				{assign var=IS_DELETE value='true'}
				{assign var=visibility value='true'}
				{if in_array($OWNER_ID, $GROUPS_IDS)}
					{assign var=visibility value=false}
				{elseif $OWNER_ID == $CURRENT_USER_ID}
					{assign var=visibility value=false}
				{elseif $IS_NOT_PAST eq 0 }
					{assign var=visibility value=false}
				{/if}
				{if !$CURRENT_USER_MODEL->isAdminUser() && $LISTVIEW_ENTRY->get('activitytype') != 'Task' && $LISTVIEW_ENTRY->get('visibility') == 'Private' && $OWNER_ID && $visibility}
					{assign var=DETAIL_VIEW_URL value=''}
					{assign var=FULL_DETAIL_VIEW_URL value=''}
					{assign var=EDIT_VIEW_URL value=''}
					{assign var=IS_DELETE value=false}
				{/if}
				{if $PREV_START_DATE eq ''}
					<table class="table table-bordered listViewEntriesTable mobile-calendar">
					<thead class="listViewHeaders">
					<tr  class="listViewHeaders">
						<th colspan="2">{$START_DATE}</th>
					</tr>
					</thead>
						{$PREV_START_DATE = $START_DATE}
				{elseif $PREV_START_DATE neq $START_DATE}
					</table>
					<table class="table table-bordered listViewEntriesTable mobile-calendar">
					<thead class="listViewHeaders">
					<tr  class="listViewHeaders">
						<th colspan="2">{$START_DATE}</th>
					</tr>
					</thead>
						{$PREV_START_DATE = $START_DATE}
				{/if}

					<tr class="listViewEntries" data-id='{$LISTVIEW_ENTRY->getId()}'{if $DETAIL_VIEW_URL} data-recordUrl='{$DETAIL_VIEW_URL}' {/if} id="{$MODULE}_listView_row_{$smarty.foreach.listview.index+1}">
						<td class="time">
							{$START_TIME} ～ {if $START_DATE neq $DUE_DATETIME[0]}{$DUE_DATE}{/if} {$DUE_TIME}
						</td>
						<td class="user">
							{$LISTVIEW_ENTRY->get('assigned_user_id')}
						</td>

					</tr>
					<tr>
						<td colspan="2">
							<a id="full_activity_{$LISTVIEW_ENTRY->getId()}" data-tooltip="#html_full_activity_{$LISTVIEW_ENTRY->getId()}" href="{$LISTVIEW_ENTRY->getDetailViewUrl()}">{$LISTVIEW_ENTRY->get('subject')}</a>
							{include file='ActivityBalloon.tpl'|@vtemplate_path activityid=$LISTVIEW_ENTRY->getId() activitytype="" gravity="west"}
						</td>
					</tr>
					{if $LISTVIEW_ENTRY->get('parent_id') != '--' }
					
					<tr>
						<td colspan="2">
							<span>
								{$LISTVIEW_ENTRY->get('parent_id')}
							</span>
						</td>
					</tr>
					
					{/if}
					<tr>
						{assign var=str_contactlist value=""}
						{foreach item=CONTACT_RECORD from=getContactList($RAWDATA['activityid'])}
							{assign var=url value='<a href="index.php?module=Contacts&view=Detail&record='|cat:{$CONTACT_RECORD.id}|cat:'" target="_brank">'|cat:{$CONTACT_RECORD.name}|cat:'</a>'}
							{assign var=str_contactlist value=$str_contactlist|cat:$url}
						{/foreach}
						<td class="contacts" colspan="2">
							{$str_contactlist}
						</td>
					</tr>
			{/foreach}
					</table>


			<!--added this div for Temporarily -->
			{if $LISTVIEW_ENTRIES_COUNT eq '0'}
				<table class="emptyRecordsDiv">
					<tbody>
					<tr>
						<td>
							{assign var=SINGLE_MODULE value="SINGLE_$MODULE"}
							{vtranslate('LBL_EQ_ZERO')} {vtranslate($MODULE, $MODULE)} {vtranslate('LBL_FOUND')}.{if $IS_MODULE_EDITABLE} {vtranslate('LBL_CREATE')} <a href="{$MODULE_MODEL->getCreateRecordUrl()}">{vtranslate($SINGLE_MODULE, $MODULE)}</a>{/if}
						</td>
					</tr>
					</tbody>
				</table>
			{/if}
		</div>
	</div>
	<style type="text/css">
		.mobile-calendar {
		}
		.mobile-calendar .user {
			text-align:right;
			color: #666;
			font-size: 12px;
		}
		.mobile-calendar .contacts {
			text-align: right;
			font-size: 12px;
		}
	</style>
{/strip}
