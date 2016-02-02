
function reChosen() {
  $(".chosen-select").chosen();
}


$("#more").click(function() {
  $("#selection-template").clone().insertAfter(".selection:last");
  var that = $(".selection").last();
  that.removeAttr("style");
  that.removeAttr("id");
  // that.children(".input-group").children("select.materials_list").addClass("chosen-select");
  that.children(".input-group").children("button").show();
  var n = $(".selection").length;
  if( n > 2) {
    $("button.del").show();
  }
  reChosen();
});

$("#sellmeier-form").on("click", "button.del", function() {
  $(this).parentsUntil("span").remove();
  var n = $(".selection").length;
  if( n <= 2) {
    $("button.del").hide();
  }
});

$("#sellmeier-form").on("change", ".materials_list", function() {
  var selected = $(this).val();
  var that = $(this).parent().children('.axis_list');
  $(that).children("option").not("option:disabled").remove();
  $.get('./?page=sellmeier', function(response){
    var materials = JSON.parse(response);
    $.each(materials[selected], function(index, value) {
      $(that).append($('<option></option>')
        .attr('value', index)
        .text(index)
      );
    });
  });
  reChosen();
})

$("#draw").click(function() {
  var title = $("#title").val();
  var materials = $(".materials_list option:selected").not("option:disabled").map(function(){ return this.value }).get().join(", ");
  materials = materials.split(", ");
  var axis = $(".axis_list option:selected").not("option:disabled").map(function(){ return this.value }).get().join(", ");
  axis = axis.split(", ");
  var selection = {};
  for(var i = 0; i<materials.length; i++) {
    selection[materials[i]] = selection[materials[i]] || [];
    selection[materials[i]].push(axis[i]);
  }
  console.log(JSON.stringify(selection));
  var xmin = encodeURIComponent($('#xmin').val());
  var xmax = encodeURIComponent($('#xmax').val());
  var xstep = encodeURIComponent($('#xstep').val());
  var page = './?page=sellmeier&selection=';
  page = page.concat(encodeURIComponent(JSON.stringify(selection)));
  page = page.concat('&xmin=', xmin, '&xmax=', xmax, '&step=', xstep);
  $.get(page, function(raw_data){
    drawChart(JSON.parse(raw_data), title);
  });
});



// Load materials list into selection box
$.get('./?page=sellmeier', function(response){
  var materials = JSON.parse(response);
  $.each(materials, function(index, value) {
    $('.materials_list').append($('<option></option>')
      .attr('value', index)
      .text(index)
    );
  });
  reChosen();
});

