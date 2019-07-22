@isTest
private class TestLightningSharing {

	static testMethod void testSOSL() {
  	LightningSharing.doSOSL('McLaughlin', 'Lead');
  }

  static testMethod void testReturning() {

    string uq = LightningSharing.getReturning('User');
    system.assertEquals(uq, 'User(Id, Name, UserType WHERE UserType in (\'Standard\', \'PowerCustomerSuccess\', \'PowerPartner\'))');

    uq = LightningSharing.getReturning('Group');
    system.assertEquals(uq, 'Group(Id, Name, Type)');

    uq = LightningSharing.getReturning('Custom__c');
    system.assertEquals(uq, 'Custom__c(Id, Name)');

  	uq = LightningSharing.getReturning('Lead');
    system.assertEquals(uq, 'Lead(Id, Name)');

  }

  static testMethod void testuserTypes() {
  	LightningSharing.huh('PowerCustomerSuccess');
  	LightningSharing.huh('PowerPartner');
  	LightningSharing.huh('CustomerSuccess');
  	LightningSharing.huh('CsnOnly');
  	LightningSharing.huh('CSPLitePortal');
  	system.assertEquals('MadeUpStuff', LightningSharing.huh('MadeUpStuff'));
  }

  static testMethod void testInnerClass(){
  	LightningSharing.sharingHolder sh = new LightningSharing.sharingHolder();
  	sh.UserOrGroupName = 'test';
  	sh.SubType = 'test';
  	sh.UserOrGroupType = 'test';
  	sh.UserOrGroupID = 'test';
  	sh.AccessLevel = 'test';
  	sh.RowCause = 'test';

    system.assertEquals(sh.UserOrGroupName, 'test');
    system.assertEquals(sh.SubType, 'test');
    system.assertEquals(sh.UserOrGroupType, 'test');
    system.assertEquals(sh.UserOrGroupID, 'test');
    system.assertEquals(sh.AccessLevel, 'test');
    system.assertEquals(sh.RowCause, 'test');
  }

  static testMethod void testGetSharings() {
  	list<lead> l = [select id from lead];
		try {
  		LightningSharing.getSharings(l[0].id);
		} catch (AuraHandledException ahe){

		}

  	list<Opportunity> o = [select id from Opportunity];

		try {
  		LightningSharing.getSharings(l[0].id);
		} catch (AuraHandledException ahe){

		}

    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

    LightningSharing.getSharings(ptos[0].id);
    LightningSharing.getSharings(rotos[0].id);
  }

  static testMethod void testcanIEditPermsAdmin() {
  	list<lead> l = [select id from lead];
  	LightningSharing.canIEditPerms(l[0].id);

    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

    boolean perm = LightningSharing.canIEditPerms(ptos[0].id);
    system.assertEquals(perm, true);
    perm = LightningSharing.canIEditPerms(rotos[0].id);
    system.assertEquals(perm, true);

  }

  static testMethod void testcanIEditPermsAdminNonOwner() {
    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

    user u = createAdmin();
    boolean perm1;
    boolean perm2;

  	system.runAs(u){
      perm1 =LightningSharing.canIEditPerms(ptos[0].id);
      perm2 =LightningSharing.canIEditPerms(rotos[0].id);
  	}

    system.assertEquals(perm1, true);
    system.assertEquals(perm2, true);

  }

  static testMethod void testDelete() {

  	//list<lead> l = [select id from Lead];
    list<PrivateTestObject__c> ptos = [select Id from PrivateTestObject__c];
  	user u = createUsers(1)[0];

    LightningSharing.upsertPerm(u.id, ptos[0].id, 'Edit');

  	LightningSharing.deletePerm(u.id, ptos[0].id);
  }


  static testMethod void testUpsertPerm() {
  	list<Opportunity> o = [select id from Opportunity];
  	list<lead> l = [select id from Lead];
    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

  	user u = createUsers(1)[0];

    LightningSharing.upsertPerm(u.id, ptos[0].id, 'Edit');
    LightningSharing.upsertPerm(u.id, ptos[0].id, 'Read');
    LightningSharing.upsertPerm(u.id, ptos[0].id, 'Edit');

    LightningSharing.getSharings(ptos[0].id);

    LightningSharing.deletePerm(u.id, ptos[0].id);


    LightningSharing.upsertPerm(u.id, rotos[0].id, 'Edit');
    LightningSharing.getSharings(rotos[0].id);
    LightningSharing.deletePerm(u.id, rotos[0].id);

  	try {
  		LightningSharing.upsertPerm(u.id, o[0].id, 'Edit');
  		LightningSharing.deletePerm(u.id, o[0].id);
  	} catch (exception e){
  		//ok, sharing may not be on
  		system.debug(e);
  	}

  	try {
  		LightningSharing.upsertPerm(u.id, o[0].id, 'Read');
  		LightningSharing.deletePerm(u.id, o[0].id);
  	} catch (exception e){
  		system.debug(e);
  		//ok, sharing may not be on
  	}

  	try {
  		LightningSharing.upsertPerm(u.id, l[0].id, 'Edit');
  		LightningSharing.deletePerm(u.id, l[0].id);
  	} catch (exception e){
  		//ok, sharing may not be on
  		system.debug(e);
  	}

  	try {
  		LightningSharing.upsertPerm(u.id, l[0].id, 'Read');
  		LightningSharing.deletePerm(u.id, l[0].id);
  	} catch (exception e){
  		system.debug(e);
  		//ok, sharing may not be on
  	}
  }

  static testMethod void testStringStuff(){
  	LightningSharing.getLookupField('Account');
  	LightningSharing.getAccessLevelField('Account');
  	system.assertEquals('AccountShare', LightningSharing.getSharingTableName('Account'));

  	LightningSharing.getLookupField('Custom__c');
  	LightningSharing.getAccessLevelField('Custom__c');
  	LightningSharing.getSharingTableName('Custom__c');
		system.assertEquals('Custom__Share', LightningSharing.getSharingTableName('Custom__c'));

		system.assertEquals('Namespace__Custom__Share', LightningSharing.getSharingTableName('Namespace__Custom__c'));
  }


  static testMethod void testBuildQuery(){
  	list<lead> l = [select id from lead];
  	LightningSharing.buildQuery(l[0].id);
  }

  static testMethod void testcanIEditPermsNonAdmin() {
  	//list<lead> l = [select id from lead];
    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

  	list<user> users = createUsers(1);

    LightningSharing.upsertPerm(users[0].id, ptos[0].id, 'Edit');
    LightningSharing.upsertPerm(users[0].id, rotos[0].id, 'Edit');

  	System.RunAs(users[0]){

      //LightningSharing.getSharings(l[0].id);
      //LightningSharing.getSharings(ptos[0].id);
      //LightningSharing.getSharings(rotos[0].id);

      //system.assert(LightningSharing.canIEditPerms(l[0].id), false);
  		system.assertEquals(LightningSharing.canIEditPerms(ptos[0].id), false);
      system.assertEquals(LightningSharing.canIEditPerms(rotos[0].id), false);

  	}
  }

  static testMethod void testGroupStuff(){
    list<group> groups = [select id from group where Name = 'the knights who say nee'];
    list<lead> l = [select id from lead];
    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

    list<user> users = createUsers(2);

    list<GroupMember> gms = new list<GroupMember>();
    gms.add(new GroupMember(GroupId=groups[0].id, UserOrGroupId=users[0].id));
    gms.add(new GroupMember(GroupId=groups[0].id, UserOrGroupId=users[1].id));

    insert gms;

    test.startTest();
    system.RunAs(createAdmin()){

      //LightningSharing.upsertPerm(groups[0].id, l[0].id, 'Read');
      LightningSharing.upsertPerm(groups[0].id, ptos[0].id, 'Read');
      //LightningSharing.upsertPerm(groups[0].id, rotos[0].id, 'Read');

			try{
      	LightningSharing.getSharings(l[0].id);
			} catch (AuraHandledException ahe){

			}
      LightningSharing.getSharings(ptos[0].id);
      LightningSharing.getSharings(rotos[0].id);
    }
    test.stopTest();

  }

	static testMethod void testSharingExistsAccount(){
		// should not exist--accounts are public r/w

		// not assertable because I don't know what the sharing is like in the destination org!
		LightningSharing.sharingExists('Account');


		System.assertEquals(true, LightningSharing.sharingExists('ltngsharing__PrivateTestObject__c'));
		System.assertEquals(true, LightningSharing.sharingExists('ltngsharing__ReadOnlyTestObject__c'));

		// Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
		// for (string s:tokens.keySet()){
		// 	system.debug(s);
		// }
	}

	

  @testSetup static void makeData(){
    	//make some object for testing, like a lead
    	lead l = new lead();
    	l.Lastname = 'McLaughlin';
    	l.company = 'Salesforce';
    	l.email = 'm.shane.mclaughlin@gmail.com';
    	insert l;

    	account a = new account();
    	a.Name = 'Ink, inc.';
    	insert a;

    	contact c = new contact();
    	c.accountId = a.id;
    	c.FirstName = 'Sarah';
    	c.LastName = 'McLaughlin';
    	c.Email = 'sarah@gmail.com';
    	insert c;

    	Opportunity o = new Opportunity();
    	o.accountId = a.id;
    	o.closeDate = system.today();
    	o.Name = 'biggest deal ever';

    	o.StageName = [select MasterLabel from OpportunityStage where IsClosed = false][0].MasterLabel;
    	insert o;

      PrivateTestObject__c pto = new PrivateTestObject__c();
      insert pto;

      ReadOnlyTestObject__c roto = new ReadOnlyTestObject__c();
      insert roto;

      group g = new group();
      g.Name = 'the knights who say nee';
      g.Type = 'Regular';

      insert g;


  }




  public static user createAdmin(){
  	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

		// create User
		User u = new User();

		u.FirstName = 'A';
		u.LastName = 'S';
		u.Email = 'test@testLightningSharing2017.com';
		u.Username = 'astest@testLightningSharing2017.com';
		u.Alias = 'astest';
		u.ProfileId = p.Id;
		u.TimeZoneSidKey    = 'America/Denver';
		u.LocaleSidKey      = 'en_US';
		u.EmailEncodingKey  = 'UTF-8';
		u.LanguageLocaleKey = 'en_US';

		insert u;
		system.debug('u contains ' + u);
		return u;
	}

	public static list<user> createUsers(integer numberOfUsers){
		list<user> users = new list<user>();

		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];


		for (integer i=0; i<numberOfUsers; i++){
			string x = string.valueOf(i);
			User u = new User(Alias = 't'+x, Email='standarduser'+x+'@testLightningSharing2017.msm',
				EmailEncodingKey='UTF-8', LastName='Testing' + x, LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles', UserName='standarduser'+x+'@testLightningSharing2017.msm');
			users.add(u);
		}

		insert users;
		return users;
	}

}