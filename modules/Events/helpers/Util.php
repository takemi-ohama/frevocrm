<?php
/*+***********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 *************************************************************************************/

class Events_Util_Helper extends Vtiger_Util_Helper {

	
	public static function copyCalendarRecord(Events_Record_Model $recordModel) {
		
		$invitees_ids = $recordModel->get("selectedusers");
		if($recordModel->get("mode") == "" && count($invitees_ids) > 0 ) {
			foreach($invitees_ids as $copy_user_id) {
				$copyRecordModel = Events_Record_Model::getCleanInstance("Events");
				foreach ($recordModel->getData() as $key => $value) {
					if($key == "id" || $key == "selectedusers" || $key == "assigned_user_id") {}
					else {
						$copyRecordModel->set($key,$value);
					}
				}

				$self_ids = array_merge($invitees_ids, array($recordModel->get("assigned_user_id")));
				foreach($self_ids as $key => $user_id) {
					if($user_id == $copy_user_id) {
						unset($self_ids[$key]);
						break;
					}
				}
				
				$copyRecordModel->set("assigned_user_id", $copy_user_id);
				$copyRecordModel->set("created_user_id", $copy_user_id);
				$_REQUEST['inviteesid'] = null;
				$copyRecordModel->save();
				
				$focus = CRMEntity::getInstance($copyRecordModel->getModuleName());
				$focus->mode = $copyRecordModel->get('mode');
				$focus->id = $copyRecordModel->getId();
				$focus->insertIntoInviteeTable($copyRecordModel->getModuleName(), $self_ids);

				//繰り返しスケジュールを複製する
				if($_REQUEST['recurringtype'] != '' && $_REQUEST['recurringtype'] != '--None--') {
					vimport('~~/modules/Calendar/RepeatEvents.php');
					$focus =  new Activity();
		
					//get all the stored data to this object
					$focus->column_fields = $copyRecordModel->getData();
		
					Calendar_RepeatEvents::repeatFromRequest($focus);
				}
				
				
				
			}
		}
	}
	
	/*
	 * 活動登録画面において、お客様と関連づいけて登録した場合は、活動にある締切日もしくは終了日の値をお客様の最終活動日を更新する。
	 * また関連モジュールの「案件、紹介会社・病院」に対する最終活動日も更新する。
	 * @params Vtiger_Request
	 */
	public static function updateLastActionDate($activityid, Vtiger_Request $request) {

		// 活動の予定を選択したときのみ、最終活動更新日を更新する
		if($request->get("eventstatus") == "Held") {
			$contactidlist = $request->get("contactidlist");
			$contactid = $request->get("contact_id");
			
			/*
			 * 活動詳細登録フォームの場合、お客様の担当者複数選択するときの最終更新日を更新する処理
			 */
			if(strlen($contactidlist) > 0 ) {
				$contactArray = explode(";", $contactidlist);
				foreach($contactArray as $contactid) {
					$recordContactModel = Vtiger_Record_Model::getInstanceById($contactid, "Contacts");
					$recordContactModel->set('id', $contactid);
					$recordContactModel->set('mode', 'edit');
					$recordContactModel->set('last_action_date', $request->get("due_date"));
					$accountid = $recordContactModel->get("account_id");
					if( $accountid > 0 ) {
						self::saveAccounts($accountid, $activityid, $request->get("due_date"));
					}
					$recordContactModel->save();
				}
			}
			/*
			 * 活動POPUP登録フォームの場合、お客様の担当者単一選択するときの最終更新日を更新する処理
			*/
			elseif( $contactid > 0 ) {
				$recordContactModel = Vtiger_Record_Model::getInstanceById($contactid, "Contacts");
				$recordContactModel->set('id', $contactid);
				$recordContactModel->set('mode', 'edit');
				$recordContactModel->set('last_action_date', $request->get("due_date"));
				$accountid = $recordContactModel->get("account_id");
				if( $accountid > 0 ) {
					self::saveAccounts($accountid, $activityid, $request->get("due_date"));
				}
				$recordContactModel->save();
			}

			// 関連モジュールの
			$parent_id = $request->get("parent_id");
			if($parent_id > 0 ) {
				$recordParentModel = Vtiger_Record_Model::getInstanceById($parent_id);
				$moduleName = $recordParentModel->getModuleName();
				if($moduleName == 'Leads' || $moduleName == "Accounts") {
					$recordParentModel->set('id', $parent_id);
					$recordParentModel->set('mode', 'edit');
					$recordParentModel->set('last_action_date', $request->get("due_date"));
					$recordParentModel->save();
				}
				elseif($moduleName == "Potentials") {
					$recordParentModel->set('id', $parent_id);
					$recordParentModel->set('mode', 'edit');
					$recordParentModel->set('last_action_date', $request->get("due_date"));
					$accountid = $recordParentModel->get("related_to");
					if( $accountid > 0 ) {
						self::saveAccounts($accountid, $activityid, $request->get("due_date"));
					}
					$recordParentModel->save();
				}
			}
		}
		
	}
	
	private static function saveAccounts($accountid, $activityid, $due_date) {
		$recordAccountModel = Vtiger_Record_Model::getInstanceById($accountid, "Accounts");
		$recordAccountModel->set('id', $accountid);
		$recordAccountModel->set('mode', 'edit');
		$recordAccountModel->set('last_action_date', $due_date);
		$recordAccountModel->save();
		
		$sourceModuleModel = Vtiger_Module_Model::getInstance("Accounts");
		$relatedModuleModel = Vtiger_Module_Model::getInstance("Calendar");
		$relationModel = Vtiger_Relation_Model::getInstance($sourceModuleModel, $relatedModuleModel);
		$relationModel->addRelation($accountid, $activityid);
	}

}