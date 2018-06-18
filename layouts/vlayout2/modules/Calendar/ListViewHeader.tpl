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

	<div class="listViewPageDiv">
	<div class="listViewTopMenuDiv noprint">
		<div class="listViewActionsDiv row-fluid">
				<span class="btn-toolbar span4">
					<span class="btn-group listViewMassActions" style="display:none;">
						{if count($LISTVIEW_MASSACTIONS) gt 0 || $LISTVIEW_LINKS['LISTVIEW']|@count gt 0}
							<button class="btn dropdown-toggle" data-toggle="dropdown"><strong>{vtranslate('LBL_ACTIONS', $MODULE)}</strong>&nbsp;&nbsp;<i class="caret"></i></button>
							<ul class="dropdown-menu">
								{foreach item="LISTVIEW_MASSACTION" from=$LISTVIEW_MASSACTIONS name=actionCount}
									<li id="{$MODULE}_listView_massAction_{Vtiger_Util_Helper::replaceSpaceWithUnderScores($LISTVIEW_MASSACTION->getLabel())}"><a href="javascript:void(0);" {if stripos($LISTVIEW_MASSACTION->getUrl(), 'javascript:')===0}onclick='{$LISTVIEW_MASSACTION->getUrl()|substr:strlen("javascript:")};'{else} onclick="Vtiger_List_Js.triggerMassAction('{$LISTVIEW_MASSACTION->getUrl()}')"{/if} >{vtranslate($LISTVIEW_MASSACTION->getLabel(), $MODULE)}</a></li>
									{if $smarty.foreach.actionCount.last eq true}
									<li class="divider"></li>
								{/if}
								{/foreach}
								{if $LISTVIEW_LINKS['LISTVIEW']|@count gt 0}
									{foreach item=LISTVIEW_ADVANCEDACTIONS from=$LISTVIEW_LINKS['LISTVIEW']}
										<li id="{$MODULE}_listView_advancedAction_{Vtiger_Util_Helper::replaceSpaceWithUnderScores($LISTVIEW_ADVANCEDACTIONS->getLabel())}"><a {if stripos($LISTVIEW_ADVANCEDACTIONS->getUrl(), 'javascript:')===0} href="javascript:void(0);" onclick='{$LISTVIEW_ADVANCEDACTIONS->getUrl()|substr:strlen("javascript:")};'{else} href='{$LISTVIEW_ADVANCEDACTIONS->getUrl()}' {/if}>{vtranslate($LISTVIEW_ADVANCEDACTIONS->getLabel(), $MODULE)}</a></li>
									{/foreach}
								{/if}
							</ul>
						{/if}
					</span>
					{foreach item=LISTVIEW_BASICACTION from=$LISTVIEW_LINKS['LISTVIEWBASIC']}
						<span class="btn-group">
							<button id="{$MODULE}_listView_basicAction_{Vtiger_Util_Helper::replaceSpaceWithUnderScores($LISTVIEW_BASICACTION->getLabel())}" class="btn addButton" {if stripos($LISTVIEW_BASICACTION->getUrl(), 'javascript:')===0} onclick='{$LISTVIEW_BASICACTION->getUrl()|substr:strlen("javascript:")};'{else} onclick='window.location.href="{$LISTVIEW_BASICACTION->getUrl()}"'{/if}><i class="icon-plus"></i>&nbsp;<strong>{vtranslate($LISTVIEW_BASICACTION->getLabel(), $MODULE)}</strong></button>
						</span>
					{/foreach}
				</span>
			<span>
				<table width="100%">
					<tr style="height: 30px">
						<input type="hidden" id="startDate" value="{$START_DATE}">
						<input type="hidden" id="range" value="{$RANGE}">
						{foreach item=USER from=$USERS}
							<input type="hidden" id="userList" value="{$USER}">
						{/foreach}

						<td align="center" id="goToPrev" style="font-size: large;background: #F3F3F3;border-bottom-color:#b3b3b3;border-color:#ccc;border-width: 1px;border-style: solid"> ◄ </td>
						<td align="center" id="baseDate">{$START_DATE}</td>
						<td align="center" id="goToNext"style="font-size: large;background: #F3F3F3;border-bottom-color:#b3b3b3;border-color:#ccc;border-width: 1px;border-style: solid"> ► </td>
						<td width="5px"></td>
						<td colspan="2" width="100px" align="center" id="goToToday"style="font-size: large; background: #F3F3F3;border-bottom-color:#b3b3b3;border-color:#ccc;border-width: 1px;border-style: solid">今日</td>
					</tr>
					<tr>
						<td height="5px" colspan="6">
						</td>
					</tr>
					<tr style="height: 30px">
						<td colspan="3" align="center" style="font-size: large;background: #F3F3F3;border-bottom-color:#b3b3b3;border-color:#ccc;border-width: 1px;border-style: solid">
							<div style="height: 100%">
								<p class="link2" style="height: 100%;margin: 0px;font-size: inherit">
									<a href='index.php?module=Calendar&view=PopupUserSelect&mode=userSelect' id="userListModal">ユーザー選択</a>
								</p>
							</div>
						</td>
						<td width="5px"></td>
						<td align="center" id="rangeWeek"style="font-size: large; background: #F3F3F3;border-bottom-color:#b3b3b3;border-color:#ccc;border-width: 1px;border-style: solid">週</td>
						<td align="center" id="rangeDay"style="font-size: large; background: #F3F3F3;border-bottom-color:#b3b3b3;border-color:#ccc;border-width: 1px;border-style: solid">日</td>
					</tr>
				</table>
			</span>
		</div>
	</div>
	<div class="listViewContentDiv" id="listViewContents">
{/strip}