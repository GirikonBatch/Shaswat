public class RestoreEmail
{
	public String csid;
    
	public List<emailMessage> emailRestore = new List<emailMessage>();          //Email list to Restore
    
    public list<String> lstring = new list<String>();

	public RestoreEmail(ApexPages.StandardController controller)
	{
		csid = ApexPages.currentPage().getParameters().get('id');
	}
	
	public PageReference NoRestore()
	{
        csid = ApexPages.currentPage().getParameters().get('id');
        PageReference pgref = new PageReference('/' + csid);
        return pgref;
	}

	public Pagereference OnRestore()
    {
		List<String> atids = new List<String>();
		Map<integer,List<id>> EmailAttachementMap = new Map<integer,List<id>>();

        integer i = 0;
		
        for(Attachment at : [SELECT Id, ParentId, Name, Body FROM Attachment WHERE name LIKE 'Parser%' AND ParentID =: csid])
 		{
		    //Reading Parser File and creating an Email corresponding to every Parser and fetching Attachment ids in Parser
    		String bodyContent = at.body.toString();           //bodyContent is body of Parser File
    		String[] lstring = bodycontent.split('#%#');

    		EmailMessage eml = new EmailMessage();
            
    		eml.BccAddress = lstring[1];
    		eml.CcAddress = lstring[2];
    		eml.FromAddress = lstring[3];
    		eml.FromName = lstring[4];
    		eml.Headers = lstring[5];
            eml.HtmlBody = lstring[6];
    		eml.ParentId = lstring[7];
            eml.RelatedToId = lstring[8];
            eml.Status = lstring[9];
            eml.Subject = lstring[10];
            eml.TextBody = lstring[11];
   			eml.ToAddress = lstring[12];
    		    		
            emailrestore.add(eml);
    
    		if(lstring.size()==13)
    		{
    			atids = lstring[12].split(';');       // atids contains  attachment ids stored in parser file
    		}
    
            // Storing list of ids
    		if(atids.size()>0)
    		{
    			List<id> AttachmentsID = new List<id>(); // This will contain attachment ids to be inserted       
        
                For(integer j=0;j<atids.size();j++)
        		{    
                    Attachment b = new Attachment();
                    
             		b = [SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,IsDeleted,IsPrivate,LastModifiedById,
                         LastModifiedDate,Name,OwnerId,ParentId,SystemModstamp FROM Attachment WHERE id =: atids[j]];
            
                    AttachmentsID.add(b.id);
        		} 
                
                EmailAttachementMap.put(i++,AttachmentsID);
    		}
		}

		insert emailrestore;

        Map<id,List<id>> EmailAttachementMap1 = new Map<id,List<id>>();
                
        for(integer j=0;j<emailrestore.size();j++)
        {
        	EmailAttachementMap1.put(emailrestore[j].id, EmailAttachementMap.get(j)) ;  
        	EmailAttachementMap.remove(j);
        }
        
        List<Attachment> atmList = new List<Attachment>();
        List<Attachment> atmLis_del = new List<Attachment>();
        
        for(id p_id : EmailAttachementMap1.keySet() )   			// Traversing list of inserted email ids in map
        {     
              
        	if(EmailAttachementMap1.get(p_id) != NULL)
            {
                for(attachment attm : [SELECT Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,
                                       IsDeleted,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,
                                       SystemModstamp FROM attachment WHERE ID in : EmailAttachementMap1.get(p_id)])
            	{
                    
                    Attachment atch = new Attachment();
                    
                    atch.Body = attm.Body;
                    atch.ContentType = attm.ContentType;
                    atch.Description = attm.Description;
                    atch.IsPrivate =  attm.IsPrivate;
                    atch.Name  = attm.Name.substringAfterLast('_') ;
                    atch.OwnerId = attm.OwnerId;
                    atch.ParentId = p_id;
                    
                    atmList.add(atch);
                    
                    atmLis_del.add(attm);                    
             	}
        	}  
        }
       
		Insert atmList;
     	Delete atmLis_del;
     	database.emptyRecycleBin(atmLis_del);
   
        del();

        PageReference pgref = new PageReference('/' + csid);
        return pgref;
    }
    
	void del()
    {
        List<Attachment> ParserfilesDelete = new List<Attachment>();
        List<Attachment> EmailfilesDelete = new List<Attachment>();
        
        ParserfilesDelete = [Select Id, ParentId, Name, Body, ContentType From Attachment where name like 'Parser%.txt' and ParentId =: csid];
        EmailfilesDelete = [Select Id, ParentId, Name, Body, ContentType From Attachment where name like 'Email%.pdf' and ParentId =: csid];      
    }
}