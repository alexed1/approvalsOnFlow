@isTest
private class TestSharingAndAdmin {

	static testMethod void testSOSL() {
  	AdminTools.doSOSL('McLaughlin', 'Lead');
  }

  static testMethod void testReturning() {

    string uq = AdminTools.getReturning('User');
    system.assertEquals(uq, 'User(Id, Name, UserType WHERE UserType in (\'Standard\', \'PowerCustomerSuccess\', \'PowerPartner\'))');

    uq = AdminTools.getReturning('Group');
    system.assertEquals(uq, 'Group(Id, Name, Type)');

    uq = AdminTools.getReturning('Custom__c');
    system.assertEquals(uq, 'Custom__c(Id, Name)');

  	uq = AdminTools.getReturning('Lead');
    system.assertEquals(uq, 'Lead(Id, Name)');

  }

  static testMethod void testuserTypes() {
  	SharingActions.huh('PowerCustomerSuccess');
  	SharingActions.huh('PowerPartner');
  	SharingActions.huh('CustomerSuccess');
  	SharingActions.huh('CsnOnly');
  	SharingActions.huh('CSPLitePortal');
  	system.assertEquals('MadeUpStuff', SharingActions.huh('MadeUpStuff'));
  }

  static testMethod void testInnerClass(){
  	SharingActions.sharingHolder sh = new SharingActions.sharingHolder();
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
  		SharingActions.getSharings(l[0].id);
		} catch (AuraHandledException ahe){

		}

  	list<Opportunity> o = [select id from Opportunity];

		try {
  		SharingActions.getSharings(l[0].id);
		} catch (AuraHandledException ahe){

		}

    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

    SharingActions.getSharings(ptos[0].id);
    SharingActions.getSharings(rotos[0].id);
  }

  static testMethod void testcanIEditPermsAdmin() {
  	list<lead> l = [select id from lead];
  	SharingActions.canIEditPerms(l[0].id);

    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

    boolean perm = SharingActions.canIEditPerms(ptos[0].id);
    system.assertEquals(perm, true);
    perm = SharingActions.canIEditPerms(rotos[0].id);
    system.assertEquals(perm, true);

  }

  static testMethod void testcanIEditPermsAdminNonOwner() {
    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

    user u = createAdmin();
    boolean perm1;
    boolean perm2;

  	system.runAs(u){
      perm1 =SharingActions.canIEditPerms(ptos[0].id);
      perm2 =SharingActions.canIEditPerms(rotos[0].id);
  	}

    system.assertEquals(perm1, true);
    system.assertEquals(perm2, true);

  }

  static testMethod void testDelete() {

  	//list<lead> l = [select id from Lead];
    list<PrivateTestObject__c> ptos = [select Id from PrivateTestObject__c];
  	user u = createUsers(1)[0];

    SharingActions.upsertPerm(u.id, ptos[0].id, 'Edit');

  	SharingActions.deletePerm(u.id, ptos[0].id);
  }


  static testMethod void testUpsertPerm() {
  	list<Opportunity> o = [select id from Opportunity];
  	list<lead> l = [select id from Lead];
    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

  	user u = createUsers(1)[0];

    SharingActions.upsertPerm(u.id, ptos[0].id, 'Edit');
    SharingActions.upsertPerm(u.id, ptos[0].id, 'Read');
    SharingActions.upsertPerm(u.id, ptos[0].id, 'Edit');

    SharingActions.getSharings(ptos[0].id);

    SharingActions.deletePerm(u.id, ptos[0].id);


    SharingActions.upsertPerm(u.id, rotos[0].id, 'Edit');
    SharingActions.getSharings(rotos[0].id);
    SharingActions.deletePerm(u.id, rotos[0].id);

  	try {
  		SharingActions.upsertPerm(u.id, o[0].id, 'Edit');
  		SharingActions.deletePerm(u.id, o[0].id);
  	} catch (exception e){
  		//ok, sharing may not be on
  		system.debug(e);
  	}

  	try {
  		SharingActions.upsertPerm(u.id, o[0].id, 'Read');
  		SharingActions.deletePerm(u.id, o[0].id);
  	} catch (exception e){
  		system.debug(e);
  		//ok, sharing may not be on
  	}

  	try {
  		SharingActions.upsertPerm(u.id, l[0].id, 'Edit');
  		SharingActions.deletePerm(u.id, l[0].id);
  	} catch (exception e){
  		//ok, sharing may not be on
  		system.debug(e);
  	}

  	try {
  		SharingActions.upsertPerm(u.id, l[0].id, 'Read');
  		SharingActions.deletePerm(u.id, l[0].id);
  	} catch (exception e){
  		system.debug(e);
  		//ok, sharing may not be on
  	}
  }

  static testMethod void testStringStuff(){
  	AdminTools.getLookupField('Account');
  	AdminTools.getAccessLevelField('Account');
  	system.assertEquals('AccountShare', SharingActions.getSharingTableName('Account'));

  	AdminTools.getLookupField('Custom__c');
  	AdminTools.getAccessLevelField('Custom__c');
  	SharingActions.getSharingTableName('Custom__c');
		system.assertEquals('Custom__Share', SharingActions.getSharingTableName('Custom__c'));

		system.assertEquals('Namespace__Custom__Share', SharingActions.getSharingTableName('Namespace__Custom__c'));
  }


  static testMethod void testBuildQuery(){
  	list<lead> l = [select id from lead];
  	SharingActions.buildQuery(l[0].id);
  }

  static testMethod void testcanIEditPermsNonAdmin() {
  	//list<lead> l = [select id from lead];
    list<PrivateTestObject__c> ptos = [select id from PrivateTestObject__c];
    list<ReadOnlyTestObject__c> rotos = [select id from ReadOnlyTestObject__c];

  	list<user> users = createUsers(1);

    SharingActions.upsertPerm(users[0].id, ptos[0].id, 'Edit');
    SharingActions.upsertPerm(users[0].id, rotos[0].id, 'Edit');

  	System.RunAs(users[0]){

       
  		system.assertEquals(SharingActions.canIEditPerms(ptos[0].id), false);
      system.assertEquals(SharingActions.canIEditPerms(rotos[0].id), false);

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

       
      SharingActions.upsertPerm(groups[0].id, ptos[0].id, 'Read');
     

			try{
      	SharingActions.getSharings(l[0].id);
			} catch (AuraHandledException ahe){

			}
      SharingActions.getSharings(ptos[0].id);
      SharingActions.getSharings(rotos[0].id);
    }
    test.stopTest();

  }

	static testMethod void testSharingExistsAccount(){
		// should not exist--accounts are public r/w

		// not assertable because I don't know what the sharing is like in the destination org!
		SharingActions.sharingExists('Account');


		System.assertEquals(true, SharingActions.sharingExists('ltngsharing__PrivateTestObject__c'));
		System.assertEquals(true, SharingActions.sharingExists('ltngsharing__ReadOnlyTestObject__c'));

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
		u.Email = 'test@testAdminTools2017.com';
		u.Username = 'astest@testAdminTools2017.com';
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
			User u = new User(Alias = 't'+x, Email='standarduser'+x+'@testAdminTools2017.msm',
				EmailEncodingKey='UTF-8', LastName='Testing' + x, LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles', UserName='standarduser'+x+'@testAdminTools2017.msm');
			users.add(u);
		}

		insert users;
		return users;
	}

}