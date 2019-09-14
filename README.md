## About

This is Address Book.  Address Book is a web application for managing
your personal address book.  It manages phone numbers, birthdays, addresses, 
and more.

## Setup
```
git clone git://github.com/jwood/addressbook.git
cd addressbook
gem install bundler -v 1.8.0
bundle install

cp config/database.yml.template config/database.yml
# configure your database

cp config/application_config.yml.template config/application_config.yml
# configure the application

bundle exec rake db:migrate
```

## Description
Addressbook consists of 4 main sections:

### Search
Search allows you to search for contacts by full or partial last name.

### Contacts
Contacts is used to manage your, you guessed it, contacts.  The contacts sections allows
you to view and edit all information for a given contact.

### Addresses
Adding a new contact is done by posting the body in a newline separated format. It is then sent to the NLU module -- a thin wrapper around libsbook, TBH, and the parts are returned as Json. The entire thing is stored in the database as a contact, with the raw text as the text field, so that one can go back and correct it. 
### Groups
Groups provide a way to organize your contacts.  Each group has a name, and 
a list of members.  Members can be added via the "Maintain Group Members"
link.  After clicking "Maintain Group Members", you can add/remove one or more
addresses to/from the group.

Once you have members in your group, you can create a printable PDF file of
mailing labels for the members in your group.  Simply specify the type of labels
you will be using, and click the "Create Labels" link.

When printing the labels, be sure your PDF viewer is set to respect the 
margins in the document, and not to "center the document in the page" or 
perform any other types of margin alterations.

## Other Features
* Mobile optimized index and contact details pages
* Authentication using HTTP Basic Auth
 
## LICENSE
MIT License.  See LICENCE for details.

## AUTHOR
John Wood  
[http://johnpwood.net](http://johnpwood.net)  
[john@johnpwood.net](mailto:john@johnpwood.net)  

