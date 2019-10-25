$(function() {
  function calcClusterVcpus() {
    vcpusPerVm = $('.instance-type-description .vcpu-count').data('vcpus');
    vmCount = clusterSize.getValue();
    $('#cluster-cpu-count').html(vcpusPerVm * vmCount);
  }

  function calcClusterRam() {
    bytesPerVm = $('.instance-type-description .ram-size').data('bytes');
    siUnits = $('.instance-type-description .ram-size').data('si');
    vmCount = clusterSize.getValue();
    totalBytes = bytesPerVm * vmCount;
    $('#cluster-ram-size').attr('data-bytes', totalBytes);
    $('#cluster-ram-size').html(humanFileSize(totalBytes, siUnits))
  }

  var updateClusterSize = function() {
    calcClusterVcpus();
    calcClusterRam();
  }

  var clusterSize = $('#cluster_instance_count').slider()
  .on('slide change', updateClusterSize).data('slider');

  $('input[name="cluster[instance_type]"]').click(function() {
    definition = $(this).siblings('.definition').html();
    $('.instance-type-description').html(definition);
    ramSize = $('.instance-type-description .ram-size')
    ramSize.html(
      humanFileSize(ramSize.data('bytes'), ramSize.data('si'))
    )

    if (this.id === 'cluster_instance_type_custom') {
      $('.cluster-cpu-count,.cluster-ram-size').hide();
      $('input#cluster_instance_type_custom[type="text"]').
      show().focus();
    } else {
      $('input#cluster_instance_type_custom[type="text"]').
      val("").hide();
      updateClusterSize();
      $('.cluster-cpu-count,.cluster-ram-size').show();
    }
  });

  // kick things off
  $('input[name="cluster[instance_type]"][checked="checked"]').click();

  // only submit once
  $('form#new_cluster').submit(function(){
    $(this).find('input[type=submit]').prop('disabled', true);
  });
});
