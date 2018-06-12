<?php
/*+***********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 *************************************************************************************/

class Calendar_PopupSave_Action extends Calendar_Save_Action {
	public function process(Vtiger_Request $request) {
		$recordModel = $this->saveRecord($request);
		$loadUrl = "index.php?module=Calendar&view=PopupDetail&record={$recordModel->getId()}";
		header("Location: $loadUrl");
	}
}
