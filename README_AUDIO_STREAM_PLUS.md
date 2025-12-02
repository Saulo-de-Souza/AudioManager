<h1 align="center"> Audio Stream Plus </h1>

<div align="center">
  <img src="addons/audio_manager/icons/icon_plus.svg" width="200" height="200">
</div>

### Audio Enhancement Node for Godot

**AudioStreamPlus** is a powerful extension of Godot's native AudioStreamPlayer node, designed to provide enhanced audio playback capabilities with advanced features such as clipper support, improved loop control, and much more. It maintains full compatibility with the Godot audio system, adding a rich set of customizable options.

---

## Overview

**AudioStreamPlus** enhances the standard AudioStreamPlayer with features such as:

### 1- Audio clipping support:

> In the Godot Engine inspector, choose the start and end times for playback.

### 2- Signal between loops:

> AudioStreamPlus outputs a signal between each loop when using audio clipping with loop enabled. Furthermore, it has been implemented to output signals from special Streams that Godot itself does not output, such as AudioStreamInteractive and others. Now with AudioStreamPlus, you will have these signals!

### 3- Pause signals:

> In the Godot Engine inspector, you can configure the audio to pause whenever the game window loses focus and resume playback when it regains focus. This also applies to web applications; in fact, if you are using looped audio clipping, we advise enabling this option due to web limitations.

---

## Installation

Place AudioStreamPlus in your project's addons/ directory.
Enable the plugin in **Project Settings** > **Plugins**.
Use it just like a regular AudioStreamPlayer node.

---

## Properties

| Property                    | Type                        | Description                                                                |
| --------------------------- | --------------------------- | -------------------------------------------------------------------------- |
| `stream`                    | AudioStream                 | The audio stream to play. Setting this stops all currently playing sounds. |
| `use_clipper`               | bool                        | Enables or disables clipper functionality.                                 |
| `start_time`                | float                       | Start time in seconds when use_clipper is enabled.                         |
| `end_time`                  | float                       | End time in seconds when use_clipper is enabled.                           |
| `clipper_ignore_time_scale` | bool                        | Ignore time scaling for audio clipping.                                    |
| `autoplay`                  | bool                        | If true, automatically plays the stream when entering the tree.            |
| `loop`                      | bool                        | Enables looping of the audio.                                              |
| `volume_db`                 | float                       | Volume in decibels.                                                        |
| `pitch_scale`               | float                       | Pitch multiplier.                                                          |
| `max_polyphony`             | int                         | Maximum number of sounds that can play simultaneously.                     |
| `pause_onblur`              | bool                        | Pauses the audio when the game window or browser tab loses focus.          |
| `mix_target`                | AudioStreamPlayer.MixTarget | Audio mix target (stereo, surround, etc.).                                 |
| `playback_type`             | AudioServer.PlaybackType    | Forces playback type.                                                      |
| `bus`                       | StringName                  | Audio bus to route the sound to.                                           |
| `is_playing`                | bool                        | Returns whether audio is currently playing or not.                         |
| `is_paused`                 | bool                        | Returns whether the audio is paused or not.                                |

---

## Methods

| Method                                         | Description                                       |
| ---------------------------------------------- | ------------------------------------------------- |
| `play(from_position: float = 0.0)`             | Starts playing the audio from a given position.   |
| `stop()`                                       | Stops the currently playing audio.                |
| `pause()`                                      | Pauses the audio playback.                        |
| `unpause()`                                    | Resumes paused audio.                             |
| `get_length()`                                 | Returns the total length of the audio stream.     |
| `get_length_with_weight()`                     | Returns the length adjusted for pitch or clipper. |
| `get_playback_position(add_mix: bool = false)` | Returns the current playback position.            |
| `get_stream_playback()`                        | Returns the current AudioStreamPlayback.          |
| `has_stream_playback()`                        | Returns true if audio is currently playing.       |
| `seek(to_position: float)`                     | Seeks to a specific position in the audio.        |
| `get_audio_stream_player()`                    | Returns the internal AudioStreamPlayer node.      |

---

## Signals

| Signal                             | Description                                                                          |
| ---------------------------------- | ------------------------------------------------------------------------------------ |
| `finished`                         | Emitted when a sound finishes playing. This only works for playback without looping. |
| `finished_loop_in_clipper`         | Emitted when a clipper loop finishes.                                                |
| `pause_unpause_focus(pause: bool)` | Emitted when audio is paused/unpaused due to focus loss.                             |

---

## Example Usage

Basic Setup:

```gdscript
# Create new AudioStreamPlus
var audio_plus = AudioStreamPlus.new()

# Add a stream
audio_plus.stream = preload("res://assets/audios/door.mp3")

# Add to the node tree
add_child(audio_plus)

# Play the audio
audio_plus.play()

```

Using Clipper:

```gdscript
# Enable the use of audio clipping.
audio_plus.use_clipper = true
audio_plus.start_time = 0.7
audio_plus.end_time = 1.2

```

Loop with Clipper:

```gdscript
# Enable the use of audio clipping.
audio_plus.use_clipper = true
audio_plus.start_time = 0.7
audio_plus.end_time = 1.2
audio_plus.loop = true


```

Connect to the loop signal:

```gdscript
# Create new AudioStreamPlus
var audio_plus = AudioStreamPlus.new()
audio_plus.stream = preload("res://assets/audios/door.mp3")
add_child(audio_plus)

# Enable the use of audio clipping.
audio_plus.use_clipper = true
audio_plus.start_time = 0.7
audio_plus.end_time = 1.2
audio_plus.loop = true

# Connect to the loop signal
audio_plus.finished_loop_in_clipper.connect(func():
    print("Loop...")
    )

# Play the audio
audio_plus.play()

```

---

## Configuration Warnings

AudioStreamPlus will show warnings in the editor when:

- No stream is assigned.
- start_time is greater than or equal to end_time.
- The bus is invalid or empty.
- Incompatible stream types are used with clipper or loop.

---

## Notes

> **AudioStreamInteractive** does not support pitch scaling or polyphony. This is already native to the Godot class.

> The looping behavior of **AudioStreamPlaylist** is overridden by this plugin's loop property. If you set loop to true in a playlist, it will loop.

> **Clipper** is not compatible with **AudioStreamInteractive**, **AudioStreamRandomizer**, **AudioStreamSynchronized**, and **AudioStreamPlaylist**.

---

## Screenshots

!["icon plus"](screenshots/audio_stream_plus_1.png)
