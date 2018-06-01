public class RestoreEmail
{
    public String csid;                                              // csid Stores the Case ID that is to be Archived to be Processed
    
    public RestoreEmail(ApexPages.StandardController controller)
    {
        csid = ApexPages.currentPage().getParameters().get('id');
    }

// Function Call on click of NO Button
    public PageReference NoRestore() 
    {
        PageReference pgref = new PageReference('/' + csid);
        //system.debug('########################'+ csid);
        return pgref;
    }

    public PageReference OnRestore()
    {
        
// Function Call on click of YES Button
        List<EmailMessage> emailRestore = new List<EmailMEssage>();         // Email List to Restore
        List<String> atids = new List<String>();
        
        Map<integer, List<id>> IndexAttachmentMap = new Map<integer, List<id>>();
        Map<id, List<id>> EmailIDAttachmentMap = new Map<id, List<id>>();

        List<Attachment> ATTFILES = new List<Attachment>();
        
        integer i = 0;
        
        ATTFILES = [SELECT Id, ParentId, Name, Body FROM Attachment WHERE name LIKE '%PARSER.txt' AND ParentID =: csid];   // Use ParentID in:ListCaseID in bulk

        Map <id, Attachment> AllAttach = new Map<id, Attachment>([SELECT Id, ParentId, Name, Body, ContentType, Description, IsPrivate, OwnerId FROM Attachment WHERE ParentID =: csid]);

        for(Attachment at : ATTFILES)
        {
            // Reading Parser File and Creating an Email corresponding to every Parser and fetching Attachment ids in Parser
            
            String bodyContent = at.body.toString();          // bodyContent is Body of Parser file
            String[] lstring = bodyContent.split('#%#');
            
            //system.debug('############################'+ lstring);
            
            EmailMessage em = new EmailMessage();
            
            em.BccAddress = lstring[1];
            em.CcAddress = lstring[2];
            em.FromAddress = lstring[3];
            em.FromName = lstring[4];
            em.Headers = lstring[5];
            em.ParentId = lstring[6];            // CaseID can also be used but this will help in bulk so it is used
            em.Status = lstring[7];
            em.Subject = lstring[8];
            em.TextBody = lstring[9];
            em.ToAddress = lstring[10];
            
            emailrestore.add(em);               // Adding email object to list for insertion outside for loop
    
            if(lstring.size()==12)              // Check if Attachment Ids are there or not 
            {
                atids.clear();
                atids = lstring[11].split(';'); //atids contains  attachment ids stored in parser file
                
                //system.debug('##############atids############ inside if condition'+ atids);
    
                // Storing list of ids
                if(atids.size()>0)
                {
                    //system.debug('##########ATTACHMENTIDS##########'+ atids);
    
                    List<id> AttachmentsID = new List<id>();           // temp list this will contain Attachment Ids to be inserted       
                    
                    For(integer j=0;j<atids.size();j++)
                    {    
                        AttachmentsID.add(atids[j]);
                        
                        //System.debug('######################### '+ AttachmentsID );
                    }
                     
                    IndexAttachmentMap.put(i++,AttachmentsID);         // Saving Attachment Ids with Indexes in Map
        
                    //System.debug('#############'+ AttachmentsID +'   '+ i);
                }
            }
            
            if(lstring.size()<12)
            {
                i++;
            }
        }

        Insert emailrestore;                            // Email Objects Inserted    
        
        for(integer j=0;j<emailrestore.size();j++)
        {
            if(IndexAttachmentMap.get(j)!=NULL)
            {
                EmailIDAttachmentMap.put(emailrestore[j].id, IndexAttachmentMap.get(j)) ;   // Saving Email Id and corresponding Attachments Id using map1 
                 
                //IndexAttachmentMap.remove(j);
            }
        }
               
        //System.debug('++++++++++++++++++++++++'+EmailIDAttachmentMap);
    
        List<Attachment> atmList = new List<Attachment>();
        List<Attachment> atmLis = new List<Attachment>();
        
        for(id eid : EmailIDAttachmentMap.keySet() )                      // Traversing list of inserted Email Ids in map2
        {      
            List<id> atid;
            
            if(EmailIDAttachmentMap.get(eid) != NULL)
            {
                atid = new List<id>(EmailIDAttachmentMap.get(eid));       // Saving a set of Ids for specific Email Id
            }
            
            for(Integer j=0;j<atid.size();j++)
            {
                Attachment At = AllAttach.get(atid[j]);
                Attachment atch = new attachment();
                
                atch.Body = At.Body;
                atch.ContentType = At.ContentType;
                atch.Description = At.Description;
                atch.IsPrivate =  At.IsPrivate;
                atch.Name  = At.Name.substringAfterLast('_') ;
                atch.OwnerId = At.OwnerId;
                atch.ParentId = eid;
                
                atmList.add(atch);  
                atmLis.add(at); 
            }                   
        }
     
        Insert atmList; //insert
           
        //Delete atmLis;
        del();     
    
        PageReference pgref = new PageReference('/'+csid);
        return pgref;
    }
    
    void del()
    {
        List<Attachment> ParserfilesDelete = new List<Attachment>();
        List<Attachment> EmailfilesDelete = new List<Attachment>();
        
        ParserfilesDelete = [SELECT Id,ParentId,Name,body,ContentType FROM Attachment WHERE name LIKE '%PARSER.txt' AND ParentId =: csid];
        EmailfilesDelete = [SELECT Id,ParentId,Name,body,ContentType FROM Attachment WHERE name LIKE 'EMAIL%.pdf' AND ParentId =: csid];
        
        //Delete ParserfilesDelete;
        //Delete EmailfilesDelete;
    }
}