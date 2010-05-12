dojo.require("dijit.layout.AccordionContainer");
dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.layout.BorderContainer");

function adjustSelectableContacts() {
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

function updateCreateLabelsLink(url) {
  var newLinkHtml = '<a href="' + url + '?label_type=' + jQuery('#labelTypeSelector').val() + '" target="new"' + '>Create Labels</a>';
  $('createLabelsLink').update(newLinkHtml);
}

function includeSelectedMembers() {
  $('not_included').childElements().each(function(s) {
    if (s.selected == true) {
      $('included').insert({'bottom': s});
    }
  });
}

function excludeSelectedMembers() {
  $('included').childElements().each(function(s) {
    if (s.selected == true) {
      $('not_included').insert({'bottom': s});
    }
  });
}

function includeAllMembers() {
  $('not_included').childElements().each(function(s) {
    $('included').insert({'bottom': s});
  });
}

function excludeAllMembers() {
  $('included').childElements().each(function(s) {
    $('not_included').insert({'bottom': s});
  });
}

function selectAllIncludedGroupMembers() {
  $('included').childElements().each(function(s) {
    s.selected = true;
  });
}

function selectExistingAddressOption() {
  $('existing_address').checked = true;
}

function selectSpecifiedAddressOption() {
  $('specified_address').checked = true;
}

function editAddress() {
  $('specifyAddress').show();
  $('address').hide();
}

function changeAddressForAll() {
  $("submit_id").value = "yes";
  closeFancybox();
}

function changeAddressForSpecified() {
  $("submit_id").value = "no";
  closeFancybox();
}

function closeFancybox() {
  jQuery.fancybox.close();
}

function displayMaintainGroupMembers() {
  $('displayGroupMembers').hide();
  $('editGroupMembers').show();
}
