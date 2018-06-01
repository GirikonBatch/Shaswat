public class ArchiveEmail
{
    public string csid{get;set;}                                          // csid Stores the Case ID that is to be Archived to be Processed
    
    List<EmailMessage> delemail = new List<EmailMessage>();               // List of Emails to be Archived
    
    List<Attachment> lattach = new List<Attachment>();                    // List to Add Attachments
    List<Attachment> lemailpdf = new List<Attachment>();                  // List to contain PDF for Archived Emails
    List<Attachment> lparser = new List<attachment>();                    // List to contain Parser
    
    public String aid = '';                                               // String to store Attachment ID for every Email
    
    public map <id, EmailMessage> emailMap;                               // Map that has a List of Email as the Value (used to Store the Actual Email and the Type of EmailMessage)
    public map <id, Attachment> attmMap = new map<id, Attachment>();      // Map that has a List of Attachment as the Value (used to store the Actual Attachment and the Type of Attachment)
    

    public ArchiveEmail(ApexPages.StandardController controller)
    {  
        csid = ApexPages.currentPage().getParameters().get('id');   
    }

// Function Call on click of NO Button

    public PageReference NoArchive()
    {    
        PageReference pgref = new PageReference('/' + csid);
        //system.debug('#####################' + csid);
        return pgref;
    }

// Function Call on click of YES Button

    public PageReference OnArchive()
    {
        emailMap = new map<id, EmailMessage>([SELECT ActivityId,BccAddress,CcAddress,CreatedById,CreatedDate,FromAddress,FromName,
                                              HasAttachment,Headers,HtmlBody,Id,Incoming,IsClientManaged,IsDeleted,IsExternallyVisible,
                                              LastModifiedById,LastModifiedDate,MessageDate,MessageIdentifier,ParentId,RelatedToId,
                                              ReplyToEmailMessageId,Status,Subject,TextBody,ToAddress,ValidatedFromAddress,Counter__c 
                                              FROM EmailMessage WHERE ParentId =: csid]);
   
        //system.debug('#####################' + emailMap);
        
        attmMap = new map<id, Attachment>([SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,IsDeleted,IsPrivate,
                                           LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,SystemModstamp FROM Attachment WHERE 
                                           ParentId in : emailMap.keySet()]);
        
        //system.debug('#####################' + attmMap);
        
        for(Attachment at : attmMap.values())
        {
            Attachment atch = new Attachment();
                    
            EmailMessage em = emailMap.get(at.ParentId);                       // Relevant from Bulk perspective 
            
// Otherwise simply use csid        
            atch.Body = at.Body;
            atch.ContentType = at.ContentType;
            atch.Description = at.Description;
            atch.IsPrivate =  at.IsPrivate;
            atch.Name  = 'ATTACHMENT' + '_' + em.Counter__c + '_' + at.Name;
            atch.ParentId = em.ParentId;                                      
            
            lattach.add(atch);
        }

        if(lattach.size()>0)
        Insert lattach; 

        for(EmailMessage em : emailMap.values())
        {             
            aid = '';  
            
            for(Attachment a : lattach)
            {
                string str = a.Name;
                
                if(str.startsWith('ATTACHMENT' + '_' + em.Counter__c))
                {
                    aid = aid + a.Id + ';';
                } 
            }
            
// Creating PDF file to Email   
            Attachment at = new Attachment();

            at.ParentId =  em.ParentId;
            at.Name = 'EMAIL' + '_' + em.Counter__c + '_.pdf';
            at.Body = blob.toPDF('Name:' + em.FromName + '<br/>' + '<br/>' + 'From:' + em.FromAddress + '<br/>' + '<br/>' + 'CC Name:' + em.CcAddress + '<br/>' + '<br/>' +
                                 'BCC Name:' + em.BccAddress + '<br/>' + '<br/>' + 'Subject:' + em.Subject + '<br/>' + '<br/>' + 'Body:' + em.TextBody + '<br/>'+ '<br/>');
                                    
            lemailpdf.add(at);

// Creating Parser file for every Email
            Attachment parse = new Attachment();
            
            parse.ParentId = em.ParentId;
            parse.Name = 'PARSER' + '_' + em.Counter__c + '_.txt';
            parse.Body =  blob.valueOf('#%#'+em.BccAddress+          // 1st 
                                       '#%#'+em.CcAddress+           // 2nd
                                       '#%#'+em.FromAddress+
                                       '#%#'+em.FromName+
                                       '#%#'+em.Headers+
                                       '#%#'+em.ParentId+            // 6th i.e; Case Id
                                       '#%#'+em.Status+
                                       '#%#'+em.Subject+
                                       '#%#'+em.TextBody+            // Body
                                       '#%#'+em.ToAddress+
                                       '#%#'+aid);
                                       
            lparser.add(parse);                          // Adding Parser Files to List for Insertion          
            delemail.add(em);                            // Adding Email Objects to List for Deletion
        }
            
        Insert lemailpdf;
        Insert lparser;

        //Delete delemail;
    
        list<task> ts = [SELECT Id, TaskSubtype, WhatId, WhoId FROM Task WHERE TaskSubtype = 'EMAIL' AND WhatId =: csid];
        
        Delete ts;
        
        if(ts.size()>0)
        database.emptyRecycleBin(ts);

        PageReference pgref = new PageReference('/' + csid);
        //system.debug('#####################' + csid);
        return pgref; 
    }
}