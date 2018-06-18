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
	{assign var="MODULE_NAME" value=$MODULE_MODEL->get('name')}
	<input id="recordId" type="hidden" value="{$RECORD->getId()}" />
	<div class="detailViewContainer">
		<div class="row-fluid detailViewTitle">
			<div class="span12">
				<div class="row-fluid">
					<div class="span5">
						<div class="row-fluid">
							<span class="span10 margin0px">
								<span class="row-fluid">
									<span class="recordLabel font-x-x-large textOverflowEllipsis span pushDown" title="{$RECORD->getName()}">
										{foreach item=NAME_FIELD from=$MODULE_MODEL->getNameFields()}
											{assign var=FIELD_MODEL value=$MODULE_MODEL->getField($NAME_FIELD)}
												{if $FIELD_MODEL->getPermissions()}
													<span class="{$NAME_FIELD}">{$RECORD->get($NAME_FIELD)}</span>&nbsp;
												{/if}
										{/foreach}
										の更新処理中
									</span>
								</span>
							</span>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="row-fluid">
			<div class="span12 {if !empty($DETAILVIEW_LINKS['DETAILVIEWTAB']) || !empty($DETAILVIEW_LINKS['DETAILVIEWRELATED']) } details {/if}">
				<form id="detailView" data-name-fields='{ZEND_JSON::encode($MODULE_MODEL->getNameFields())}' method="POST">
                                    {if !empty($PICKLIST_DEPENDENCY_DATASOURCE)} 
                                        <input type="hidden" name="picklistDependency" value="{Vtiger_Util_Helper::toSafeHTML($PICKLIST_DEPENDENCY_DATASOURCE)}"> 
                                    {/if} 
					<div class="contents">
{/strip}
