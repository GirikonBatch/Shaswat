public with sharing class Email_Attachment 
{
	public List<emailMessage> em = new List<emailMessage>();  // Email lists is to be archived
    public List<Attachment> at = new List<Attachment>();
    public String csid{get;set;}  							 // Case ID is to be processed
    public String parameterValue{get;set;}
    
    public Email_Attachment(ApexPages.StandardController controller)
    {
        system.debug('helo');
    	csid = ApexPages.currentPage().getParameters().get('id');
    }
    
//No Button Function Call
    
    public PageReference refreshRecord()     
    {
        csid = ApexPages.currentPage().getParameters().get('id');
        PageReference pgref = new PageReference(''+csid);
        return pgref;
    }
    
//Methods for Archive Records(Yes Button Function Call)
    
    public void saveRecord()     
    {
        for(emailMessage  e: [SELECT BccAddress,CcAddress,CreatedById,CreatedDate,FromAddress,FromName,HasAttachment,Headers,HtmlBody,Id,Incoming,
                             IsClientManaged,IsDeleted,IsExternallyVisible,LastModifiedById,LastModifiedDate,MessageDate,MessageIdentifier,ParentId,
                             RelatedToId,ReplyToEmailMessageId,Status,Subject,SystemModstamp,TextBody,ThreadIdentifier,ToAddress,ValidatedFromAddress 
                             FROM EmailMessage where ParentId =: csid])
        {
            em.add(e);

//Converting Every Email into a New Attachment in PDF Format  
            
            String pdfContent = e.Textbody;
            Attachment attachmentPDF = new Attachment();     
            attachmentPDF.parentId = csid;            
			attachmentPDF.name= e.id+ '.pdf';
            attachmentPDF.body = blob.toPDF(pdfContent);
			
			insert attachmentPDF;
        } 
        
//By Changing the Parent ID, Converting Email Attachments of each Email to Case Attachments

        for(Attachment at :[select Id, Name, Body, ParentId from Attachment where ParentId IN
           (select Id from EmailMessages where ParentId =: csid)])
        {
            String s = at.id;

            Attachment att = new Attachment();
            att.ParentId = csid;
            att.Name = 'aaa';
            att.Body = at.body;
            at.add(att);

            Insert at;
        }

        Delete at;
    }
}