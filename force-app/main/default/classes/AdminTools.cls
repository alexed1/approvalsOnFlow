global with sharing class AdminTools {

	
	@AuraEnabled(cacheable=true)
	global static String doSOSL(String searchString, String objectType){
		//Bobby Tables says always sanitize your inputs.
		searchString = String.escapeSingleQuotes(searchString);
		objectType = String.escapeSingleQuotes(objectType);
		System.debug('search string is: ' + searchString);

		//check CRUD/FLS
		//what object is this?
		Schema.DescribeSObjectResult describe = Schema.getGlobalDescribe().get(objectType).getDescribe();
		//can I query?
		if (!describe.isQueryable() || !describe.isAccessible()){
			throw new AuraHandledException(Label.LackingPermissions);
		}

		Map<String, Schema.SObjectField> fieldMap = describe.fields.getMap();
		for (Schema.SObjectField field:fieldMap.values()){
			if (field.getDescribe().isNameField()){
				if (!field.getDescribe().isAccessible()){
					throw new AuraHandledException(Label.LackingPermissions);
				}
			}
		}

		// limit rows returned for performance reasons
		String sosl = 'FIND \'*' + searchString + '*\' IN NAME FIELDS RETURNING ' + getReturning(objectType) + ' limit 200';
		list<list<sobject>> results = search.query(sosl);

		list<sObject> output = new list<sobject>();
		for (list<sObject> result:results){
			output.addAll(result);
		}

		return JSON.serialize(output);
	}

	@TestVisible
	public static String getReturning (String objectType){
		//assert that we can use these fields as the current user
		if (!User.Id.getDescribe().isAccessible() ||
			  !User.Name.getDescribe().isAccessible() ||
			  !User.UserType.getDescribe().isAccessible() ||
			  !Group.Id.getDescribe().isAccessible() ||
			  !Group.Name.getDescribe().isAccessible()
			){
			throw new AuraHandledException(Label.LackingPermissions);
		}


		//filter out user types that don't have sharing!
		if (objectType == 'User'){
			return 'User(Id, Name, UserType WHERE UserType in (\'Standard\', \'PowerCustomerSuccess\', \'PowerPartner\'))';
		}
		if (objectType == 'Group'){
			return objectType + '(Id, Name, Type)';
		} else {
			return objectType + '(Id, Name)';
		}
	}

global static String objectTypeFromId(Id recordId){
	Schema.SObjectType token = recordId.getSObjectType();
	Schema.DescribeSObjectResult dr = token.getDescribe();
	return dr.getName();
}


	private static boolean isStandard (String sobj){
		if (sobj=='Account' || sobj=='Asset' || sobj=='Campaign' || sobj =='Case' || sobj=='Contact' || sobj=='Lead' || sobj=='Opportunity' || sobj=='User' ){
			return true;
		}
		return false;
	}

	@TestVisible
	public static String getLookupField (String sobj){
		if (isStandard(sobj)){
			return sobj + 'Id';
		} else {
			return 'ParentId';
		}
	}

	@TestVisible
	public static String getAccessLevelField (String sobj){
		System.debug('accesslevelField received sobject type :' + sobj);
		if (isStandard(sobj)){
			System.debug('is a special object');
			return sobj + 'AccessLevel';
		} else {
			System.debug('is not a special object');
			return 'AccessLevel';
		}
	}




}