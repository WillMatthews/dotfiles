// user.js — persistent Firefox preferences for this profile.
// Applied on every startup; overrides matching values in prefs.js.
// To revert a setting, either delete its line here AND reset it via
// about:config, or just delete it here and accept whatever prefs.js holds.
// Reference: https://kb.mozillazine.org/User.js_file

// =============================================================
// Startup & sessions
// =============================================================
user_pref("browser.startup.page", 3);                          // 3 = restore previous session
user_pref("browser.startup.homepage", "about:home");
user_pref("browser.newtabpage.enabled", true);
user_pref("browser.aboutwelcome.enabled", false);              // skip first-run tour
user_pref("browser.shell.checkDefaultBrowser", false);

// =============================================================
// Telemetry, "experiments", and data collection — off
// =============================================================
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);

// =============================================================
// "Suggestions" / sponsored content in the new tab and URL bar
// =============================================================
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.contentblocking.report.lockwise.enabled", false);
user_pref("browser.contentblocking.report.monitor.enabled", false);

// =============================================================
// Tracking & privacy
// =============================================================
user_pref("browser.contentblocking.category", "strict");       // Enhanced Tracking Protection: Strict
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.globalprivacycontrol.enabled", true);       // GPC signal
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("network.cookie.cookieBehavior", 5);                 // 5 = reject cross-site + state partitioning
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);    // strip path+query from cross-origin referers

// =============================================================
// Search
// =============================================================
user_pref("browser.search.suggest.enabled", true);             // suggestions from the default engine
user_pref("browser.urlbar.suggest.searches", true);
user_pref("browser.urlbar.trimURLs", false);                   // show full URL incl. scheme
user_pref("browser.urlbar.trending.featureGate", false);       // no "trending" rows
user_pref("browser.search.separatePrivateDefault.ui.enabled", true);

// =============================================================
// Downloads
// =============================================================
user_pref("browser.download.useDownloadDir", false);           // always ask where to save
user_pref("browser.download.alwaysOpenPanel", false);

// =============================================================
// UI / quality of life
// =============================================================
user_pref("browser.tabs.closeWindowWithLastTab", false);
user_pref("browser.tabs.loadBookmarksInTabs", true);
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);         // Ctrl+Tab = MRU order
user_pref("findbar.highlightAll", true);
user_pref("layout.spellcheckDefault", 2);                      // spellcheck in single-line inputs too
user_pref("ui.key.menuAccessKeyFocuses", false);               // stop Alt from grabbing the menu bar

// Enable userChrome.css / userContent.css (drop them in chrome/ next to this file)
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// =============================================================
// "Aged Brass" theme — see ~/Documents/THEMES.md
// Force dark color-scheme so page UA styles match the chrome.
// =============================================================
user_pref("ui.systemUsesDarkTheme", 1);                        // tell Firefox the OS is dark
user_pref("layout.css.prefers-color-scheme.content-override", 0); // 0 = dark for sites
user_pref("browser.theme.dark-private-windows", false);        // same look in private windows
user_pref("browser.display.background_color", "#2A211B");      // bg of about:blank etc.
user_pref("browser.display.foreground_color", "#EFE3CE");
user_pref("browser.anchor_color", "#FFC332");
user_pref("browser.visited_color", "#D6A12A");
user_pref("browser.active_color", "#E9994A");
// Tab preview thumbs etc. — tell the engine our base is dark
user_pref("browser.in-content.dark-mode", true);

// =============================================================
// Performance
// =============================================================
user_pref("browser.sessionstore.interval", 60000);             // save session every 60s, not 15s
// user_pref("gfx.webrender.all", true);                       // force WebRender (usually already on)
// user_pref("media.ffmpeg.vaapi.enabled", true);              // hw video decode under Wayland/VAAPI

// =============================================================
// Misc cruft removal
// =============================================================
user_pref("extensions.pocket.enabled", false);
user_pref("identity.fxaccounts.enabled", true);                // keep Sync; set false to hide entirely
user_pref("browser.discovery.enabled", false);                 // no "recommended extensions"
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
