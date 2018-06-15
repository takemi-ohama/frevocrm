<?php
/**
 * Created by PhpStorm.
 * User: thinkingreed
 * Date: 2017/03/30
 * Time: 17:09
 */
Class Calendar_PopupUserSelect_View extends Calendar_ViewTypes_View{
    function __construct() {

        $this->exposeMethod('userSelect');
    }
    function userSelect(Vtiger_Request $request){
        $viewer = $this->getViewer($request);
        $currentUser = Users_Record_Model::getCurrentUserModel();

        $moduleName = $request->getModule();
        $sharedUsers = Calendar_Module_Model::getSharedUsersOfCurrentUser($currentUser->id);
        $sharedUsersInfo = Calendar_Module_Model::getSharedUsersInfoOfCurrentUser($currentUser->id);

        $viewer->assign('MODULE', $moduleName);
        $viewer->assign('SHAREDUSERS', $sharedUsers);
        $viewer->assign('SHAREDUSERS_INFO', $sharedUsersInfo);
        $viewer->assign('CURRENTUSER_MODEL',$currentUser);
        $viewer->view('PopupUserSelect.tpl', $moduleName);
    }
}