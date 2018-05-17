public with sharing class Email_Attachment 
{
	public List<emailMessage> em = new List<emailMessage>();
    public List<Attachment> at = new List<Attachment>();
    public String csid{get;set;}
    public String parameterValue{get;set;}
    
    public Email_Attachment(ApexPages.StandardController controller)
    {
    	csid = ApexPages.currentPage().getParameters().get('id');
    }
    
    public PageReference refreshRecord()     //Don't Save Records    
    {
        csid = ApexPages.currentPage().getParameters().get('id');
        PageReference pgref = new PageReference(''+csid);
        return pgref;
    }
    
    public void saveRecord()     //Constructor--Archive Records
    {
        for(emailMessage  e: [SELECT BccAddress,CcAddress,CreatedById,CreatedDate,FromAddress,FromName,HasAttachment,Headers,HtmlBody,Id,Incoming,
                             IsClientManaged,IsDeleted,IsExternallyVisible,LastModifiedById,LastModifiedDate,MessageDate,MessageIdentifier,ParentId,
                             RelatedToId,ReplyToEmailMessageId,Status,Subject,SystemModstamp,TextBody,ThreadIdentifier,ToAddress,ValidatedFromAddress 
                             FROM EmailMessage where ParentId =: csid])
        {
            em.add(e);
            
            String pdfContent = e.Textbody;
            
            Attachment attachmentPDF = new Attachment();     //Converting to PDF
            attachmentPDF.parentId = csid;            
			attachmentPDF.name= e.id+ '.pdf';
            attachmentPDF.body = blob.toPDF(pdfContent);
			
			insert attachmentPDF;
        } 
    }
}