function attachOnCloseListeners() {
  (document.querySelectorAll(".notification .delete") || []).forEach(($delete) => {
    const $notification = $delete.parentNode

    $delete.addEventListener("click", () => {
      $notification.parentNode.removeChild($notification)
    });
  });
}

document.addEventListener('DOMContentLoaded', attachOnCloseListeners)
document.addEventListener('turbo:render', attachOnCloseListeners)