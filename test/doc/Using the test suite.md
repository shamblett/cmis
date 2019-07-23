
# CMIS Interactive Test Suite Usage

Testing of this client is performed through an interactive test suite allowing
connection to CMIS repositories, browsing of information thereof and the creation/
deletion of documents and folders.

Before starting please enter the details needed in the cmis_test_config file if
you intend to use this as a short cut to filling in the details on then test page.

The testing has been carried out against the Alfresco CMIS browser binding test repository
[here](http://cmis.alfresco.com/cmisbrowser) although any compliant repository can be used.

The page layout is designed to be easy to use, however, the output/pictures directory
contains screen shots of the type of output you should see at each stage of the testing.

Twitters Bootstrap framework is used via the Dart bootjack package to give a consistent
layout.

Note that information returned by the repository chosen is deliberately limited
so as not to unduly lengthen the page.

'Clear' buttons in each of the sections do just that, ie they clear the last information
returned and any alerts.

## Connect
Enter the details shown or input these into the config file, if you are using a proxy
you MUST indicate this using the proxy checkbox. Press connect, if successful you will
get a 'Cmis Session successfully created' message in the alert section.


## Repository details
After successful connection press the 'Get Repository Information' button, you will see
above this a list of repositories on the selected server, click one of the repositories,
this will be transferred into the 'Using Repository-Id:' box. Then press 'Get Repository Information'
again. This time repository details will be displayed for the selected repository.

You MUST select a repository as described above for the rest of the tests to work.

## Type Information
Gets information about the type supplied. To test this initially use 'cmis:folder',
this will be more useful as more objects are discovered further on.

## Root Folder Information
Select the info you want from the root folder, i.e documents, folders or both and press
'Get Root Folder Contents'. The list returned is limited however it should provide enough 
to use in the rest of the testing.

## Folder Information
Select an objectId for a folder from the output of Root Folder Information and copy this
into the 'Folder Id' text box. You can then list the various attributes of the folder using
the supplied buttons.

## Document Information
Again, select an objectId for a document from the output of Root Folder Information and copy this
into the 'Document Id' text box. Pressing 'Get Document' retrieves and shows the contents of
the document. Note this may be binary.

## Create/Delete Folder
Enter a name and an optional path for a folder you wish to create, if no path is entered the
root folder is used. Paths can be obtained from the 'Path:' identifier of the root folder listing
above(note, no preceeding '\' is needed). Press create and the folder will be created.
Enter the object Id of a folder that you wish to delete and pres delete.

## Create/Delete Document
As for the folder creation above enter a name and an optional path for the document you wish
to create, also either enter some text in the 'Document Contents' testx area or upload a file
using the 'Content File Name' button as the document content. Note that if you enter text in the
'Document Contents' text area this will be used in preference to the file upload. 

Press create and the document will be created. To check the contents are correct copy the objectId
from the created document details and check this using the Document Information section. You should see
the contents you entered when creating the document.

To delete a document proceeed as for the delete folder above but use the document objectId.

You can re-check folder/document creation at any time using the Root Folder Information section
and Folder Information sections above. Also any type information output(Object Type Id) can be checked 
using the Type Information section.

## Query
Enter a CMIS query into the 'Enter a Query' text area and press 'Do the Query'. The results of the query
are presented below the section. Examples of the CMIS query language can be found [here.](http://wiki.alfresco.com/wiki/CMIS_Query_Language)

Alert areas under each of the sections will inform you of success/fail and the reason the server gave for
a fail.



