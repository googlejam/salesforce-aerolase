/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-13-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class CustomTerritoryController {
    public static List<CustomTerritoryControllerWrapper.RelationshipTreeWrapper> relationshipTreeList = new List<CustomTerritoryControllerWrapper.RelationshipTreeWrapper>();
    public static List<CustomTerritoryControllerWrapper.RuleWrapper> ruleWrapperList = new List<CustomTerritoryControllerWrapper.RuleWrapper>();
    public static List<ObjectTerritory2AssignmentRule> objectTerritory2AssignmentRuleList = new List<ObjectTerritory2AssignmentRule>();
    public static List<RuleTerritory2Association> ruleTerritory2AssociationList = new List<RuleTerritory2Association>();
    public static List<Territory2> territory2List = new List<Territory2>();
    public static List<ObjectTerritory2Association> insertAssignmentList = new List<ObjectTerritory2Association>();
    public static List<UserTerritory2Association> userTerritoryAsccList = new List<UserTerritory2Association>();
    public static Set<String> leadIdSet = new Set<String>();
    public static Map<String,List<String>> ruleAsccIdToRuleMap = new Map<String,List<String>>();
    public static Map<String,String> territoryIdToUserIdMap = new Map<String,String>();
	public static Boolean deleteCheck = false;

    public static Lead leadObj = new Lead();

    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-15-2023 
    **/
    public static void fetchRulesData() {
        objectTerritory2AssignmentRuleList = [SELECT Id,BooleanFilter, IsActive, MasterLabel, ObjectType, Territory2ModelId,Territory2Model.Name,Territory2Model.State, Territory2Model.DeveloperName,
                                            (SELECT Id,Operation, RuleId,SortOrder, Value,Field FROM ObjectTerritory2AssignmentRuleItems ORDER BY SortOrder ASC )
                                            FROM ObjectTerritory2AssignmentRule WHERE  IsActive = true WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];

        ruleTerritory2AssociationList = [SELECT Id,RuleId,Territory2.Name,IsInherited,Territory2Id FROM RuleTerritory2Association WHERE Territory2Id != null WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        territory2List = [ SELECT Id,ParentTerritory2Id, DeveloperName, Territory2TypeId, Territory2ModelId ,(SELECT Id,IsInherited FROM RuleTerritory2Associations ) FROM Territory2 WITH SECURITY_ENFORCED ORDER BY ParentTerritory2Id ];
        userTerritoryAsccList = [SELECT Id,UserId,Territory2Id FROM UserTerritory2Association WHERE IsActive = true WITH SECURITY_ENFORCED ];
        createRelationShipTree();
        createTerritoryToUserMap();

        
    }


    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-15-2023 
    **/
    public static void assignLead(Lead obj) {
        leadObj = obj;
        //System.debug('47 leadObj '+leadObj);
    }
    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-15-2023 
    **/
    public static void customTerritoryCalculation() {   
        //System.debug('55 leadObj '+leadObj);
        ruleBreakdown();
        //System.debug('57 leadObj '+leadObj);
        runEvaluation();
        //System.debug('58 leadObj '+leadObj);
	}




    /**
    * @description
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-16-2023
    **/
        public static void createRelationShipTree(){
        Map<String,List<Territory2>> parentToChildMap = new Map<String,List<Territory2>>();
        Map<String,Territory2> idToTerritoryRecMap = new Map<String,Territory2>();

        for(Territory2 territoryObj : territory2List){
            idToTerritoryRecMap.put(territoryObj.Id,territoryObj);
            if(territoryObj.ParentTerritory2Id != null && parentToChildMap.containsKey(territoryObj.ParentTerritory2Id) ){
                List<Territory2> tempTerritoryList = new List<Territory2>{territoryObj};
                tempTerritoryList.addAll(parentToChildMap.get(territoryObj.ParentTerritory2Id));
                parentToChildMap.put(territoryObj.ParentTerritory2Id,tempTerritoryList);
                parentToChildMap.put(territoryObj.Id,new List<Territory2>());
            }else{
                List<Territory2> tempTerritoryList = new List<Territory2>();
                parentToChildMap.put(territoryObj.Id,tempTerritoryList);
            }
        }


        for(String key : parentToChildMap.keySet() ){
            Territory2 territoryObj = idToTerritoryRecMap.get(key);
            CustomTerritoryControllerWrapper.RelationshipTreeWrapper relationshipTreeObj = new CustomTerritoryControllerWrapper.RelationshipTreeWrapper();
            relationshipTreeObj.territory2Id = territoryObj.Id;
            relationshipTreeObj.territory2Name = territoryObj.DeveloperName;
            relationshipTreeObj.uniqueKey = relationshipTreeObj.territory2Id+'-'+relationshipTreeObj.territory2Name;
            relationshipTreeObj.territory2TypeId = territoryObj.territory2TypeId != null ? territoryObj.territory2TypeId : '';
            relationshipTreeObj.territory2ModelId = territoryObj.Territory2ModelId != null ? territoryObj.Territory2ModelId : '';
            if(parentToChildMap.get(territoryObj.Id).isEmpty()){
                relationshipTreeList.add(relationshipTreeObj);
                continue;
            }
            for(RuleTerritory2Association territoryRuleTerritory2AssociationObj : territoryObj.RuleTerritory2Associations ){
                relationshipTreeObj.IsInherited = territoryRuleTerritory2AssociationObj.IsInherited;
            }

            for(Territory2 childTerritoryObj : parentToChildMap.get(territoryObj.Id) ){
                CustomTerritoryControllerWrapper.RelationshipTreeWrapper childRelationshipTreeObj = new CustomTerritoryControllerWrapper.RelationshipTreeWrapper();
                relationshipTreeObj.childTerritoryIds += ';'+childTerritoryObj.Id;
                childRelationshipTreeObj.territory2Id = childTerritoryObj.Id;
                childRelationshipTreeObj.territory2Name = childTerritoryObj.DeveloperName;
                childRelationshipTreeObj.uniqueKey = childRelationshipTreeObj.territory2Id+'-'+childRelationshipTreeObj.territory2Name;
                childRelationshipTreeObj.parentTerritory2Id = childTerritoryObj.ParentTerritory2Id != null ? childTerritoryObj.ParentTerritory2Id : '';
                childRelationshipTreeObj.territory2TypeId = childTerritoryObj.territory2TypeId != null ? childTerritoryObj.territory2TypeId : '';
                childRelationshipTreeObj.territory2ModelId = childTerritoryObj.Territory2ModelId != null ? childTerritoryObj.Territory2ModelId : '';
                for(RuleTerritory2Association territoryRuleTerritory2AssociationObj : childTerritoryObj.RuleTerritory2Associations ){
                    childRelationshipTreeObj.IsInherited = territoryRuleTerritory2AssociationObj.IsInherited;
                }
                relationshipTreeObj.childTerritoryList.add(childRelationshipTreeObj);
            }
            
            relationshipTreeList.add(relationshipTreeObj);


    }
}


    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 07-02-2023 
    **/
    public static void createTerritoryToUserMap(){
        for(UserTerritory2Association userTrrObj : userTerritoryAsccList){
            territoryIdToUserIdMap.put(userTrrObj.Territory2Id,userTrrObj.UserId);
        }
    }

    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-15-2023 
    **/
    public static void ruleBreakdown() {
       
        Map<String,RuleTerritory2Association> ruleIdToRuleAssociationMap = new Map<String,RuleTerritory2Association>();
        for(RuleTerritory2Association ruleAsccObj : ruleTerritory2AssociationList){
            ruleIdToRuleAssociationMap.put(ruleAsccObj.RuleId,ruleAsccObj);
            if(ruleAsccIdToRuleMap.containsKey(ruleAsccObj.Id)){
                List<String> tempRuleIdList = new List<String>{ruleAsccObj.RuleId};
                tempRuleIdList.addAll(ruleAsccIdToRuleMap.get(ruleAsccObj.Id));
                ruleAsccIdToRuleMap.put(ruleAsccObj.Id,tempRuleIdList);
            }else{
                List<String> tempRuleIdList = new List<String>{ruleAsccObj.RuleId};
                ruleAsccIdToRuleMap.put(ruleAsccObj.Id,tempRuleIdList);
            }
        }        

        for(ObjectTerritory2AssignmentRule ruleObj : objectTerritory2AssignmentRuleList){
            CustomTerritoryControllerWrapper.RuleWrapper ruleWrapperObj = new CustomTerritoryControllerWrapper.RuleWrapper();
            ruleWrapperObj.ruleId = ruleObj.Id;
            ruleWrapperObj.ruleName = ruleObj.MasterLabel;
            ruleWrapperObj.ObjectType = ruleObj.ObjectType;
            ruleWrapperObj.territory2ModelId = ruleObj.Territory2ModelId;
            ruleWrapperObj.territory2Id = ruleIdToRuleAssociationMap.containsKey(ruleWrapperObj.ruleId) ? ruleIdToRuleAssociationMap.get(ruleWrapperObj.ruleId).Territory2Id : null;
            ruleWrapperObj.ruleTerritory2AssociationObj = ruleIdToRuleAssociationMap.containsKey(ruleWrapperObj.ruleId) ? ruleIdToRuleAssociationMap.get(ruleWrapperObj.ruleId) : null;
            String tempBooleanFilter = '';
            for(ObjectTerritory2AssignmentRuleItem ruleItemObj : ruleObj.ObjectTerritory2AssignmentRuleItems){
                tempBooleanFilter += String.ValueOf(ruleItemObj.SortOrder)+' AND ';
                String onlyFieldRemoveKey = ruleWrapperObj.ObjectType+'.';
                String onlyField = ruleItemObj.Field.remove(onlyFieldRemoveKey);
                ruleWrapperObj.fieldSet.add(onlyField);
            }
            tempBooleanFilter = tempBooleanFilter.removeEnd(' AND ');
            ruleWrapperObj.BooleanFilter = ruleObj.BooleanFilter != null ? ruleObj.BooleanFilter : tempBooleanFilter;
            ruleWrapperObj.expression = ruleWrapperObj.BooleanFilter;
            ruleWrapperObj.expressionWithRecordVal  = ruleWrapperObj.BooleanFilter;
            for(ObjectTerritory2AssignmentRuleItem ruleItemObj : ruleObj.ObjectTerritory2AssignmentRuleItems){
                if( ruleItemObj.Field == null || ruleItemObj.Operation == null){
                    continue;
                } 
                String tempVal = String.isNotBlank(ruleItemObj.Value) ? ruleItemObj.Value : '';
                
                String tempExpression = CustomTerritoryControllerWrapper.operatorsMap.get(ruleItemObj.Operation);
                if(tempExpression == null){
                    continue;
                }
                tempExpression = tempExpression.replace('a', ruleItemObj.Field);
                tempExpression = tempExpression.replace('b', tempVal);
                ruleWrapperObj.expression = ruleWrapperObj.expression.replace(String.ValueOf(ruleItemObj.SortOrder),tempExpression);

                String onlyFieldRemoveKey = ruleWrapperObj.ObjectType+'.';
                String onlyField = ruleItemObj.Field.remove(onlyFieldRemoveKey);

                //For Account
                //String val = String.valueOf(acc.get(onlyField));
                //System.debug('leadObj '+leadObj);
				//System.debug('onlyField '+onlyField);
                //System.debug('CustomTerritoryControllerWrapper.accountToLeadFieldMap.containsKey(onlyField) '+CustomTerritoryControllerWrapper.accountToLeadFieldMap.containsKey(onlyField));
                //System.debug('String.valueOf(leadObj.get(CustomTerritoryControllerWrapper.accountToLeadFieldMap.get(onlyField))) '+String.valueOf(leadObj.get(CustomTerritoryControllerWrapper.accountToLeadFieldMap.get(onlyField))));
                ////System.debug('String.valueOf(leadObj.get(onlyField) '+String.valueOf(leadObj.get(onlyField)));


                //For Lead
                String val =  CustomTerritoryControllerWrapper.accountToLeadFieldMap.containsKey(onlyField) ?  String.valueOf(leadObj.get(CustomTerritoryControllerWrapper.accountToLeadFieldMap.get(onlyField))) : String.valueOf(leadObj.get(onlyField));

                if(String.isBlank(val)){
                    ruleWrapperObj.ruleResult = false;
                }
                // System.debug('ruleObj '+ruleObj);
                // System.debug('ruleObj.Id '+ruleObj.Id);
              	// System.debug('ruleObj.MasterLabel '+ruleObj.MasterLabel);
                // System.debug('ruleWrapperObj.expression '+ruleWrapperObj.expression);
                // System.debug('ruleWrapperObj '+ruleWrapperObj);
                // System.debug('val '+val);
                // System.debug('ruleItemObj.Value '+ruleItemObj.Value);
                // System.debug('ruleItemObj.Operation '+ruleItemObj.Operation);

                Boolean tempRuleResult= evaluateExpression(val,tempVal,ruleItemObj.Operation);
               
                // System.debug('tempRuleResult '+tempRuleResult);
                ruleWrapperObj.sortOrderToResultMap.put(String.ValueOf(ruleItemObj.SortOrder),tempRuleResult);
                ruleWrapperObj.expressionWithRecordVal = ruleWrapperObj.expressionWithRecordVal.replace(String.ValueOf(ruleItemObj.SortOrder),String.valueOf(tempRuleResult));
				// System.debug('217 ruleWrapperObj.sortOrderToResultMap '+ruleWrapperObj.sortOrderToResultMap);
                // System.debug('217 ruleWrapperObj.expressionWithRecordVal '+ruleWrapperObj.expressionWithRecordVal);
             
            }
            ruleWrapperList.add(ruleWrapperObj);
        }

	}

    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-15-2023 
    * @param val1 
    * @param val2 
    * @param operation 
    * @return Boolean 
    **/
    public static Boolean evaluateExpression(String val1,String val2,String operation) {
        // System.debug('val1 '+val1);
        // System.debug('val2 '+val2);
        // System.debug('operation '+operation);
        Boolean result = false;

        if(String.isBlank(val1) || String.isBlank(val2) || String.isBlank(operation) ){
            return result;
        }
        if(operation == 'equals' && ( !val2.contains(',') && !val2.contains(';') ) ){
            result = (val1 == val2);
        }else if(operation == 'notEqual' && ( !val2.contains(',') && !val2.contains(';') ) ){
            result = (val1 != val2);
        }else if(operation == 'lessThan'){
            result = (val1 < val2);
        }else if(operation == 'greaterThan'){
            result = (val1 > val2);
        }else if(operation  == 'lessOrEqual'){
            result = (val1 <= val2);
        }else if(operation == 'greaterOrEqual'){
            result = (val1 >= val2);
        }else if(operation == 'contains' ){
            result = ( val2.contains(val1) );
        }else if(( operation == 'equals' &&  (val2.contains(',')) )){  
            //result = ( val2.contains(val1+',') );
            result = false;
            for(String text : val2.split(',')){
                if(val1 == text){
                    result = true;
                    break;
                }
            }
        }else if(( operation == 'equals' &&  (val2.contains(';')) )){ 
            //result = ( val2.contains(val1+';') );
            result = false;
            for(String text : val2.split(';')){
                if(val1 == text){
                    result = true;
                    break;
                }
            }
        }
        else if(operation == 'notContain'  ){
            result = ( !val2.contains(val1) );
        }else if(( operation == 'notEqual' &&  (val2.contains(',')) )){  
            //result = ( !val2.contains(val1+',') );
            result = true;
            for(String text : val2.split(',')){
                if(val1 == text){
                    result = false;
                    break;
                }
            }
        }else if(( operation == 'notEqual' &&  (val2.contains(';')) )){ 
            //result = ( !val2.contains(val1+';') );
            result = true;
            for(String text : val2.split(';')){
                if(val1 == text){
                    result = false;
                    break;
                }
            }
        }else if(operation == 'startsWith'){
            result = ( val1.startsWithIgnoreCase(val2) );
        }else if(operation == 'includes'){
            result = ( val2.contains(val1) );
        }else if(operation == 'excludes'){
            result = ( !val2.contains(val1) );
        }else if(operation == 'within'){
            result = ( val2.contains(val1) );
        }

        // System.debug('result '+result);
        return result;
	}

    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-15-2023 
    **/
    public static void runEvaluation() {
		//System.debug('315');       
        for(CustomTerritoryControllerWrapper.RuleWrapper ruleWrapperObj :ruleWrapperList){
            //System.debug('ruleWrapperObj'+ruleWrapperObj);
            //System.debug('ruleWrapperObj.ruleName'+ruleWrapperObj.ruleName);
            //System.debug('ruleWrapperObj.expressionWithRecordVal'+ruleWrapperObj.expressionWithRecordVal);
            Boolean result = false;
            Integer counter = 0;
            String operator = '';
            Boolean val1 = false;
            Boolean val2 = false;
            List<String> expList = ruleWrapperObj.expressionWithRecordVal.split(' ');
            if(expList.size() == 1){
                result = Boolean.valueOf(expList[0]);
                ruleWrapperObj.ruleResult = result;
                continue;
            }
            /*for( String exp : expList){
                exp = exp.trim();
                counter++;

                if(exp == 'true'){
                    if(counter == 1){
                        val1 = true;
                    }else if(counter == 3){
                        val2 = true;
                    }
                }else if(exp == 'false'){
                    //result = false;
                    if(counter == 1){
                        val1 = false;
                    }else if(counter == 3){
                        val2 = false;
                    }
                }else{
                    operator = exp;
                }

                if(counter == 3){
                    if(operator == 'AND'){
                        result = val1 && val2 ;
                    }else if(operator == 'OR'){
                        result = val1 || val2 ;
                    }

                    val1 = false;
                    val2 = false;
                    operator = '';
                    counter = 0;
                }
            }

            ruleWrapperObj.ruleResult = result;
            // System.debug('ruleWrapperObj.ruleResult'+ruleWrapperObj.ruleResult); */
            ruleWrapperObj.ruleResult = evaluate(ruleWrapperObj.expressionWithRecordVal);

        }
		// System.debug('367');     
	}
    
    //New Code to evaluate- start
    public static Boolean evaluate(String expression) {
        expression = expression.replaceAll(' ', ''); // Remove spaces
        expression = expression.replaceAll('true', '1'); // Replace 'true' with '1'
        expression = expression.replaceAll('false', '0'); // Replace 'false' with '0'
        expression = '(' + expression + ')'; // Add parentheses to the expression

        while (expression.contains('(')) {
            Integer startIndex = expression.lastIndexOf('(');
            Integer endIndex = expression.indexOf(')', startIndex);
            String subExpression = expression.substring(startIndex + 1, endIndex);
            String subResult = evaluateSubExpression(subExpression);
            expression = expression.replace('(' + subExpression + ')', subResult);
        }

        return evaluateSubExpression(expression) == '1';
    }

    private static String evaluateSubExpression(String expression) {
        while (expression.contains('AND')) {
            Integer andIndex = expression.indexOf('AND');
            Integer leftIndex = andIndex - 1;
            Integer rightIndex = andIndex + 3;
            String leftOperand = expression.substring(leftIndex, leftIndex + 1);
            String rightOperand = expression.substring(rightIndex, rightIndex + 1);
            String result = (leftOperand.equals('1') && rightOperand.equals('1')) ? '1' : '0';
            expression = expression.replace(leftOperand + 'AND' + rightOperand, result);
        }

        while (expression.contains('OR')) {
            Integer orIndex = expression.indexOf('OR');
            Integer leftIndex = orIndex - 1;
            Integer rightIndex = orIndex + 2;
            String leftOperand = expression.substring(leftIndex, leftIndex + 1);
            String rightOperand = expression.substring(rightIndex, rightIndex + 1);
            String result = (leftOperand.equals('1') || rightOperand.equals('1')) ? '1' : '0';
            expression = expression.replace(leftOperand + 'OR' + rightOperand, result);
        }

        return expression;
    }
    //New Code to evaluate- end

    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-15-2023 
    **/
    public static void assigneInsertTerritoryRec() {
        Set<String> doNoAddSet = new Set<String>();
        for(CustomTerritoryControllerWrapper.RuleWrapper ruleWrapperObj :ruleWrapperList){
            if(!ruleWrapperObj.ruleResult || (String.isBlank(ruleWrapperObj.territory2Id) )){
                continue;
            }
            for(CustomTerritoryControllerWrapper.RelationshipTreeWrapper relationshipTreeObj : relationshipTreeList){
                if(relationshipTreeObj.IsInherited && relationshipTreeObj.childTerritoryIds.contains(ruleWrapperObj.ruleTerritory2AssociationObj.Territory2Id)){
                    doNoAddSet.add(relationshipTreeObj.territory2Id);
                }
            }
        }
        // System.debug('doNoAddSet '+doNoAddSet);
        for(CustomTerritoryControllerWrapper.RuleWrapper ruleWrapperObj :ruleWrapperList){
            ObjectTerritory2Association insertAssignmentObj = new ObjectTerritory2Association();
            if(!ruleWrapperObj.ruleResult || (String.isBlank(ruleWrapperObj.territory2Id) )){
                continue;
            }
            if(doNoAddSet.contains(ruleWrapperObj.territory2Id)){
                continue;
            }
            insertAssignmentObj.ObjectId = leadObj.Id;
            insertAssignmentObj.Territory2Id = ruleWrapperObj.territory2Id;
            insertAssignmentObj.AssociationCause = 'Territory2Manual';
            insertAssignmentList.add(insertAssignmentObj);
            leadIdSet.add(leadObj.Id);
        }
        
        ruleWrapperList.clear();
        
        //  System.debug('insertAssignmentList '+insertAssignmentList);
    }

    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-15-2023 
    **/
    public static void insertAssignedTerritory() {
        List<ObjectTerritory2Association> existingAssignmentList = new List<ObjectTerritory2Association>();
        List<ObjectTerritory2Association> insertAssignmentUpdatedList = new List<ObjectTerritory2Association>();
        List<ObjectTerritory2Association> deleteAssignmentList = new List<ObjectTerritory2Association>();
        Set<String> existingTerritory2IdSet = new Set<String>();
        Set<String> calculatedTerritory2IdSet = new Set<String>();
        if(leadIdSet.isEmpty()){
            return;
        }
        existingAssignmentList = [SELECT Id,AssociationCause, ObjectId,SobjectType, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId IN:leadIdSet WITH SECURITY_ENFORCED ];
		
        for(ObjectTerritory2Association assignmentObj : existingAssignmentList){
            String key = assignmentObj.Territory2Id+'-'+assignmentObj.ObjectId;
            existingTerritory2IdSet.add(key);
        }
        Set<string> keySet = new Set<string>();

        for(ObjectTerritory2Association assignmentObj : insertAssignmentList){
            String key = assignmentObj.Territory2Id+'-'+assignmentObj.ObjectId;
            calculatedTerritory2IdSet.add(key);
            if(existingTerritory2IdSet.contains(key) || (!keySet.isEmpty() && keySet.contains(key)) ){
                continue;
            }
            keySet.add(key);
            insertAssignmentUpdatedList.add(assignmentObj);
        }
		deleteAssignmentList.clear();
        for(ObjectTerritory2Association assignmentObj : existingAssignmentList){
            String key = assignmentObj.Territory2Id+'-'+assignmentObj.ObjectId;
            if(calculatedTerritory2IdSet.contains(key)){
                continue;
            }
            deleteAssignmentList.add(assignmentObj);
        }

        if(!insertAssignmentUpdatedList.isEmpty()){
            insert insertAssignmentUpdatedList;
            updateLeadOwner(insertAssignmentUpdatedList);
        }
      
        if(!deleteAssignmentList.isEmpty() && deleteCheck){
            delete deleteAssignmentList;
            deleteCheck = false;
        }
        //System.debug('insertAssignmentUpdatedList '+insertAssignmentUpdatedList);
        existingTerritory2IdSet.clear();
        insertAssignmentList.clear();
        leadIdSet.clear();
        deleteAssignmentList.clear();
    }

    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06-15-2023 
    **/
    public static void updateLeadOwner( List<ObjectTerritory2Association> insertAssignmentUpdatedList ) {
        List<Lead> updatedLead = new  List<Lead>();
		Set<id> idSet = new Set<id>();
        for(ObjectTerritory2Association assignmentObj : insertAssignmentUpdatedList){
            if(!territoryIdToUserIdMap.containsKey(assignmentObj.Territory2Id)){
                continue;
            }
            if(!idSet.isEmpty() && idSet.contains(leadObj.Id)){
                continue;
            }
            Lead tempLead = new Lead();
            tempLead.Id = leadObj.Id;
            tempLead.OwnerId = territoryIdToUserIdMap.get(assignmentObj.Territory2Id);
            updatedLead.add(tempLead);
            idSet.add(leadObj.Id);
        }

        update updatedLead;
    }

}