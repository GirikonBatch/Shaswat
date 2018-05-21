public with sharing class Email_Attachment 
{
    List<emailMessage> em = new List<emailMessage>();           // Email lists is to be Archived
    List<Attachment> at = new List<Attachment>();               // Attachments is to be Archived
    public String csid{get;set;}                                // Case ID is to be Processed
    public String parameterValue{get;set;}

    list<Attachment> emailpdf = new List<Attachment>();        // List to contain PDF for Archived Email
    list<Attachment> lparser = new List<Attachment>();         // List that contain Parser

    public String aid = '';                                    // String to Store the Attachment Id for each Email
    public list<String> lstring = new list<String>();        

    public Email_Attachment(ApexPages.StandardController controller)
    {
        system.debug('helo');
        csid = ApexPages.currentPage().getParameters().get('id');
    }
    
// NoArchive Function Call
    
    public PageReference NoArchive()     
    {
        csid = ApexPages.currentPage().getParameters().get('id');
        PageReference pgref = new PageReference(''+csid);
        return pgref;
    }
    
// Methods for Archive Function Call 
    
    public PageReference OnArchive()     
    {
        for(emailMessage  e: [SELECT BccAddress,CcAddress,CreatedById,CreatedDate,FromAddress,FromName,HasAttachment,Headers,HtmlBody,Id,Incoming,
                             IsClientManaged,IsDeleted,IsExternallyVisible,LastModifiedById,LastModifiedDate,MessageDate,MessageIdentifier,ParentId,
                             RelatedToId,ReplyToEmailMessageId,Status,Subject,SystemModstamp,TextBody,ThreadIdentifier,ToAddress,ValidatedFromAddress 
                             FROM EmailMessage where ParentId =: csid])
        {
            em.add(e);

// Converting Every Email into a New Attachment in PDF Format  
            
            String pdfContent = 'Name:'+ e.FromAddress + '<br>'+'Subject:'+e.subject + '<br>' + 'Body:'+e.textBody;
            Attachment attachmentPDF = new Attachment();     
            attachmentPDF.parentId = csid;            
            attachmentPDF.name= e.id+'.pdf';
            attachmentPDF.body = blob.toPDF(pdfContent);
            
            emailpdf.add(attachmentPDF);
        
        
// By Changing the Parent ID, Converting Email Attachments of each Email to Case Attachments 

            for(Attachment a : [select Id, Name, Body, ParentId from Attachment where ParentId IN : em])
            {
                String s = a.id;
                
                Attachment att = new Attachment();
                att.parentId = csid;
                att.Name = 'aaa';
                att.Body = a.body;
                at.add(att);
            }
            
// Creating an Email into Parser File for Retriving Email
    
            Attachment attach = new Attachment();
            attach.parentId = csid;
            attach.Name = 'Attachment';
            attach.Body = blob.valueOf('#%#'+e.BccAddress+
                                       '#%#'+e.CcAddress+
                                       '#%#'+e.FromAddress+
                                       '#%#'+e.FromName+
                                       '#%#'+e.Headers+
                                       '#%#'+e.HtmlBody+
                                       '#%#'+e.Id+
                                       '#%#'+e.RelatedToId+
                                       '#%#'+e.Subject+
                                       '#%#'+e.TextBody+
                                       '#%#'+e.ToAddress+
                                       '#%#'+e.Incoming+
                                       '#%#'+e.Status+
                                       '#%#'+aid);
            
            lparser.add(attach);
        }
        
        Insert at;
        Insert emailpdf;
        Insert lparser;
        
        Delete at;
        database.emptyRecycleBin(em);

        PageReference pgref = new PageReference(''+csid);
        return pgref;
    }
    
    public PageReference Restore()
    {
        PageReference pgref = new PageReference(''+csid);
        return pgref;
    }
}