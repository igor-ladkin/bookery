function attachOnCloseListeners() {
  (document.querySelectorAll(".notification .delete") || []).forEach(($delete) => {
    const $notification = $delete.parentNode
    const removeNotification = () => $notification.parentNode.removeChild($notification)

    $delete.addEventListener("click", removeNotification)
    setTimeout(removeNotification, 3000)
  });
}

document.addEventListener('DOMContentLoaded', attachOnCloseListeners)
document.addEventListener('turbo:render', attachOnCloseListeners)