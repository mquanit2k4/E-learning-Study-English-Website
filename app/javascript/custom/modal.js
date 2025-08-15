(function() {
  function showInjectedModal(holder) {
    // Ưu tiên Semantic UI
    var $ui = $(holder).find('.ui.modal');
    if ($ui.length) { $ui.modal('show'); return; }

    // Fallback cho Bootstrap
    var $bs = $(holder).find('.modal');
    if ($bs.length) { $bs.modal('show'); }
  }

  function initRemoteModals() {
    var holder = '#modal-holder';

    // click link mở modal
    $(document).off('click.remoteModal').on('click.remoteModal', 'a[data-modal]', function(e) {
      e.preventDefault();
      var url = this.href;

      $.get(url).done(function(html) {
        $(holder).html(html);
        showInjectedModal(holder);
      });
    });

    // submit form trong modal (nếu có)
    $(document).off('ajax:success.remoteModal').on('ajax:success.remoteModal', 'form[data-modal]', function(event){
      var detail = event.detail || [];
      var data   = detail[0], xhr = detail[2];
      var loc    = xhr && xhr.getResponseHeader && xhr.getResponseHeader('Location');

      if (loc) {
        window.location = loc;
      } else {
        $(holder).html(data);
        showInjectedModal(holder);
      }
    });
  }

  // Turbo + lần load đầu
  document.addEventListener('turbo:load', initRemoteModals);
  document.addEventListener('DOMContentLoaded', initRemoteModals);
})();
