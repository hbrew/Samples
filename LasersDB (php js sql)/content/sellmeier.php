<div id="chart_box"></div>
<div id="sellmeier-form">
<span class="selection" id="selection-template" style="display:none;">
<div class="input-group sellmeier-selection">
  <select data-placeholder="Choose materials" class="form-control materials_list">
  	<option value="" disabled selected>Choose materials</option>
  </select>
  <select data-placeholder="Optical axis" class="form-control axis_list">
  	<option value="" disabled selected>Optical axis</option>
  </select>
  <button type="button" class="form-control btn btn-danger del">X</button>
</div>
</span>

<span class="selection">
<div class="input-group sellmeier-selection">
  <select data-placeholder="Choose materials" class="form-control materials_list">
  	<option value="" disabled selected>Choose materials</option>
  </select>
  <select data-placeholder="Optical axis" class="form-control axis_list">
  	<option value="" disabled selected>Optical axis</option>
  </select>
  <button type="button" class="form-control btn btn-danger del">X</button>
</div>
</span>
<button type="button" style="width:200px" class="btn form-control" id="more">More Materials</button>
<br />
<br />
<div class="input-group">
	<span class="input-group-addon" id="basic-addon1">Title</span>
	<input type="text" id="title" class="form-control" />
</div>
<div class="input-group">
	<span class="input-group-addon">&#955; min (&#956;m)</span>
	<input type="text" id="xmin" class="form-control" />
	<span class="input-group-addon">&#955; max (&#956;m)</span>
	<input type="text" id="xmax" class="form-control" />
	<span class="input-group-addon">&#955; step (&#956;m)</span>
	<input type="text" id="xstep" class="form-control" />
</div>
<br />
<button type="button" style="width:100px" class="btn form-control" id="draw">Draw</button>
</div>