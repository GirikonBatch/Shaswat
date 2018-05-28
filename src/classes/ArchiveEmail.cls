public class ArchiveEmail 
{
    List<emailMessage> em = new List<emailMessage>();           // Email lists is to be Archived
    List<Attachment> at = new List<Attachment>();               // Attachments is to be Archived
    
    public id csid{get;set;}                                    // Case ID is to be Processed
    public String parameterValue{get;set;}

    list<Attachment> emailpdf = new List<Attachment>();        // List to contain PDF for Archived Email
    list<Attachment> lparser = new List<Attachment>();         // List that contain Parser

    public String aid = '';                                    // String to Store the Attachment Id for each Email
    public list<String> lstring = new list<String>();        

    public ArchiveEmail(ApexPages.StandardController controller)
    {
        system.debug('======================================hello');
        csid = ApexPages.currentPage().getParameters().get('id');
    }
    
// NoArchive Function Call
    
    public PageReference NoArchive()     
    {
        csid = ApexPages.currentPage().getParameters().get('id');
        PageReference pgref = new PageReference('/' + csid);
        return pgref;
    }
    
// Methods for OnArchive Function Call 
    
    public PageReference OnArchive()     
    {
        for(emailMessage  Email : [SELECT Counter__c,BccAddress,CcAddress,CreatedById,CreatedDate,FromAddress,FromName,HasAttachment,Headers,
                                   HtmlBody,Id,Incoming,IsClientManaged,IsDeleted,IsExternallyVisible,LastModifiedById,LastModifiedDate,
                              	   MessageDate,MessageIdentifier,ParentId,RelatedToId,ReplyToEmailMessageId,Status,Subject,SystemModstamp,
                              	   TextBody,ThreadIdentifier,ToAddress,ValidatedFromAddress FROM emailMessage where ParentId =: csid])
        {
            system.debug('##################################'+Email);
            
           // em.add(Email);

// Converting Every Email into a New Attachment in PDF Format  
            
            String pdfContent = 'Name:' + Email.FromAddress +'<br>'+'<br>'+ 'Subject:' + Email.Subject +'<br>'+'<br>'+ 'Body:' + Email.TextBody;
            
            Attachment attachmentPDF = new Attachment();     
            attachmentPDF.parentId = csid;            
            attachmentPDF.name= 'Email'+Email.Counter__c+'.pdf';
            attachmentPDF.body = blob.toPDF(pdfContent);
            
            emailpdf.add(attachmentPDF);
        
// By Changing the Parent ID, Converting Email Attachments of each Email to Case Attachments 

            for(Attachment a : [select Id, Name, Body, ParentId from Attachment where ParentId =: Email.id])
            {   
                Attachment att = new Attachment();
                att.parentId = csid;
                att.Name = Email.Counter__c+ '_' + a.Name;
                att.Body = a.body;
                at.add(att);
            }    
// Creating an Email into Parser File for Retriving Email
    
            Attachment attach = new Attachment();
            attach.parentId = csid;
            attach.Name = 'Parser'+Email.Counter__c+'.txt';
            attach.Body = blob.valueOf('#%#'+Email.BccAddress+
                                       '#%#'+Email.CcAddress+
                                       '#%#'+Email.FromAddress+
                                       '#%#'+Email.FromName+
                                       '#%#'+Email.Headers+
                                       '#%#'+Email.HtmlBody+
                                       '#%#'+Email.Id+
                                       '#%#'+Email.RelatedToId+
                                       '#%#'+Email.Status+
                                       '#%#'+Email.Subject+
                                       '#%#'+Email.TextBody+
                                       '#%#'+Email.ToAddress+
                                       '#%#'+aid);
            lparser.add(attach);
        }
   
        Insert at;
        Insert emailpdf;        
        Insert lparser;
        
        //Insert emailpdf;        
        //Delete at;
        //Delete emailpdf;        
        //database.emptyRecycleBin(Email);
       
        System.debug('++++++++++++++++++++++++++++++++++debug');
        
        PageReference pgref = new PageReference('/' + csid);
        return pgref;
    }
    
    public PageReference NoRestore()
    {
        PageReference pgref = new PageReference('/' + csid);
        return pgref;
    }
    
    public PageReference OnRestore()
    {
        csid = ApexPages.currentPage().getParameters().get('id');
        PageReference pgref = new PageReference ('/' + csid);
        return pgref;
    }
}