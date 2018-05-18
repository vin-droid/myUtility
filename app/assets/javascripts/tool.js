
function  submitAndResetForm(ele){
   var frm = $(ele).parents("form");
   frm.submit(); // Submit the form
   frm[0].reset();  // Reset all form data
}

$(function() {
  // Handler for .ready() called.
	$('#excel_splitter').validate({
	  debug: true,
	  rules: {
	  	"excel_splitter[filename]": {
	  		required: true,
	  		accept: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
	  	},
	  	"excel_splitter[user_email]": 'required',
	  	"excel_splitter[chunk_size]": 'required',
	  },
	  messages:{
	  	"excel_splitter[filename]":{
	  		required: 'Please select a xlsx file.',
	  		accept: "Please upload a valid file type."
	  	},
	  	"excel_splitter[user_email]": 'Email is required to send zip file if bigger size',
	  	"excel_splitter[chunk_size]": 'Please select a chunk size',
	  },
	  submitHandler: function(form){
	  	form.submit();
	  }
	});
});
