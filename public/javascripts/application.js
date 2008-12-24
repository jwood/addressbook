dojo.require("dojo.widget.AccordionContainer");
dojo.require("dojo.widget.ContentPane");
dojo.require("dojo.widget.LayoutContainer");

/* 
 * Code to disable/enable the second contact for an address 
 */
adjustSelectableContacts = function() {
  var INDIVIDUAL = 1;
  var SINGLE_PARENT = 5;
  var addressContact2 = document.getElementById("addressContact2");
  var addressTypeElement = document.getElementById("addressType");

  if (addressTypeElement.value != INDIVIDUAL &&
      addressTypeElement.value != SINGLE_PARENT) {
    addressContact2.style.visibility = "visible";
  } else {
    addressContact2.style.visibility = "hidden";
  }
}

/* 
 * Opens a popup window and stores a reference to the main window 
 */
openWindow = function(url, name, dimensions) {
  var w = window.open(url, name, dimensions);
  w.dummy = window;
}

/* 
 * Updates the passed in id in the main window with the html passed in 
 */
updateInOriginalWindow = function(id, html, popup_name) {
  var w = window.open("", popup_name);
  var otherBrowser = w.dummy;
  var element = otherBrowser.document.getElementById(id);
  Element.update(element, html);
}

/* 
 * Closes the specified popup window
 */
closeWindow = function(name) {
  var w = window.open("", name);
  w.close();
}

/*
 * Updates the create labels link to specify the proper label type
 */
updateCreateLabelsLink = function(url) {
  var selector = document.getElementById('labelTypeSelector');
  var newLinkHtml = '<a href="' + url + '?label_type=' + selector.value + 
    '" onclick="window.open(this.href,\'label_window\',\'label_window\');return false;"' + 
    '>Create Labels</a>';
  Element.update('createLabelsLink', newLinkHtml);
}
