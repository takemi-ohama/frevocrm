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
{include file="PopupHeader.tpl"|vtemplate_path:$MODULE}
<input type='hidden' value="{$MODULE}" id='module' name='module'/>
<input type="hidden" value="{$PARENT_MODULE}" id="parent" name='parent' />
<input type='hidden' value="{$VIEW}" id='view' name='view'/>
<div class="bodyContents">
	<div class="mainContainer row-fluid" style="min-width:100%">
		<div class="contentsDiv {if $LEFTPANELHIDE neq '1'} span12 {/if}marginLeftZero" id="rightPanel" style="min-height:550px;">
