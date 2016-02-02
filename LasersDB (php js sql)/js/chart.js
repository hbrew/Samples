// Callback that creates and populates a data table,
// instantiates the chart, passes in the data and
// draws it.
function drawChart(data, titleStr) {

// Create the data table.
var dataTable = google.visualization.arrayToDataTable(data);

// Set chart options
var options = {
  title: titleStr,
  legend: { position: 'bottom' },
  width: 500,
  height: 500
};

// Instantiate and draw our chart, passing in some options.
var chart = new google.visualization.LineChart(document.getElementById('chart_box'));

chart.draw(dataTable, options);
  
}

google.load('visualization', '1', {packages: ['corechart']});