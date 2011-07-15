## About

This is Address Book.  Address Book is a web application for managing
your personal address book.  It manages phone numbers, birthdays, addresses, 
and more.

## Setup
* git clone git://github.com/jwood/addressbook.git
* cd addressbook
* gem install bundler
* bundle install
* Copy config/database.yml.template to config/database.yml and configure your database
* rake db:migrate

## Ruby 1.8.x only
Addressbook currently has a dependency on a library that is not compatible with Ruby 1.9.
Until that dependency is updated (or replaced), addressbook will require Ruby 1.8.x to
run.

## Setup on [Heroku](http://heroku.com/) - Free hosting
* [Create your Heroku Account](http://heroku.com/signup) and [Install the Heroku gem](http://docs.heroku.com/heroku-command)
* git clone git://github.com/jwood/addressbook.git
* cd addressbook
* heroku create
* git push heroku master
* heroku rake db:migrate

## Demo
[http://jwood-addressbook.heroku.com/](http://jwood-addressbook.heroku.com/)  

## Description
Addressbook consists of 4 main sections:

### Search
Search allows you to search for contacts by full or partial last name.

### Contacts
Contacts is used to manage your, you guessed it, contacts.  The contacts sections allows
you to view and edit all information for a given contact.

### Addresses
Addresses is used to manage the addresses of your contacts.  Each address has
an address type (Individual, Family, Married Couple, Unmarried Couple, etc).
The address type is used to determine the "addressee" of the address.  For
example, if Joe Smith and Jane Smith share an address, the addressee
would be the following for the specific address types:

"Individual" - "Mr. Joe Smith"  
"Family" - "Mr. & Mrs. Joe & Jane Smith & Family"  
"Married Couple" - "Mr. & Mrs. Joe & Jane Smith"  
"Unmarried Couple" - "Mr. Joe Smith & Ms. Jane Smith"  
"Single Parent" - "Mr. Joe Smith & Family"  

The home phone is also stored along with the address, since home phones are
specific to a home.  
 
You can specify the two main contacts for an address by selecting the primary
and secondary contact on the address details page.  These contacts are used
in constructing the addressee (see above).
 
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

