
function  submitAndResetForm(ele){
   var frm = $(ele).parents("form");
   frm.submit(); // Submit the form
   frm[0].reset();  // Reset all form data
}