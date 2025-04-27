# AudioManager - Advanced Audio Management for Godot

**AudioManager** is a powerful plugin for the Godot Engine that simplifies and enhances audio management in your game. It supports **Omni**, **2D**, and **3D** audio types, allowing you to control playback, trimming, looping, and various audio properties from a single node. With this plugin, you can easily manage multiple audio tracks, apply effects like distance-based attenuation, and control playback programmatically.

## Features

- **Unified Audio Control**: Manage Omni, 2D, and 3D audio from a single node.
- **Audio Trimming**: Set custom start and end times for each audio track.
- **Looping Support**: Enable looping for any audio, even if the file doesn’t natively support it.
- **Loop Offset**: Add an offset for smooth looping in non-seamless audio files.
- **Playback Control**: Play, pause, stop, and resume audio by name or in bulk.
- **Distance-Based Audio**: Apply volume attenuation based on the listener’s distance (for 2D and 3D audio).
- **Customizable Properties**: Adjust volume, pitch, max distance, and more for each audio track.
- **Auto-Play**: Start audio playback automatically when the scene loads.
- **Editor Integration**: Configure all options directly in the Godot editor.

## How It Works

The **AudioManager** centralizes audio management in Godot, allowing you to define and control multiple audio tracks (Omni, 2D, and 3D) within a single node. It uses custom resource types (`AudioMangerOmni`, `AudioManger2D`, `AudioManger3D`) to configure each track’s properties, such as trimming, looping, and playback settings. The plugin internally handles the creation and control of audio players and timers, providing a simple API for programmatic playback control.

The AudioManager node has a parent property (`target_parent_audios`) for 2D and 3D audio, and if this property is not set, the 2D and 3D audio are inserted into the parent node from where the AudioManager was inserted. This enables features such as audio attenuation and other positional effects based on the position of the AudioManager's parent node.

In addition to 2D and 3D audio, you have the `omni` option which behaves like Godot's native **AudioStreamPlayer** node.

Note: You cannot configure clipper and loop for AudioStreamRandomizer, AudioStreamSynchronized and AudioStreamPlaylist.

## Installation

1. Download the plugin files.
2. Extract the files into the `res://addons/` directory of your Godot project.
3. Enable the plugin in Godot by going to `Project > Project Settings > Plugins` and activating **AudioManager**.

## Usage

### Adding Audio Tracks

1. Add an **AudioManager** node to your scene.
2. In the **Inspector**, configure the audio lists:
   - **Omni**: For global audio (e.g., background music).
   - **2D**: For positional audio in 2D space.
   - **3D**: For positional audio in 3D space.
3. For each audio type, add entries to the respective arrays (`audios_omni`, `audios_2d`, `audios_3d`).
4. Configure each audio entry with properties like `audio_name`, `audio_stream`, `start_time`, `end_time`, `loop`, `auto_play`, etc.

### Controlling Audio Playback

You can control audio playback using the following methods:

#### Omni Audio

```cpp
# Play omni audio
$audio_manager.play_audio_omni("audio_name")
```

```cpp
# Pause omni audio
$audio_manager.pause_audio_omni("audio_name")
```

```cpp
# Resume omni audio
$audio_manager.continue_audio_omni("audio_name")
```

```cpp
# Stop omni audio
$audio_manager.stop_audio_omni("audio_name")
```

#### 2D Audio

```cpp
# Play 2d audio
$audio_manager.play_audio_2d("audio_name")
```

```cpp
# Pause 2d audio
$audio_manager.pause_audio_2d("audio_name")
```

```cpp
# Resume 2d audio
$audio_manager.continue_audio_2d("audio_name")
```

```cpp
# Stop 2d audio
$audio_manager.stop_audio_2d("audio_name")
```

#### 3D Audio

```cpp
# Play 3d audio
$audio_manager.play_audio_3d("audio_name")
```

```cpp
# Pause 3d audio
$audio_manager.pause_audio_3d("audio_name")
```

```cpp
# Resume 3d audio
$audio_manager.continue_audio_3d("audio_name")
```

```cpp
# Stop 3d audio
$audio_manager.stop_audio_3d("audio_name")
```

### Bulk Playback Control

You can also control all audio tracks of a specific type or all types at once:

- **Play All Audio**:

  ```cpp
   # Plays all Omni, 2D, and 3D audio
   $audio_manager.play_all()
  ```

  ```cpp
   # Plays all Omni audio
   $audio_manager.play_all_omni()
  ```

  ```cpp
   # Plays all 2D audio
   $audio_manager.play_all_2d()
  ```

  ```cpp
   # Plays all 3D audio
   $audio_manager.play_all_3d()
  ```

- **Stop All Audio**:

  ```cpp
   # Stops all Omni, 2D, and 3D audio
   $audio_manager.stop_all()
  ```

  ```cpp
   # Stops all Omni audio
   $audio_manager.stop_all_omni()
  ```

  ```cpp
   # Stops all 2D audio
   $audio_manager.stop_all_2d()
  ```

  ```cpp
   # Stops all 3D audio
   $audio_manager.stop_all_3d()
  ```

- **Pause All Audio**:

  ```cpp
   # Pauses all Omni, 2D, and 3D audio
   $audio_manager.pause_all()
  ```

  ```cpp
   # Pauses all Omni audio
   $audio_manager.pause_all_omni()
  ```

  ```cpp
   # Pauses all 2D audio
   $audio_manager.pause_all_2d()
  ```

  ```cpp
   # Pauses all 3D audio
   $audio_manager.pause_all_3d()
  ```

- **Resume All Audio**:

  ```cpp
  # Resumes all paused Omni, 2D, and 3D audio
  $audio_manager.continue_all()
  ```

  ```cpp
  # Resumes all paused Omni audio
  $audio_manager.continue_all_omni()
  ```

  ```cpp
  # Resumes all paused 2D audio
  $audio_manager.continue_all_2d()
  ```

  ```cpp
  # Resumes all paused 3D audio
  $audio_manager.continue_all_3d()
  ```

### Retrieving Audio Resources

You can access audio resources directly to modify their properties at runtime:

- **Get Audio Resource**:

  ```v
  var audio_omni = $audio_manager.get_audio_omni("audio_name")
  ```

  ```v
  var audio_2d = $audio_manager.get_audio_2d("audio_name")
  ```

  ```v
  var audio_3d = $audio_manager.get_audio_3d("audio_name")
  ```

## Configuration

Each audio track can be configured with the following properties:

- **Audio Name**: A unique identifier for the audio track.
- **Audio Stream**: The audio file to be played.
- **Start Time**: The time (in seconds) to start playing the audio.
- **End Time**: The time (in seconds) to stop the audio.
- **Use Clipper**: Whether to use trimming (start and end times).
- **Loop**: Enables looping for the audio.
- **Auto-Play**: Plays the audio automatically when the scene loads.
- **Volume DB**: The volume level in decibels.
- **Pitch Scale**: The pitch adjustment.
- **Max Distance** (2D and 3D): The maximum distance for audio attenuation.
- **Max Polyphony**: The maximum number of simultaneous streams.
- **Panning Strength** (2D and 3D): The intensity of the panning effect.
- **Bus**: (Omni, 2D and 3D)
- **Playback Type**: (Omni, 2D and 3D)
- **Area Mask**: (2D and 3D)
- **Attenuation**: (2D)
- **Emission Angle Enabled**: (3D)
- **Emission Angle Degrees**: (3D)
- **Emission Angle Filter Attenuation db**: (3D)
- **Attenuation Filter Cutoff hz**: (3D)
- **Attenuation Filter db**: (3D)
- **Doppler Tracking**: (3D)
- **unit_size**: (3D)
- **loop_offset**: (Omni, 2D and 3D)
- **mix_target**: (Omni)

These properties can be set directly in the Godot editor via the **Inspector** by selecting an audio entry in the **AudioManager** node.

### Positional Audio Configuration (2D and 3D)

The `target_parent_audios_2d` and `target_parent_audios_3d` properties define the parent node where 2D and 3D audio players are instantiated, allowing audio to have specific positions in 2D or 3D scenes. This is crucial for effects like distance-based volume attenuation, panning (in 2D), and spatial audio (in 3D):

- **`target_parent_audios_2d`**: Defines the parent node (type `Node2D`) for 2D audio players. Link it to a node with a position in the 2D scene (e.g., a character) to enable positional effects like volume variation and panning based on the listener’s distance and location.
- **`target_parent_audios_3d`**: Defines the parent node (type `Node3D`) for 3D audio players. Link it to a node with a position in 3D space (e.g., an object or enemy) to enable spatial audio effects like volume attenuation, sound direction, and Doppler, depending on the listener’s relative position.

#### Important: Audio Listener Requirement

For audio to be heard and positional effects to work, **you must** have an audio listener configured in the scene:

- For **2D audio**: Add an `AudioListener2D` node or set a 2D camera as the listener (enable the `current` property).
- For **3D audio**: Add an `AudioListener3D` node or set a 3D camera as the listener (enable the `current` property).
  **Warning**: Without an audio listener (`AudioListener2D` or `AudioListener3D`) or a properly configured camera, audio will not play correctly, and distance or positional effects will not function.

## Examples

### Example 1: Playing Background Music (Omni Audio)

1. Add an **AudioManager** node to your scene.
2. In the **Inspector**, under **Omni**, add a new audio entry.
3. Set **Audio Name** to `"background_music"`.
4. Assign an audio file to **Audio Stream**.
5. Set **Auto-Play** to `true` to start playback when the scene loads.

Alternatively, play it programmatically:

```v
$audio_manager.play_audio_omni("background_music")
```

### Example 2: Playing a 3D Sound Effect

1. Add an **AudioManager** node to your scene.
2. Set **Target Parent Audios 3D** to the audio source node (e.g., a character or object).
3. In the **Inspector**, under **3D**, add a new audio entry.
4. Set **Audio Name** to `"explosion"`.
5. Assign an audio file to **Audio Stream**.
6. Configure **Max Distance** to control how far the sound can be heard.

Play the sound when needed:

```v
$audio_manager.play_audio_3d("explosion")
```

### Example 3: Looping a Trimmed Audio Clip

1. Add an **AudioManager** node to your scene.
2. In the **Inspector**, under **Omni**, add a new audio entry.
3. Set **Audio Name** to `"looped_clip"`.
4. Assign an audio file to **Audio Stream**.
5. Set **Use Clipper** to `true`.
6. Set **Start Time** to `2.0` seconds and **End Time** to `10.0` seconds.
7. Set **Loop** to `true`.

This will play the audio from 2 to 10 seconds and loop it continuously.

## Screenshots

**Screenshot AudioManager**

![Screenshot 1](./addons/audio_manager/images/screenshots/screenshot_1.png)

**Screenshot Omni AudioManager**

![Screenshot omni](./addons/audio_manager/images/screenshots/screenshot_omni.png)

**Screenshot 2D AudioManager**

![Screenshot omni](./addons/audio_manager/images/screenshots/screenshot_2d.png)

**Screenshot 3D AudioManager**

![Screenshot omni](./addons/audio_manager/images/screenshots/screenshot_3d.png)

## License

This plugin is available under the [MIT License](LICENSE.md).

## Contact

For support or feedback, reach out at [saulocoexi@gmail.com].
