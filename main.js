const { env } = process;
const { app, session, BrowserWindow } = require("electron");
const axios = require("axios");

const user = env.USER || "viewer";
const password = env.PASSWORD || "default";
const host = env.HOST || "http://localhost";
const playlistId = env.PLAYLIST_ID || "eb4348b0-894e-4f36-b286-b99bb674576c";

async function createWindow() {
  session.defaultSession.clearStorageData();

  const mainWindow = new BrowserWindow({
    x: 0,
    y: 0,
    width: 1920,
    height: 1080,
    kiosk: true,
    webPreferences: {
      devTools: false,
    },
  });

  try {
    const credentials = { user, password };

    const res = await axios.post(`${host}/login`, credentials, {
      headers: {
        "Content-Type": "application/json",
        "Content-Length": JSON.stringify(credentials).length,
      },
    });

    res.headers["set-cookie"].forEach((cookie) => {
      const fields = cookie.split("; ");
      const name = fields[0].split("=")[0];
      const value = fields[0].split("=")[1];
      const path = fields[1].split("=")[1];
      const maxAge = fields[2].split("=")[1];
      session.defaultSession.cookies.set({
        url: `${host}`,
        name,
        value,
        path,
      });
    });

    mainWindow.webContents.loadURL(
      `${host}/playlists/play/${playlistId}?kiosk`
    );
  } catch (err) {
    console.log(err);
  }
}

app.whenReady().then(createWindow);

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

app.on("child-process-gone", (error, details) => {
  console.log(JSON.stringify(error));
  console.log(JSON.stringify(details));
  app.exit(1);
});

app.on("render-process-gone", (error, _, details) => {
  console.log(JSON.stringify(error));
  console.log(JSON.stringify(details));
  app.exit(1);
});
