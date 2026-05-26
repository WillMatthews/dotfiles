// user.js — persistent Thunderbird preferences for this profile.
// Applied on every startup; overrides matching values in prefs.js.
// To revert a setting, delete its line here AND reset it via
// about:config (Settings > General > Config Editor).
// Reference: https://kb.mozillazine.org/User.js_file

// =============================================================
// "Aged Brass" theme — see ~/Documents/THEMES.md, theme #4.
// =============================================================

// Load chrome/userChrome.css (and userContent.css if ever added) from this
// profile. Without this, the brass theme silently does nothing.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Tell Thunderbird the UI should be dark, so the built-in light-dark() colour
// pairs we don't explicitly override (native form controls, some icons,
// scrollbars) resolve to their dark variants and match the brass chrome.
user_pref("ui.systemUsesDarkTheme", 1);

// Keep the built-in light/dark auto theme out of the way; userChrome.css drives
// the palette. (TB still respects ui.systemUsesDarkTheme above for widgets.)

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
