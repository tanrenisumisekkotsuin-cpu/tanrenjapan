// 正式URLが決まったら、この links の値だけ差し替えます。
// 管理画面URL、編集用URL、ログインURLは入れないでください。
const links = {
  apparel: "https://nscjnay55kouhz9wcz9m.stores.jp",
  contact: "https://forms.gle/SpMeMapQcsuRV6778", // TANREN 体験・相談受付フォーム（Googleフォーム回答用URL）
  kidsTrial: "https://forms.gle/Bf1s3pVYn6crX6wh7", // 子ども体験・見学フォーム（Googleフォーム回答用URL）
  propertyInfo: "https://forms.gle/gBuoN7ks5XfWYyxu5", // 空き家・古民家・土地情報募集フォーム（下部ブロック専用）
  clinic: "",
  line: "",
  instagram: "",
};

// 上部リンクメニューに表示する項目（propertyInfo は下部「空き家・古民家・土地情報の募集」専用）
const navLinkKeys = ["apparel", "contact", "clinic", "line", "instagram"];

function isReadyUrl(url) {
  return (
    typeof url === "string" &&
    url.trim() !== "" &&
    url !== "#" &&
    url !== "GOOGLE_FORM_URL_HERE"
  );
}

function normalizeNavLinkStyles() {
  document.querySelectorAll("nav.links [data-link-key]").forEach((button) => {
    button.classList.remove("primary");
    if (button.dataset.linkKey === "contact") {
      button.classList.add("link-button-featured");
    } else {
      button.classList.remove("link-button-featured");
    }
    if (!button.classList.contains("secondary")) {
      button.classList.add("secondary");
    }
  });
}

function removePropertyInfoFromNav() {
  document.querySelectorAll("nav.links [data-link-key]").forEach((button) => {
    if (!navLinkKeys.includes(button.dataset.linkKey)) {
      button.remove();
    }
  });
}

function bindLinkButtons() {
  document.querySelectorAll("[data-link-key]").forEach((button) => {
    const key = button.dataset.linkKey;
    const url = links[key] || "";
    const ready = isReadyUrl(url);
    const statusEl = button.querySelector(".link-status");

    if (ready) {
      button.setAttribute("href", url);
      button.setAttribute("target", "_blank");
      button.setAttribute("rel", "noopener noreferrer");
      if (statusEl) {
        statusEl.hidden = true;
      }
    } else {
      button.setAttribute("href", "#");
      button.classList.add("is-preparing");
      button.setAttribute("aria-disabled", "true");
      if (statusEl) {
        statusEl.hidden = false;
        statusEl.textContent = "準備中";
      }
    }

    button.addEventListener("click", (event) => {
      if (!ready) {
        event.preventDefault();
      }
    });
  });
}

removePropertyInfoFromNav();
normalizeNavLinkStyles();
bindLinkButtons();
