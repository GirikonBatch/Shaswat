public class RestoreEmail 
{	
    public ID csid{get;set;}                                               // Case ID is to be Processed
    
    public String CaseID;
    
    public List<Attachment> attlist = new List<Attachment>();              // Attachments list to Restore    
    public List<emailMessage> emlist = new List<emailMessage>();           // Email list to Restore
    
    //list<emailMessage> emailrestore = new list<emailMessage>();
    
    public list<String> lstring = new list<String>();


   	public RestoreEmail(ApexPages.StandardController controller)
    {
        csid = ApexPages.currentPage().getParameters().get('id');
    }

// NoRestore Function Call
    
    public PageReference NoRestore()
    {
        csid = ApexPages.currentPage().getParameters().get('id');
        PageReference pgref = new PageReference('/' + csid);
        return pgref;
    }
    
// Methods for OnRestore Function Call

	public PageReference OnRestore()
    {
        map<integer, list<id>> listatt = new map<integer, list<id>>();
        map<id, list<id>> listid = new map<id, list<id>>();
        
        integer i = 0;
        
        for(Attachment atch : [SELECT Id, Name, ParentId, Body FROM Attachment WHERE Name LIKE 'Parser%' AND ParentId =: csid])
        {
            String bodyContent = atch.body.toString();             // bodyContent is body of Parser File

            String[] lstring = bodycontent.split('#%#');
            
            EmailMessage emsg = new EmailMessage();
            
                emsg.BccAddress=lstring[1];
                emsg.CcAddress=lstring[2];
                emsg.FromAddress=lstring[3];
                emsg.FromName=lstring[4];
                emsg.Headers=lstring[5];
            	emsg.HtmlBody=lstring[6];
                emsg.Id=CaseID;
           		emsg.RelatedToId=CaseID;
            	emsg.Status=lstring[9];
            	emsg.Subject=lstring[10];
            	emsg.TextBody=lstring[11];
                emsg.ToAddress=lstring[12];
            
                emlist.add(emsg);
        }
        
        PageReference pgref = new PageReference('/' + csid);
        return pgref;
    }
}