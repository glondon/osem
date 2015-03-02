$(function () {
  $(document).ready(function() {
    $("[class='switch-checkbox']").bootstrapSwitch();

    $('input[class="switch-checkbox"]').on('switchChange.bootstrapSwitch', function(event, state) {

      //var conference = $(this).attr('conference');
      var model = $(this).attr('model');
      var attribute = $(this).attr('attribute');

      url = '/admin/conference/' + this.name + '/' + model + 's/' + this.value + '?' + model + '[' + attribute + ']=' + state

      $.ajax({
        url: url,
        type: 'PATCH',
        dataType: 'script'
      });
    });
  });
});
