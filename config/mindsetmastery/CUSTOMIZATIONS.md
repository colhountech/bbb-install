# Mindset Mastery BBB customizations

Tracked configuration for `bbb.colhountech.com` (BBB 3.0.32) and the Mindset Mastery app join flow.

## Server (`bbb.colhountech.com`)

**Canonical script:** `config/mindsetmastery/apply-config.sh`  
**Live path:** `/etc/bigbluebutton/bbb-conf/apply-config.sh`  
**Re-applied automatically** on every `bbb-install.sh` upgrade via `bbb-conf --check`.

### Deploy

```bash
./config/mindsetmastery/deploy-apply-config.sh
ssh root@78.47.120.165 bbb-conf --restart   # if html5 client needs a restart
```

### Presentation

| Setting | Value | Purpose |
|---------|-------|---------|
| Default PDF | `/root/Mindset.Mastery.Presentation.pdf` | Copied to all four BBB blank/default presentation paths |

### Layout (`bbb-html5.yml`)

| Setting | Value | Purpose |
|---------|-------|---------|
| `hidePresentationOnJoin` | `true` | Don't show slides panel on join |
| `showSessionDetailsOnJoin` | `false` | Skip session details modal |

### Audio / join flow (`bbb-html5.yml`)

| Setting | Value | Purpose |
|---------|-------|---------|
| `userSettingsStorage` | `local` | Remember mic/camera in browser localStorage |
| `skipCheck` | `true` | Skip audio setup dialog |
| `skipCheckOnJoin` | `true` | Skip audio check on join |
| `skipEchoTestIfPreviousDevice` | `true` | Skip echo test when device was used before |
| `listenOnlyMode` | `false` | Don't default to listen-only |

### Video (`bbb-html5.yml`)

| Setting | Value | Purpose |
|---------|-------|---------|
| `skipVideoPreview` | **`false`** | Must stay false — `true` breaks webcam modal |
| `skipVideoPreviewOnFirstJoin` | **`false`** | Must stay false — same bug |
| `skipVideoPreviewIfPreviousDevice` | `true` | Skip preview only for returning users with a saved camera |

### Other (`bbb-html5.yml` + `bbb-web.properties`)

| Setting | Value | Purpose |
|---------|-------|---------|
| `notes.enabled` | `false` | Disable shared notes in html5 client |
| `disabledFeatures` | `sharedNotes` | Disable shared notes at API level |
| `defaultWelcomeMessageFooter` | *(empty)* | Remove default footer text |

### Presentation PDF paths (all receive the same file)

- `/usr/share/bigbluebutton/blank/blank-presentation.pdf`
- `/var/bigbluebutton/blank/blank-presentation.pdf`
- `/var/www/bigbluebutton-default/default.pdf`
- `/var/www/bigbluebutton-default/assets/default.pdf` ← **this is the path BBB actually serves**

---

## App (`mindsetmastery.app`)

Repo: `MindsetMasteryApp` — deploy with `./deploy.sh` on the app VPS.

### Join flow

All join paths route through `/Join?code={meetingId}`:

1. **Rooms list / share links** → `RoomService.GetJoinUrlAsync()` returns `/Join?code=...`
2. **`/Join`** creates the BBB meeting (moderators only), then builds a signed BBB join URL with userdata
3. User is redirected to BBB

**Files:**

- `MindsetMasteryApp/Services/RoomService.cs` — join links point to `/Join`
- `MindsetMasteryApp/Pages/Join/Index.cshtml.cs` — meeting create + signed BBB redirect
- `MindsetMasteryApp/Pages/Rooms/Index.cshtml.cs` — `OnGetJoinAsync` routes via `/Join`
- `MindsetMasteryApp/Pages/Rooms/Details.cshtml.cs` — `logoutURL` on create

### Join userdata (`BigBlueButtonService.GetJoinUrlAsync`)

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `userdata-bbb_skip_check_audio` | `true` | Skip audio setup |
| `userdata-bbb_skip_check_audio_on_first_join` | `true` | Skip on first join too |
| `userdata-bbb_skip_echotest_if_previous_device` | `true` | Skip echo test if device known |
| `userdata-bbb_skip_video_preview_if_previous_device` | `true` | Skip video preview for returning users |
| `userdata-bbb_show_session_details_on_join` | `false` | Hide session details |
| `logoutURL` | `https://mindsetmastery.app/Rooms` | Return users to Rooms after logout |

**Do not add** `userdata-bbb_skip_video_preview` — same webcam hang as server-side `skipVideoPreview: true`.

### Create meeting (`BigBlueButtonService.CreateMeetingAsync`)

- `logoutURL` → `https://mindsetmastery.app/Rooms`
- `meta_endCallbackUrl` → app BBB callback for attendance/CPD

---

## Lessons learned

1. **`skipVideoPreview: true` breaks manual webcam sharing** — modal shows "Finding webcams" forever. Use `skipVideoPreviewIfPreviousDevice` only.
2. **Default PDF** must be copied to `/var/www/bigbluebutton-default/assets/default.pdf`, not just the parent `default.pdf`.
3. **`userdata-bbb_auto_join_audio`** was removed — it opened the audio modal instead of skipping it.
4. **All joins must go through `/Join`** so userdata is always attached to the signed BBB URL.