# Tool Reference

> Current MCP tool reference for Termux MCP Server.

## Overview

The server exposes Termux:API capabilities as MCP tools. Tool names are stable identifiers used by MCP clients and agents.

> **Important:** The implementation is still being hardened. Do not assume every tool is safe for unattended autonomous execution.

---

## `battery_status`

**Purpose:** Read current device battery information.

**Arguments:** none.

**Underlying command:**

```bash
termux-battery-status
```

**Typical use cases:** battery monitoring, charging recommendations, device health workflows.

**Risk:** Low.

---

## `vibrate`

**Purpose:** Trigger device vibration.

**Arguments:**

| Name | Type | Optional | Description |
|---|---|---:|---|
| `duration` | number | yes | Duration in milliseconds |
| `force` | boolean | yes | Force vibration in silent mode |

**Underlying command:** `termux-vibrate`

**Use cases:** haptic feedback, agent completion signals, accessibility workflows.

**Risk:** Low.

---

## `toast`

**Purpose:** Display a toast message on Android.

**Arguments:**

| Name | Type | Required | Description |
|---|---|---:|---|
| `text` | string | yes | Message |
| `short` | boolean | no | Use short duration |

**Underlying command:** `termux-toast`

**Use cases:** local agent notifications, build completion, automation status.

**Risk:** Low.

---

## `tts_speak`

**Purpose:** Speak text through Android's text-to-speech engine.

**Arguments:** `text: string`

**Underlying command:** `termux-tts-speak`

**Use cases:** accessibility, spoken alerts, hands-free agents.

**Risk:** Low, but it creates an audible side effect.

---

## `torch`

**Purpose:** Toggle the device flashlight.

**Arguments:** `on: boolean`

**Underlying command:** `termux-torch on|off`

**Use cases:** hardware demonstrations, accessibility, signaling.

**Risk:** Low.

---

## `clipboard_get`

**Purpose:** Read the Android clipboard.

**Arguments:** none.

**Underlying command:** `termux-clipboard-get`

**Use cases:** developer workflows, text extraction, agent-assisted transformations.

**Risk:** Medium because clipboard contents may contain passwords, tokens, private messages, or other secrets.

---

## `clipboard_set`

**Purpose:** Replace clipboard contents.

**Arguments:** `text: string`

**Underlying command:** `termux-clipboard-set`

**Use cases:** copying generated commands, URLs, text, or transformed content.

**Risk:** Medium because it modifies user state.

---

## `sms_send`

**Purpose:** Send an SMS through the Android device.

**Arguments:**

| Name | Type | Required | Description |
|---|---|---:|---|
| `number` | string | yes | Recipient number(s) |
| `message` | string | yes | Message content |

**Underlying command:** `termux-sms-send`

**Use cases:** alerts, controlled notification workflows, personal automation.

**Risk: HIGH.** This is an external side effect. Autonomous use should require explicit policy and confirmation.

---

## `sms_list`

**Purpose:** Read SMS messages.

**Arguments:**

| Name | Type | Optional | Description |
|---|---|---:|---|
| `limit` | number | yes | Maximum number of messages |
| `offset` | number | yes | Offset in result set |

**Underlying command:** `termux-sms-list`

**Use cases:** personal message summarization, controlled notification processing.

**Risk: High** because messages may contain sensitive personal information.

---

## `contact_list`

**Purpose:** Read contacts from the device.

**Arguments:** none.

**Underlying command:** `termux-contact-list`

**Use cases:** contact-aware personal assistants.

**Risk: High** because contact data is sensitive personal information.

---

## `location_get`

**Purpose:** Retrieve Android location information.

**Arguments:**

| Name | Values | Optional |
|---|---|---:|
| `provider` | `gps`, `network`, `passive` | yes |
| `request` | `once`, `last`, `updates` | yes |

**Underlying command:** `termux-location`

**Use cases:** field applications, location-aware automation, navigation workflows.

**Risk: High** because location is sensitive data.

---

## `notification_list`

**Purpose:** Read current device notifications.

**Arguments:** none.

**Underlying command:** `termux-notification-list`

**Use cases:** notification summarization, personal assistant workflows.

**Risk: Medium/High** depending on notification content.

---

## `wifi_info`

**Purpose:** Read Wi-Fi connection information.

**Arguments:** none.

**Underlying command:** `termux-wifi-connectioninfo`

**Use cases:** connectivity diagnostics and device-aware automation.

**Risk:** Low/Medium depending on how output is used.

---

## `camera_capture`

**Purpose:** Capture a photo.

**Arguments:**

| Name | Type | Required | Description |
|---|---|---:|---|
| `camera_id` | string | no | Camera identifier |
| `output_file` | string | yes | Destination path |

**Underlying command:** `termux-camera-photo`

**Use cases:** OCR, visual inspection, field data collection, accessibility.

**Risk: High** because camera access is sensitive and the operation creates a real-world side effect.

---

## `ocr_image`

**Purpose:** Extract text from an image using Tesseract.

**Arguments:** `image_path: string`

**Underlying command:** `tesseract <image> stdout`

**Requirement:** Tesseract installed in Termux.

**Use cases:** document extraction, error reading, labels, screenshots, accessibility.

**Risk:** Depends on image source and filesystem access.

---

## `share_text`

**Purpose:** Start Android sharing for text.

**Arguments:**

| Name | Type | Required | Description |
|---|---|---:|---|
| `text` | string | yes | Content to share |
| `title` | string | no | Share UI title |

**Underlying command:** `termux-share`

**Use cases:** sending generated content to another Android application.

**Risk:** Medium/High because sharing can cross application boundaries.

---

## `sensor_list`

**Purpose:** List sensors available on the device.

**Arguments:** none.

**Underlying command:** `termux-sensor -l`

**Use cases:** discovering device capabilities before starting a sensor workflow.

**Risk:** Low.

---

## `sensor_data`

**Purpose:** Read one sample from a selected sensor.

**Arguments:** `sensor: string`

**Underlying command:** `termux-sensor -n 1 -s <sensor>`

**Use cases:** orientation, motion, environmental measurements, device experiments.

**Risk:** Low/Medium depending on sensor data.

---

## `speak_battery_status`

**Purpose:** Demonstration tool that reads battery status and speaks a human-readable result.

**Flow:**

```text
battery_status
      |
      v
parse JSON
      |
      v
build sentence
      |
      v
tts_speak
```

**Use cases:** demonstrating multi-step tool composition.

**Risk:** Low.

---

# Capability matrix

| Tool | Read | Modify device | Sensitive data | External side effect | Recommended unattended use |
|---|---:|---:|---:|---:|---|
| battery_status | yes | no | low | no | yes |
| vibrate | no | yes | low | yes | usually |
| toast | no | yes | low | yes | usually |
| tts_speak | no | yes | low | yes | usually |
| torch | no | yes | low | yes | usually |
| clipboard_get | yes | no | **high** | no | policy required |
| clipboard_set | no | yes | medium | yes | policy required |
| sms_send | no | yes | **high** | **yes** | **confirmation** |
| sms_list | yes | no | **high** | no | policy required |
| contact_list | yes | no | **high** | no | policy required |
| location_get | yes | no | **high** | no | policy required |
| notification_list | yes | no | medium/high | no | policy required |
| wifi_info | yes | no | medium | no | usually |
| camera_capture | no | yes | **high** | **yes** | confirmation |
| ocr_image | yes | no | depends | no | usually |
| share_text | no | yes | depends | **yes** | confirmation |
| sensor_list | yes | no | low | no | yes |
| sensor_data | yes | no | depends | no | usually |
| speak_battery_status | yes | yes | low | yes | usually |
