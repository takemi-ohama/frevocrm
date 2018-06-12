<?php
/*+***********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 * ************************************************************************************/

class Dailyreports_Module_Model extends Vtiger_Module_Model {

	/**
	 * Function returns the Calendar Events for the module
	 * @param <String> $mode - upcoming/overdue mode
	 * @param <Vtiger_Paging_Model> $pagingModel - $pagingModel
	 * @param <String> $user - all/userid
	 * @param <String> $recordId - record id
	 * @return <Array>
	 */
	function getCalendarActivitiesHistory($mode, $pagingModel, $user, $reportsterm, $reportsdate) {
		$currentUser = Users_Record_Model::getCurrentUserModel();
		$db = PearDatabase::getInstance();

		if (isset($reportsterm) && $reportsterm == 'Week') {
			$w = date("w",strtotime($reportsdate));
			if($w == 0) {
				$begin = $w + 6;
				$end = $w;
			} else {
				$begin = $w - 1;
				$end = $w - 1 - 6;
			}
			$beginning_week_date =
				date('Y-m-d', strtotime("-{$begin} day", strtotime($reportsdate)));
			$ending_week_date =
				date('Y-m-d', strtotime("-{$end} day", strtotime($reportsdate)));
		} else {
			$beginning_week_date = $reportsdate;
			$ending_week_date = $reportsdate;
		}

		$nowInUserFormat = Vtiger_Datetime_UIType::getDisplayDateValue(date('Y-m-d H:i:s'));
		$nowInDBFormat = Vtiger_Datetime_UIType::getDBDateTimeValue($nowInUserFormat);
		list($currentDate, $currentTime) = explode(' ', $nowInDBFormat);

		$query = "SELECT vtiger_crmentity.crmid, vtiger_crmentity.smownerid, vtiger_crmentity.setype, vtiger_activity.* FROM vtiger_activity
					INNER JOIN vtiger_crmentity ON vtiger_crmentity.crmid = vtiger_activity.activityid
					left join vtiger_groups on vtiger_groups.groupid=vtiger_crmentity.smownerid
					left join vtiger_users on vtiger_users.id=vtiger_crmentity.smownerid
				WHERE (vtiger_activity.activitytype != 'Emails')
				AND
				(vtiger_activity.status = 'Completed' or vtiger_activity.status = 'Deferred' or (vtiger_activity.eventstatus = 'Held' and vtiger_activity.eventstatus != ''))
				AND
				vtiger_crmentity.deleted = 0
				AND
					date(vtiger_activity.date_start) >='" .$beginning_week_date."'
				AND
					date(vtiger_activity.date_start) <='" .$ending_week_date."'";

		$params = array();
		if($user != 'all' && $user != '') {
				$query .= " AND vtiger_crmentity.smownerid = ?";
				array_push($params, $user);
		}

		$query .= " ORDER BY date_start, time_start LIMIT ". $pagingModel->getStartIndex() .", ". ($pagingModel->getPageLimit()+1);


		if ($recordId) {
			array_push($params, $recordId);
		}

		$result = $db->pquery($query, $params);
		$numOfRows = $db->num_rows($result);

		$activities = array();
		for($i=0; $i<$numOfRows; $i++) {
			$row = $db->query_result_rowdata($result, $i);
			$model = Vtiger_Record_Model::getCleanInstance('Calendar');
			$model->setData($row);
			$model->setId($row['crmid']);
			$activities[] = $model;
		}

		$pagingModel->calculatePageRange($activities);
		if($numOfRows > $pagingModel->getPageLimit()){
			array_pop($activities);
			$pagingModel->set('nextPageExists', true);
		} else {
			$pagingModel->set('nextPageExists', false);
		}

		return $activities;
	}

}
