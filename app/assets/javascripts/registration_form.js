(function() {
  "use strict";
  App.RegistrationForm = {
    initialize: function() {
      var clearUsernameMessage, showUsernameMessage, usernameInput, validateUsername;
      usernameInput = $("form#new_user[action=\"/users\"] input#user_username");
      clearUsernameMessage = function() {
        $("small").remove();
      };
      showUsernameMessage = function(response) {
        var klass;
        klass = response.available ? "no-error" : "error";
        usernameInput.after($("<small class=\"" + klass + "\" style=\"margin-top: -16px;\">" + response.message + "</small>"));
      };
      validateUsername = function(username) {
        var request;
        request = $.get("/user/registrations/check_username?username=" + username);
        request.done(function(response) {
          showUsernameMessage(response);
        });
      };
      usernameInput.on("focusout", function() {
        var username;
        clearUsernameMessage();
        username = usernameInput.val();
        if (username !== "") {
          validateUsername(username);
        }
      });
      jQuery(function() {
  var geozone, geozonesarea, escaped_geozone, loaded_geozone, options;
  loaded_geozone = $('#user_geozone_id :selected').text();
  geozonesarea = $('#user_geozones_area_id').html();
  $('#user_geozones_area_id').parent().hide();
  if (loaded_geozone.length !== 0) {
    geozone = $('#user_geozone_id :selected').text();
    escaped_geozone = geozone.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1');
    options = $(geozonesarea).filter("optgroup[label=" + escaped_geozone + "]").html();
    $('#user_geozones_area_id').html(options);
    $('#user_geozones_area_id').parent().show();
  }
  console.log(geozonesarea);
  return $('#user_geozone_id').change(function() {
    geozone = $('#user_geozone_id :selected').text();
    escaped_geozone = geozone.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1');
    options = $(geozonesarea).filter("optgroup[label=" + escaped_geozone + "]").html();
    console.log(options);
    if (options) {
      $('#user_geozones_area_id').html(options);
      return $('#user_geozones_area_id').parent().show();
    } else {
      $('#user_geozones_area_id').empty();
      return $('#user_geozones_area_id').parent().hide();
    }
  });
});
}
};
}).call(this);
