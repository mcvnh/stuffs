function toggleBorder () {
  browser.tabs.executeScript({
    file: 'borderify.js'
  });
}

browser.browserAction.onClicked.addListener(toggleBorder);
