const init = () => $("select.reload-on-change").change(function() {
  this.form.submit();
});

$(document).on('turbo:load', init);
