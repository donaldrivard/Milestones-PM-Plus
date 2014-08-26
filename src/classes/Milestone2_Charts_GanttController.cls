public with sharing class Milestone2_Charts_GanttController {

    public String myTarget {get; 
        set{
            this.mytarget = value;
            init();
        }
    }
    public String mySize {get;
        set{
            this.mySize = value;
        }
    }
    public String myOptions {get;
        set{
            this.myOptions = value;
        }
    }
    
    public List<List<String>> taskItems {get;set;}
  
    public String objectType {get;set;}
    public String startDateFieldName {get;set;}
    public String endDateFieldName {get;set;}
    public String idFieldName {get;set;}
    public String fullViewURL {get;set;}
 
    private String nameFieldName;
    private String completedFieldName;
    private String filterFieldName;
        
    public List<Sobject> sObjectList {get; set;}
    
    public static final String COLOR_COMPLETE = '333333'; //Dark Grey
    public static final String COLOR_LATE = 'ee3322'; //Red
    public static final String COLOR_FUTURE = '666666'; //Light Grey
    public static final String COLOR_CURRENT = '2299bb'; //Blue
    
    public void init()
    {
        if (myTarget != null)
        {
            initFieldNames();
            retrieveData();
            toJSon();
        }
    }
    
    /*
    *   Initialize the variables depending on the object type possible values: 
    *   Milestone1_Milestone__c and Milestone1_Task__c
    */
    private void initFieldNames(){
        if(mytarget != null){
            if(mytarget.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())){

                startDateFieldName = Milestone1_Milestone__c.Kickoff__c.getDescribe().getName();
                endDateFieldName = Milestone1_Milestone__c.Deadline__c.getDescribe().getName();
                nameFieldName = Milestone1_Milestone__c.NameClean__c.getDescribe().getName();
                filterFieldName = Milestone1_Milestone__c.Project__c.getDescribe().getName();

                objectType = Schema.SObjectType.Milestone1_Milestone__c.getName();

            }else if(mytarget.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix())){

                startDateFieldName = Milestone1_Task__c.Start_Date__c.getDescribe().getName();
                endDateFieldName = Milestone1_Task__c.Due_Date__c.getDescribe().getName();
                nameFieldName = Milestone1_Task__c.Name.getDescribe().getName();
                filterFieldName = Milestone1_Task__c.Project_Milestone__c.getDescribe().getName();
                                
                objectType = Schema.SObjectType.Milestone1_Task__c.getName();
                
            } else {
                throw new Milestone1_Exception('[initFieldNames] Unable to generate JSON for ' + mytarget);
            }
            idFieldName = 'Id';
            completedFieldName = 'Complete__c'; 
        }
    }
    
    /*
    *   Retrieve the data doing a dynamic query by object type.
    */
    private void retrieveData(){
        
        String query = 'Select '+idFieldName+','+startDateFieldName+','+endDateFieldName+','+nameFieldName+','+completedFieldName+
                       ' from '+objectType+ ' where '+filterFieldName+'=\''+mytarget+'\' order by ' + startDateFieldName;
        sobjectList = Database.query(query);
    }
    
    /**
    *   Generate the output in json format to be rendered in the jquery gantt.
    */
    private void toJSon(){

        Date startDate,endDate;
        String name, id, color, sDateString, eDateString, urlString;
        Integer i, completed;
        
        taskItems = new List<List<String>>();
        
        i = 0;
        for (Sobject current : sobjectList){ 
            if(current.get(startDateFieldName) == null){
                startDate = Date.today();
            }else{
                startDate = Date.valueOf(current.get(startDateFieldName));
            }
            sDateString = startDate.month() + '/' + startDate.day() + '/' + startDate.year();
            
            if(current.get(endDateFieldName) == null){
                endDate = startDate;
            }else{
                endDate = Date.valueOf(current.get(endDateFieldName));
            }
            eDateString = endDate.month() + '/' + endDate.day() + '/' + endDate.year();
            
            if(Boolean.valueOf(current.get(completedFieldName)))
                completed = 1;
            else
                completed = 0;
            
            name = String.valueOf(current.get(nameFieldName));
            id = String.valueOf(current.get(idFieldName));
            urlString = URL.getSalesforceBaseUrl().toExternalForm() + '/' + id;

            color=COLOR_CURRENT;
            if (completed == 1) {
                color=COLOR_COMPLETE;
            } else if (endDate < Date.today()) {
                color=COLOR_LATE;
            } else if (startDate > Date.today()) {
                color=COLOR_FUTURE;
            }
            
/***************************************************************
pID: (required) is a unique ID used to identify each row for parent functions and for setting dom id for hiding/showing
pName: (required) is the task Label
pStart: (required) the task start date, can enter empty date ('') for groups. You can also enter specific time (2/10/2008 12:00) for additional percision or half days.
pEnd: (required) the task end date, can enter empty date ('') for groups
pColor: (required) the html color for this task; e.g. '00ff00'
pLink: (optional) any http link navigated to when task bar is clicked.
pMile:(optional) represent a milestone
pRes: (optional) resource name
pComp: (required) completion percent
pGroup: (optional) indicates whether this is a group(parent) - 0=NOT Parent; 1=IS Parent
pParent: (required) identifies a parent pID, this causes this task to be a child of identified task
pOpen: can be initially set to close folder when chart is first drawn
pDepend: optional list of id's this task is dependent on ... line drawn from dependent to this item
pCaption: optional caption that will be added after task bar if CaptionType set to "Caption"
*/    
          
            taskItems.add(new String[]{String.valueOf(++i), name, sDateString, 
                eDateString, color, urlString, '0','Brent',
                String.valueOf(completed), '0','0','0', '', ''});
        }
    }

}