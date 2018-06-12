<?php
/*+***********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 *************************************************************************************/
include_once 'vtlib/Vtiger/Field.php';
require_once 'include/utils/ConfigReader.php';
/**
 * Vtiger Field Model Class
 */
class Leads_Field_Model extends Vtiger_Field_Model {
	

	/**
	 * Function to check whether the current field is editable
	 * @return <Boolean> - true/false
	 */
	public function isEditable() {
		$fieldname=$this->getFieldName();
		$not_edit_columns_Config = new ConfigReader('modules/Leads/config.not_edit_columns.inc', 'not_edit_columns_Config');
		$not_edit_columns = $not_edit_columns_Config->getConfig("not_edit_columns");
		if(in_array($fieldname, $not_edit_columns)) {
			return false;
		}
		if(!$this->isEditEnabled()
				|| !$this->isViewable() ||
				((int)$this->get('displaytype')) != 1 ||
				$this->isReadOnly() == true ||
				$this->get('uitype') ==  4) {

			return false;
		}
		return true;
	}

}