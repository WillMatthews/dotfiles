// user.js — persistent Thunderbird preferences for this profile.
// Applied on every startup; overrides matching values in prefs.js.
// To revert a setting, delete its line here AND reset it via
// about:config (Settings > General > Config Editor).
// Reference: https://kb.mozillazine.org/User.js_file

// =============================================================
// "Aged Brass" theme — see ~/Documents/THEMES.md, theme #4.
// =============================================================

// Load chrome/userChrome.css + chrome/userContent.css from this profile.
// Without this, the brass theme silently does nothing.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Tell Thunderbird the UI should be dark, so the built-in light-dark() colour
// pairs we don't explicitly override (native form controls, some icons,
// scrollbars) resolve to their dark variants and match the brass chrome.
// NB: on Linux/GTK this is often NOT honoured for the *chrome* prefers-color-
// scheme (TB follows the GTK theme), which is why userChrome.css pins the grey
// leaf tokens directly rather than relying on this.
user_pref("ui.systemUsesDarkTheme", 1);

// NB: we deliberately do NOT set layout.css.prefers-color-scheme.content-override
// here. That would force *every* content document dark, including received email
// bodies — recolouring plain-text and unstyled mail and breaking sender styling.
// Instead, userContent.css forces colour-scheme:dark scoped to about:addressbook
// only, so mail rendering is left exactly as the sender intended.

// =============================================================
// Telemetry & data collection — off (parity with the Firefox profile).
// =============================================================
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);

// =============================================================
// Devtools — needed to inspect the brass theme live when a TB
// version bump renames a token or selector (see userChrome.css header).
// =============================================================
user_pref("devtools.chrome.enabled", true);
user_pref("devtools.debugger.remote-enabled", true);
