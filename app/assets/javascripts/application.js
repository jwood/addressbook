// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require_tree .

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
  $('#createLabelsLink').html(newLinkHtml);
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

$(document).on('ajaxSend', showSpinner);
$(document).on('ajaxComplete', hideSpinner);

$(document).on('click', '.edit_address_link', editAddress);
$(document).on('click', '.cancel_multiple_address_confirmation_link', closeFancybox);
$(document).on('click', '.maintain_group_members_link', displayMaintainGroupMembers);
$(document).on('click', '.exclude_all_members_link', excludeAllMembers);
$(document).on('click', '.exclude_selected_members_link', excludeSelectedMembers);
$(document).on('click', '.include_selected_members_link', includeSelectedMembers);
$(document).on('click', '.include_all_members_link', includeAllMembers);

