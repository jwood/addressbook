dojo.require("dijit.layout.AccordionContainer");
dojo.require("dijit.layout.ContentPane");
dojo.require("dijit.layout.BorderContainer");

function adjustSelectableContacts() {
  var addressTypeDescription = $("#addressType option[value='" + $("#addressType").val() + "']").text();
  if (addressTypeDescription == "Individual" || addressTypeDescription == "Single Parent") {
    $(".secondary_contact_header").hide();
    $(".secondary_contact_column").hide();
  } else {
    $(".secondary_contact_header").show();
    $(".secondary_contact_column").show();
  }
}

function updateCreateLabelsLink(url) {
  var newLinkHtml = '<a href="' + url + '?label_type=' + jQuery('#labelTypeSelector').val() + '" target="new"' + '>Create Labels</a>';
  $('#createLabelsLink').update(newLinkHtml);
}

function includeSelectedMembers() {
  $('#not_included').children().each(function(i) {
    if (this.selected == true) {
      $('#included').append(this);
    }
  });
}

function excludeSelectedMembers() {
  $('#included').children().each(function(i) {
    if (this.selected == true) {
      $('#not_included').append(this);
    }
  });
}

function includeAllMembers() {
  $('#not_included').children().each(function(i) {
    $('#included').append(this);
  });
}

function excludeAllMembers() {
  $('#included').children().each(function(i) {
    $('#not_included').append(this);
  });
}

function selectAllIncludedGroupMembers() {
  $('#included').children().each(function(i) {
    this.selected = true;
  });
}

function selectExistingAddressOption() {
  $('#existing_address').checked = true;
}

function selectSpecifiedAddressOption() {
  $('#specified_address').checked = true;
}

function editAddress() {
  $('#specifyAddress').show();
  $('#address').hide();
}

function changeAddressForAll() {
  $("#submit_id").val("yes");
  closeFancybox();
}

function changeAddressForSpecified() {
  $("#submit_id").val("no");
  closeFancybox();
}

function closeFancybox() {
  jQuery.fancybox.close();
}

function displayMaintainGroupMembers() {
  $('#displayGroupMembers').hide();
  $('#editGroupMembers').show();
}

function showSpinner() {
  $('#spinner').css({"visibility":"visible"});
}

function hideSpinner() {
  $('#spinner').css({"visibility":"hidden"});
}

$(".ajax_request").
  live('ajax:before', function() { showSpinner(); }).
  live('ajax:complete', function() { hideSpinner(); });

