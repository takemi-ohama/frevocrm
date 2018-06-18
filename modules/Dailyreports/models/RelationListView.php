<?php
/*+***********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 *************************************************************************************/

class Dailyreports_RelationListView_Model extends Vtiger_RelationListView_Model {

	public function getHeaders() {
		$relationModel = $this->getRelationModel();
		$relatedModuleModel = $relationModel->getRelationModuleModel();

		$summaryFieldsList = $relatedModuleModel->getSummaryViewFieldsList();

		$headerFields = array();
		if(count($summaryFieldsList) > 0) {
			foreach($summaryFieldsList as $fieldName => $fieldModel) {
				$headerFields[$fieldName] = $fieldModel;
			}
		} else {
			$headerFieldNames = $relatedModuleModel->getRelatedHistoryListFields();
			foreach($headerFieldNames as $fieldName) {
				$headerFields[$fieldName] = $relatedModuleModel->getField($fieldName);
			}
		}
		return $headerFields;
	}
	
	public function getEntries($pagingModel) {
		$db = PearDatabase::getInstance();
		$parentModule = $this->getParentRecordModel()->getModule();
		$relationModule = $this->getRelationModel()->getRelationModuleModel();
		$relatedColumnFields = $relationModule->getConfigureRelatedListFields();
		if(count($relatedColumnFields) <= 0){
			$relatedColumnFields = $relationModule->getRelatedHistoryListFields();
		}
		$query = $this->getRelationQuery();

		if ($this->get('whereCondition')) {
			$query = $this->updateQueryWithWhereCondition($query);
		}

		$startIndex = $pagingModel->getStartIndex();
		$pageLimit = $pagingModel->getPageLimit();

		$orderBy = $this->getForSql('orderby');
		$sortOrder = $this->getForSql('sortorder');
		if($orderBy) {

            $orderByFieldModuleModel = $relationModule->getFieldByColumn($orderBy);
            if($orderByFieldModuleModel && $orderByFieldModuleModel->isReferenceField()) {
                //If reference field then we need to perform a join with crmentity with the related to field
                $queryComponents = $split = spliti(' where ', $query);
                $selectAndFromClause = $queryComponents[0];
                $whereCondition = $queryComponents[1];
                $qualifiedOrderBy = 'vtiger_crmentity'.$orderByFieldModuleModel->get('column');
                $selectAndFromClause .= ' LEFT JOIN vtiger_crmentity AS '.$qualifiedOrderBy.' ON '.
                                        $orderByFieldModuleModel->get('table').'.'.$orderByFieldModuleModel->get('column').' = '.
                                        $qualifiedOrderBy.'.crmid ';
                $query = $selectAndFromClause.' WHERE '.$whereCondition;
                $query .= ' ORDER BY '.$qualifiedOrderBy.'.label '.$sortOrder;
            } elseif($orderByFieldModuleModel && $orderByFieldModuleModel->isOwnerField()) {
				 $query .= ' ORDER BY CONCAT(vtiger_users.first_name, " ", vtiger_users.last_name) '.$sortOrder;
			} else{
                // Qualify the the column name with table to remove ambugity
                $qualifiedOrderBy = $orderBy;
                $orderByField = $relationModule->getFieldByColumn($orderBy);
                if ($orderByField) {
					$qualifiedOrderBy = $relationModule->getOrderBySql($qualifiedOrderBy);
				}
                $query = "$query ORDER BY $qualifiedOrderBy $sortOrder";
				}
			}

		$limitQuery = $query .' LIMIT '.$startIndex.','.$pageLimit;
		$result = $db->pquery($limitQuery, array());
		$relatedRecordList = array();
		for($i=0; $i< $db->num_rows($result); $i++ ) {
			$row = $db->fetch_row($result,$i);

			$newRow = array();
			foreach($row as $col=>$val){
				if(array_key_exists($col,$relatedColumnFields)){
                    $newRow[$relatedColumnFields[$col]] = $val;
                }
            }
			//To show the value of "Assigned to"
			$newRow['assigned_user_id'] = $row['smownerid'];
			$record = Vtiger_Record_Model::getCleanInstance($relationModule->get('name'));
            $record->setData($newRow)->setModuleFromInstance($relationModule);
            $record->setId($row['crmid']);
			$relatedRecordList[$row['crmid']] = $record;
		}
		$pagingModel->calculatePageRange($relatedRecordList);

		$nextLimitQuery = $query. ' LIMIT '.($startIndex+$pageLimit).' , 1';
		$nextPageLimitResult = $db->pquery($nextLimitQuery, array());
		if($db->num_rows($nextPageLimitResult) > 0){
			$pagingModel->set('nextPageExists', true);
		}else{
			$pagingModel->set('nextPageExists', false);
		}
		return $relatedRecordList;
	}
}