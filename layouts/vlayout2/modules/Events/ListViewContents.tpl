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

	{*<div class="alphabetSorting noprint">*}
		{*<div id="alphabettable">*}
			{*<div class="table-responsive">*}
				{*<table width="100%" ">*}
				{*<tbody>*}
				{*<tr>*}
					{*{foreach item=ALPHABET from=$ALPHABETS}*}
						{*<td class="alphabettableSearch textAlignCenter cursorPointer {if $ALPHABET_VALUE eq $ALPHABET} highlightBackgroundColor {/if}" style="padding : 0px !important"><a id="{$ALPHABET}" href="#">{$ALPHABET}</a></td>*}
					{*{/foreach}*}
				{*</tr>*}
				{*</tbody>*}
				{*</table>*}
			{*</div>*}
		{*</div>*}
		{*<div id="alphabetpicklist">*}
		{*<span class="btn-group pull-right">*}
			{*<button class="btn dropdown-togglealpha span3" style="text-align: center" data-toggle="dropdown" href="javascript:void(0);">*}
				{*<strong> Alphabet</strong>&nbsp;&nbsp;*}
				{*<i class="caret"></i>*}
			{*</button>*}
			{*<ul class="dropdown-menu">*}
				{*{foreach item=ALPHABET from=$ALPHABETS}*}
					{*<li class="alphabetSearch textAlignCenter cursorPointer {if $ALPHABET_VALUE eq $ALPHABET} highlightBackgroundColor {/if}" style="padding : 0px !important"><a id="{$ALPHABET}" href="#">{$ALPHABET}</a></li>*}
				{*{/foreach}*}
			{*</ul>*}
		{*</span>*}
		{*</div>*}
	{*</div>*}
	{*<div class="clearfix"></div>*}
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
				{assign var=START_DATETIME value=" "|explode:$LISTVIEW_ENTRY->get('date_start')}
				{assign var=START_DATE value=$START_DATETIME[0]}
				{assign var=START_TIME value=$START_DATETIME[1]|cat:$START_DATETIME[2]}
				{assign var=DUE_DATETIME value=" "|explode:$LISTVIEW_ENTRY->get('due_date')}
				{assign var=DUE_DATEWITHYEAR value="-"|explode:$DUE_DATETIME[0]}
				{assign var=DUE_DATE value=$DUE_DATEWITHYEAR[1]|cat:"/"|cat:$DUE_DATEWITHYEAR[2]}
				{assign var=DUE_TIME value=$DUE_DATETIME[1]|cat:$DUE_DATETIME[2]}

				{assign var=IS_DELETE value='true'}
				{assign var=visibility value='true'}
				{if in_array($OWNER_ID, $GROUPS_IDS)}
					{assign var=visibility value=false}
				{elseif $OWNER_ID == $CURRENT_USER_ID}
					{assign var=visibility value=false}
				{/if}
				{if !$CURRENT_USER_MODEL->isAdminUser() && $LISTVIEW_ENTRY->get('activitytype') != 'Task' && $LISTVIEW_ENTRY->get('visibility') == 'Private' && $OWNER_ID && $visibility}
					{assign var=DETAIL_VIEW_URL value=''}
					{assign var=FULL_DETAIL_VIEW_URL value=''}
					{assign var=EDIT_VIEW_URL value=''}
					{assign var=IS_DELETE value=false}
				{/if}
				{if $PREV_START_DATE eq ''}
					<table class="table table-bordered listViewEntriesTable">
					<thead class="listViewHeaders">
					<tr  class="listViewHeaders">
						<th colspan="2">{$START_DATE}</th>
					</tr>
					</thead>
						{$PREV_START_DATE = $START_DATE}
				{elseif $PREV_START_DATE neq $START_DATE}
					</table>
					<table class="table table-bordered listViewEntriesTable">
					<thead class="listViewHeaders">
					<tr  class="listViewHeaders">
						<th colspan="2">{$START_DATE}</th>
					</tr>
					</thead>
						{$PREV_START_DATE = $START_DATE}
				{/if}

					<tr class="listViewEntries" data-id='{$LISTVIEW_ENTRY->getId()}'{if $DETAIL_VIEW_URL} data-recordUrl='{$DETAIL_VIEW_URL}' {/if} id="{$MODULE}_listView_row_{$smarty.foreach.listview.index+1}">
						<td colspan="2">
							{$START_TIME} ～ {if $START_DATE neq $DUE_DATETIME[0]}{$DUE_DATE}{/if} {$DUE_TIME}
						</td>

					</tr>
						<tr>
							<td></td>
							<td>
								<a id="full_activity_{$LISTVIEW_ENTRY->getId()}" data-tooltip="#html_full_activity_{$LISTVIEW_ENTRY->getId()}" href="{$LISTVIEW_ENTRY->getDetailViewUrl()}">{$LISTVIEW_ENTRY->get('subject')}</a>
								{include file='ActivityBalloon.tpl'|@vtemplate_path activityid=$LISTVIEW_ENTRY->getId() activitytype="" gravity="west"}
							</td>
						</tr>
					<tr>
						<td></td>
						<td>
							{$LISTVIEW_ENTRY->get('assigned_user_id')}
						</td>
					</tr>
					<tr>
						<td></td>
						<td>
							{$LISTVIEW_ENTRY->get('parent_id')}
						</td>
					</tr>
					{*<tr class="listViewEntries" data-id='{$LISTVIEW_ENTRY->getId()}'{if $DETAIL_VIEW_URL} data-recordUrl='{$DETAIL_VIEW_URL}' {/if} id="{$MODULE}_listView_row_{$smarty.foreach.listview.index+1}">*}
                        {*<td class="listViewEntryValue {$WIDTHTYPE}" data-field-type="{$LISTVIEW_HEADER->getFieldDataType()}" nowrap>*}
							{*{assign var=LISTVIEW_HEADERNAME value=$LISTVIEW_SUBJECT_HEADERS->get('name')}*}
                            {*{if $LISTVIEW_SUBJECT_HEADERS->isNameField() eq true or $LISTVIEW_SUBJECT_HEADERS->get('uitype') eq '4'}*}
                                {*{if $MODULE == "Calendar" && $LISTVIEW_HEADERNAME == "subject"}*}
                                    {*<a id="full_activity_{$LISTVIEW_ENTRY->getId()}" data-tooltip="#html_full_activity_{$LISTVIEW_ENTRY->getId()}" href="{$LISTVIEW_ENTRY->getDetailViewUrl()}">{$LISTVIEW_ENTRY->get($LISTVIEW_HEADERNAME)}</a>*}
                                    {*{include file='ActivityBalloon.tpl'|@vtemplate_path activityid=$LISTVIEW_ENTRY->getId() activitytype="" gravity="west"}*}
                                {*{else}*}
                                    {*<a href="{$LISTVIEW_ENTRY->getDetailViewUrl()}">{$LISTVIEW_ENTRY->get($LISTVIEW_HEADERNAME)}</a>*}
                                {*{/if}*}
                            {*{else}*}
                                {*{if $MODULE == "Calendar" && $LISTVIEW_HEADERNAME == "subject"}*}
                                    {*<span id="full_activity_{$LISTVIEW_ENTRY->getId()}" data-tooltip="#html_full_activity_{$LISTVIEW_ENTRY->getId()}">*}
										{*{$LISTVIEW_ENTRY->get($LISTVIEW_HEADERNAME)}*}
									{*</span>*}
                                    {*{include file='ActivityBalloon.tpl'|@vtemplate_path activityid=$LISTVIEW_ENTRY->getId() activitytype="" gravity="west"}*}
                                {*{else}*}
									{*{$LISTVIEW_ENTRY->get($LISTVIEW_HEADERNAME)}*}
                                {*{/if}*}
                            {*{/if}*}
                        {*</td>*}
                    {*</tr>*}
								{*<td nowrap class="{$WIDTHTYPE}">*}
								{*<div class="actions pull-right">*}
									{*<span class="actionImages">*}
										{*{if $IS_MODULE_EDITABLE && $EDIT_VIEW_URL && $LISTVIEW_ENTRY->get('taskstatus') neq 'Held' && $LISTVIEW_ENTRY->get('taskstatus') neq 'Completed'}*}
											{*<a class="markAsHeld"><i title="{vtranslate('LBL_MARK_AS_HELD', $MODULE)}" class="icon-ok alignMiddle"></i></a>&nbsp;*}
										{*{/if}*}
										{*{if $IS_MODULE_EDITABLE && $EDIT_VIEW_URL && $LISTVIEW_ENTRY->get('taskstatus') eq 'Held'}*}
											{*<a class="holdFollowupOn"><i title="{vtranslate('LBL_HOLD_FOLLOWUP_ON', "Events")}" class="icon-flag alignMiddle"></i></a>&nbsp;*}
										{*{/if}*}
										{*{if $FULL_DETAIL_VIEW_URL}*}
											{*<a href="{$FULL_DETAIL_VIEW_URL}"><i title="{vtranslate('LBL_SHOW_COMPLETE_DETAILS', $MODULE)}" class="icon-th-list alignMiddle"></i></a>&nbsp;*}
										{*{/if}*}
										{*{if $IS_MODULE_EDITABLE && $EDIT_VIEW_URL}*}
											{*<a href='{$EDIT_VIEW_URL}'><i title="{vtranslate('LBL_EDIT', $MODULE)}" class="icon-pencil alignMiddle"></i></a>&nbsp;*}
										{*{/if}*}
										{*{if $IS_MODULE_DELETABLE && $IS_DELETE}*}
											{*<a class="deleteRecordButton"><i title="{vtranslate('LBL_DELETE', $MODULE)}" class="icon-trash alignMiddle"></i></a>*}
										{*{/if}*}
									{*</span>*}
								{*</div></td>*}
							{*</td>*}
					{*</tr>					{*</tr>*}
								{*<td nowrap class="{$WIDTHTYPE}">*}
								{*<div class="actions pull-right">*}
									{*<span class="actionImages">*}
										{*{if $IS_MODULE_EDITABLE && $EDIT_VIEW_URL && $LISTVIEW_ENTRY->get('taskstatus') neq 'Held' && $LISTVIEW_ENTRY->get('taskstatus') neq 'Completed'}*}
											{*<a class="markAsHeld"><i title="{vtranslate('LBL_MARK_AS_HELD', $MODULE)}" class="icon-ok alignMiddle"></i></a>&nbsp;*}
										{*{/if}*}
										{*{if $IS_MODULE_EDITABLE && $EDIT_VIEW_URL && $LISTVIEW_ENTRY->get('taskstatus') eq 'Held'}*}
											{*<a class="holdFollowupOn"><i title="{vtranslate('LBL_HOLD_FOLLOWUP_ON', "Events")}" class="icon-flag alignMiddle"></i></a>&nbsp;*}
										{*{/if}*}
										{*{if $FULL_DETAIL_VIEW_URL}*}
											{*<a href="{$FULL_DETAIL_VIEW_URL}"><i title="{vtranslate('LBL_SHOW_COMPLETE_DETAILS', $MODULE)}" class="icon-th-list alignMiddle"></i></a>&nbsp;*}
										{*{/if}*}
										{*{if $IS_MODULE_EDITABLE && $EDIT_VIEW_URL}*}
											{*<a href='{$EDIT_VIEW_URL}'><i title="{vtranslate('LBL_EDIT', $MODULE)}" class="icon-pencil alignMiddle"></i></a>&nbsp;*}
										{*{/if}*}
										{*{if $IS_MODULE_DELETABLE && $IS_DELETE}*}
											{*<a class="deleteRecordButton"><i title="{vtranslate('LBL_DELETE', $MODULE)}" class="icon-trash alignMiddle"></i></a>*}
										{*{/if}*}
									{*</span>*}
								{*</div></td>*}
							{*</td>*}
					{*</tr>*}

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
{/strip}