// Spellchecking error style
user_pref("ui.SpellCheckerUnderlineStyle", 3);

// Check spelling in every user fields
user_pref("layout.spellcheckDefault", 2);

// I don't want to give you my credit card amaz0n.ru
user_pref("network.IDN_show_punycode", true);

// Do not hide URL info
user_pref("browser.urlbar.trimURLs", false);

// Browser's CSS customization (REQUIRED for TreeTabStyle)
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

user_pref("accessibility.blockautorefresh", true);
user_pref("extensions.pocket.enabled", false);
user_pref("dom.event.clipboardevents.enabled", false);

// Disable full screen exit warning
user_pref("full-screen-api.warning.timeout", false);

// Disable HTTP password field warning
user_pref("security.insecure_field_warning.contextual.enabled", false);

// Highlight CTRL+F results
user_pref("findbar.modalHighlight", true);

// Trying to block media auto play
// Note that the API has changed recently and is not very well documented...
user_pref("media.autoplay.default", 5);

// Disable screenshot builtin addon
user_pref("extensions.screenshots.disabled", true);

// Firefox 76 - partially disable annoying megabar
user_pref("browser.urlbar.update1", false);
user_pref("browser.urlbar.update1.view.stripHttps", false);

