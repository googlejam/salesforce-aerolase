/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CustomTerritoryControllerWrapper {

    public static Map<String,String> accountToLeadFieldMap  = new Map<String, String>{
                                                    'BillingState' => 'State', 'BillingCountry' => 'Country', 
                                                    'BillingPostalCode' => 'PostalCode', 'Name' => 'Company',
                                                    'Second_Lead_Source__c' => 'Second_Lead_Source__c', 'BillingCity' => 'City'
                                                    };

    public static Map<String,String> operatorsMap  = new Map<String, String>{
        'equals' => ' ({a} == b ) ', 'notEqual' => ' ( {a} != b ) ', 
        'lessThan' => ' ( {a} < b ) ', 'greaterThan' => '( {a} > b ) ',
        'lessOrEqual' => ' ( {a} <= b ) ', 'greaterOrEqual' => ' ( {a} >= b ) ',
        'contains' => ' ( {a}.contains(b) ) ', 'notContain' => ' ( !({a}.contains(b)) ) ',
        'startsWith' => ' ( {a}.startsWith(b) ) ','includes' => ' ( {a}.includes(b) ) ',
        'excludes' => ' ( !({a}.includes(b)) ) ','within' => ' ({a} = b ) '
        };

    public static Map<String,String> filterOperatorMap  = new Map<String, String>{ 'OR' => ' || ', 'AND' => ' && ' };

    public class RuleWrapper{
        public String ruleId;
        public String ruleName;
        public String uniqueKey;
        public String territory2ModelId;
        public String territory2Id;
        public String BooleanFilter;
        public String expression;
        public String expressionWithRecordVal;
        public String ObjectType;
        public RuleTerritory2Association ruleTerritory2AssociationObj;
        public Set<String> fieldSet = new Set<String>();
        public Boolean ruleResult = false;
        public Map<String,Boolean> sortOrderToResultMap = new Map<String,Boolean>();
    }

    public class RelationshipTreeWrapper{
        public String uniqueKey;
        public String territory2Id;
        public String territory2Name;
        public String parentTerritory2Id;
        public String territory2TypeId;
        public String territory2ModelId;
        public String childTerritoryIds ='';
        public Boolean IsInherited = false;
        public List<RelationshipTreeWrapper> childTerritoryList = new List<RelationshipTreeWrapper>();
    }


}