<?php
/*+**********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 ************************************************************************************/

class Calendar_MobileList_View extends Vtiger_List_View  {
    /*
     * Function to search whether a multi-level $array has $key
     */
    public function findKey($array, $keySearch){
        foreach ($array as $key => $item) {
            if ($item === $keySearch) {
                return true;
            }
            else {
                if (is_array($item) && $this->findKey($item, $keySearch)) {
                    return true;
                }
            }
        }
        return false;
    }
    function replaceKey($array, $data){
        foreach ($array as $key => $item) {
            if ($item === $data[0]) {
                $array = $data;
                return $array;
            }
            else {
                if (is_array($item)) {
                    $array[$key] = $this->replaceKey($item, $data);
                }
                return $array;
            }
        }
        return $array;
    }
    public function insertSearchParams($array,$data){
        if($this->findKey($array,$data[0])){
            $array = $this->replaceKey($array,$data);
        }
        else{
            $array[0][] = $data;
        }
        return $array;
    }
    /*
     * Function to initialize the required data in smarty to display the List View Contents
     */
    public function initializeListViewContents(Vtiger_Request $request, Vtiger_Viewer $viewer) {
        $moduleName = $request->getModule();
        $cvId = $this->viewName;
        $filterlist = $this->viewer->tpl_vars['CUSTOM_VIEWS']->value;
        foreach($filterlist as $myfilter){
            foreach ($myfilter as $filter){
                if($filter->get('viewname') == "All"){
                    $cvId = $filter->get('cvid');
                }
            }
        }
        $pageNumber = $request->get('page');
        $orderBy = $request->get('orderby');
        $sortOrder = $request->get('sortorder');
        if($sortOrder == "ASC"){
            $nextSortOrder = "DESC";
            $sortImage = "icon-chevron-down";
        }else{
            $nextSortOrder = "ASC";
            $sortImage = "icon-chevron-up";
        }

        if(empty ($pageNumber)){
            $pageNumber = '1';
        }
	$cvId = -100;
        $listViewModel = Calendar_ListView_Model::getInstance($moduleName, $cvId);
        $currentUser = Users_Record_Model::getCurrentUserModel();

        $linkParams = array('MODULE'=>$moduleName, 'ACTION'=>$request->get('view'), 'CVID'=>$cvId);
        $linkModels = $listViewModel->getListViewMassActions($linkParams);

        $pagingModel = new Vtiger_Paging_Model();
        $pagingModel->set('page', $pageNumber);
        $pagingModel->set('viewid', $cvId);
        $orderBy = 'date_start';
        $sortOrder= 'ASC';
        if(!empty($orderBy)) {
            $listViewModel->set('orderby', $orderBy);
            $listViewModel->set('sortorder',$sortOrder);
        }

        $searchKey = $request->get('search_key');
        $searchValue = $request->get('search_value');
        $operator = $request->get('operator');
        if(!empty($operator)) {
            $listViewModel->set('operator', $operator);
            $viewer->assign('OPERATOR',$operator);
            $viewer->assign('ALPHABET_VALUE',$searchValue);
        }
        if(!empty($searchKey) && !empty($searchValue)) {
            $listViewModel->set('search_key', $searchKey);
            $listViewModel->set('search_value', $searchValue);
        }

        $searchParmams = $request->get('search_params');
        $rangeParmams = $request->get('range');

        if(empty($searchParmams)) {
            $today = new DateTime();
            $todayUser = $today->format('Y-m-d');
            $searchParmams = array(array(array('due_date','bw',$todayUser.' 00:00,'.$todayUser.' 23:59')));
        }
        if (!$this->findKey($searchParmams,'due_date')){
            $today = new DateTime();
            $todayUser = $today->format('Y-m-d');
            $tempParmams = array('due_date','bw',$todayUser.' 00:00,'.$todayUser.' 23:59');
            $searchParmams = $this->insertSearchParams($searchParmams,$tempParmams);
//            echo("<pre>");print_r($searchParmams);die;
        }
        if (!$this->findKey($searchParmams,'assigned_user_id')){
            $tempParmams = array('assigned_user_id','e',$currentUser->getDisplayName());
            $searchParmams = $this->insertSearchParams($searchParmams,$tempParmams);
        }
        if(empty($rangeParmams)){
            $rangeParmams = 1;
        }
        foreach ($searchParmams[0] as $searchParmam){
            //echo("<pre>");print_r($searchParmam);die;
            if($searchParmam[0] === 'due_date'){
                $searchParamsStartDate = explode(',',$searchParmam[2]);
            }
            elseif($searchParmam[0] === 'assigned_user_id'){
                $searchParamsUserList = explode(',',$searchParmam[2]);
            }
        }


        //echo("<pre>");print_r($searchParmams);die;
        $transformedSearchParams = $this->transferListSearchParamsToFilterCondition($searchParmams, $listViewModel->getModule());
        $listViewModel->set('search_params',$transformedSearchParams);


        //To make smarty to get the details easily accesible
        foreach($searchParmams as $fieldListGroup){
            foreach($fieldListGroup as $fieldSearchInfo){
                $fieldSearchInfo['searchValue'] = $fieldSearchInfo[2];
                $fieldSearchInfo['fieldName'] = $fieldName = $fieldSearchInfo[0];
                $searchParmams[$fieldName] = $fieldSearchInfo;
            }
        }


        if(!$this->listViewHeaders){
            $this->listViewHeaders = $listViewModel->getListViewHeaders();
        }
        $LISTVIEW_HEADERS =  $this->listViewHeaders;
        foreach($LISTVIEW_HEADERS as $LISTVIEW_HEADER){
            if($LISTVIEW_HEADER->get('column') == 'due_date'){
                $dueDateHeader = $LISTVIEW_HEADER;
            }
            else if($LISTVIEW_HEADER->get('column') == 'date_start'){
                $startDateHeader = $LISTVIEW_HEADER;
            }
            else if($LISTVIEW_HEADER->get('column') == 'sownerid'){
                $sownerHeader = $LISTVIEW_HEADER;
            }
            else if($LISTVIEW_HEADER->get('column') == 'subject'){
                $subjectHeader = $LISTVIEW_HEADER;
            }
        }

        if(!$this->listViewEntries){
            $this->listViewEntries = $listViewModel->getListViewEntries($pagingModel);
        }

        $noOfEntries = count($this->listViewEntries);
        $LISTVIEW_ENTRIES =  $this->listViewEntries;
        //print_r($LISTVIEW_ENTRIES);die;
        foreach ($LISTVIEW_ENTRIES as $LISTVIEWENTRY){
//            $datetime2=explode(' ',$LISTVIEWENTRY->get('date_start'));
//            print_r($datetime2[0]);
//            echo("<br>");
//            print_r($datetime2[1].$datetime2[2]);
//            echo("<br>");
            $startDate = $LISTVIEWENTRY->get('date_start');
            $newStartDate = new DateTime($startDate);
            $LISTVIEWENTRY->set('start_datetime',$newStartDate->format('m-d H:i'));
            //$dueDate = $LISTVIEWENTRY->get('due_date');
            $RAWDATA= $LISTVIEWENTRY->getRawData();

            $dueDate = $RAWDATA['due_date']." ".$RAWDATA['time_end'];
            $newDueDate = new DateTime($dueDate);
           //echo("<pre>");print_r($RAWDATA);die;
            $LISTVIEWENTRY->set('due_datetime',$newDueDate->format('m-d H:i'));
//            print_r($LISTVIEWENTRY->get('date_starttime'));
//            $newDateTime = explode(' ',$newDate->format('m-d H:i'));
//            print_r($newDateTime[0]);
//            echo("<br>");
//            print_r($newDateTime[1]);
//            echo("<br>");
        }

        $viewer->assign('MODULE', $moduleName);

        if(!$this->listViewLinks){
            $this->listViewLinks = $listViewModel->getListViewLinks($linkParams);
        }
        $viewer->assign('LISTVIEW_LINKS', $this->listViewLinks);

        $viewer->assign('LISTVIEW_MASSACTIONS', $linkModels['LISTVIEWMASSACTION']);

        $viewer->assign('PAGING_MODEL', $pagingModel);
        $viewer->assign('PAGE_NUMBER',$pageNumber);

        $viewer->assign('ORDER_BY',$orderBy);
        $viewer->assign('SORT_ORDER',$sortOrder);
        $viewer->assign('NEXT_SORT_ORDER',$nextSortOrder);
        $viewer->assign('SORT_IMAGE',$sortImage);
        $viewer->assign('COLUMN_NAME',$orderBy);
        $viewer->assign('START_DATE',$searchParamsStartDate[0]);
        $viewer->assign('RANGE',$rangeParmams);
        $viewer->assign('USERS',$searchParamsUserList);

        $viewer->assign('LISTVIEW_ENTRIES_COUNT',$noOfEntries);
        $viewer->assign('LISTVIEW_HEADERS', $this->listViewHeaders);
        $viewer->assign('LISTVIEW_DUEDATE_HEADERS', $dueDateHeader);
        $viewer->assign('LISTVIEW_STARTDATE_HEADERS', $startDateHeader);
        $viewer->assign('LISTVIEW_SUBJECT_HEADERS', $subjectHeader);
        $viewer->assign('LISTVIEW_ASSIGN_HEADERS', $sownerHeader);
        $viewer->assign('LISTVIEW_ENTRIES', $this->listViewEntries);

        //if (PerformancePrefs::getBoolean('LISTVIEW_COMPUTE_PAGE_COUNT', false)) {
            if(!$this->listViewCount){
                $this->listViewCount = $listViewModel->getListViewCount();
            }
            $totalCount = $this->listViewCount;

            $pageLimit = $pagingModel->getPageLimit();
            $pageCount = ceil((int) $totalCount / (int) $pageLimit);

            if($pageCount == 0){
                $pageCount = 1;
            }
            $viewer->assign('PAGE_COUNT', $pageCount);
            $viewer->assign('LISTVIEW_COUNT', $totalCount);
        //}

        $viewer->assign('LIST_VIEW_MODEL', $listViewModel);
        $viewer->assign('GROUPS_IDS', Vtiger_Util_Helper::getGroupsIdsForUsers($currentUser->getId()));
        $viewer->assign('IS_MODULE_EDITABLE', $listViewModel->getModule()->isPermitted('EditView'));
        $viewer->assign('IS_MODULE_DELETABLE', $listViewModel->getModule()->isPermitted('Delete'));
        $viewer->assign('SEARCH_DETAILS', $searchParmams);
    }

    /**
     * Function returns the number of records for the current filter
     * @param Vtiger_Request $request
     */
    function getRecordsCount(Vtiger_Request $request) {
        $moduleName = $request->getModule();
        $cvId = $request->get('viewname');
        $count = $this->getListViewCount($request);

        $result = array();
        $result['module'] = $moduleName;
        $result['viewname'] = $cvId;
        $result['count'] = $count;

        $response = new Vtiger_Response();
        $response->setEmitType(Vtiger_Response::$EMIT_JSON);
        $response->setResult($result);
        $response->emit();
    }

    /**
     * Function to get listView count
     * @param Vtiger_Request $request
     */
    function getListViewCount(Vtiger_Request $request){
        $moduleName = $request->getModule();
        $cvId = $request->get('viewname');
        if(empty($cvId)) {
            $cvId = '0';
        }

        $searchKey = $request->get('search_key');
        $searchValue = $request->get('search_value');

        $listViewModel = Vtiger_ListView_Model::getInstance($moduleName, $cvId);

        $searchParmams = $request->get('search_params');
        $listViewModel->set('search_params',$this->transferListSearchParamsToFilterCondition($searchParmams, $listViewModel->getModule()));

        $listViewModel->set('search_key', $searchKey);
        $listViewModel->set('search_value', $searchValue);
        $listViewModel->set('operator', $request->get('operator'));

        $count = $listViewModel->getListViewCount();

        return $count;
    }
}