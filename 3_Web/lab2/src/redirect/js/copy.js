const RESET_DELAY_MS = 2000;

document.addEventListener("click", async (event) => {
  const button = event.target.closest(".copy-btn");

  if (!button) {
    return;
  }

  const source = document.getElementById(button.dataset.copyTarget);

  if (!source) {
    return;
  }

  const text = source.textContent.trim();

  try {
    await navigator.clipboard.writeText(text);
  } catch {
    // Буфер обмена недоступен без защищённого контекста: выделяем текст вручную.
    const selection = window.getSelection();
    const range = document.createRange();
    range.selectNodeContents(source);
    selection.removeAllRanges();
    selection.addRange(range);
    return;
  }

  button.textContent = "Скопировано";
  button.classList.add("is-copied");

  setTimeout(() => {
    button.textContent = "Скопировать";
    button.classList.remove("is-copied");
  }, RESET_DELAY_MS);
});
