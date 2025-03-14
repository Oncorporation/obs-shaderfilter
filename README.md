![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads-pre/Oncorporation/obs-shaderfilter/latest/total)

# obs-shaderfilter 1.21

## Introduction

The obs-shaderfilter plugin for [OBS Studio](http://obsproject.com/) is intended to allow users to apply 
their own shaders to OBS sources. This theoretically makes possible some simple effects like drop shadows
that can be implemented strictly in shader code. 

Please note that this plugin may expose a reasonable number of bugs in OBS, as it uses the shader parser and 
the property system in somewhat unusual ways. It should be considered to be in a prerelease state at this time.

## Installation

The binary package mirrors the structure of the OBS Studio installation directory, so you should be able to
just drop its contents alongside an OBS Studio install (usually at C:\Program Files (x86)\obs-studio\). The 
necessary files should look like this: 

    obs-studio
    |---data
    |   |---obs-plugins
    |       |---obs-shaderfilter
    |           |---examples
    |               |---blink.shader
    |               |---border.shader
    |               |---drop_shadow.shader
    |               |---filter-template.effect
    |               |---multiply.shader
    |               |---pulse.effect
    |               |---rectangular_drop_shadow.shader
    |               |---rounded_rect.shader
    |               |---many more...
    |           |---locale
    |               |---en-US.ini
    |---obs-plugins
        |---32bit
        |   |---obs-shaderfilter.dll
        |---64bit
            |---obs-shaderfilter.dll

## Usage

The filter can be added to any source through the "Filters" option when right-clicking on a source. The name
of the filter is "User-defined shader." 

Shaders can either be entered directly in a text box in the filter properties, or loaded from a file. To change 
between the two modes, use the "Load shader text from file" toggle. If you are entering your shader text directly,
note that you will need to use the "Reload effect" button to apply your changes. This can also be used to reload an external file if changes have been made. OBS shaders are written in HLSL.

The option is provided to render extra pixels on each side of the source. This is useful for effects like shadows
that need to render outside the bounds of the original source. 

Normally, all that's required for OBS purposes is a pixel shader, so the plugin will wrap your shader text with a 
standard template to add a basic vertex shader and other boilerplate. If you wish to customize the vertex shader
or other parts of the effect for some reason, you can check the "Use Effect File (.effect)" option. 

Any parameters you add to your shader (defined as `uniform` variables) will be detected by the plugin and exposed
in the properties window to have their values set. Currently, only `int`, `float`, `bool`, `string`, `texture2d`, and `float4`
parameters are supported. (`float4` parameters will be interpreted by the properties window as colors.) `string` is used for 
notes and instructions, but could be used in an effect or shader. Variable names are displayed in the GUI with underscore replaced with space `uniform float Variable_Name` becomes `Variable Name`.

#### Defaults

You set default values as a normal assignment ```uniform string notes = 'my note';```, except for `float4` 
which requires bracket \{\} notation like ```uniform float4 mycolor = { 0.75, 0.75, 0.75, 1.0};``` 

Note that if your shader has syntax errors and fails to compile, OBS does not provide any error messages; you will
simply see your source render nothing at all. In many cases the output of the effect parser will be written to the
OBS log file, which you can view with the Help -> Log Files menu in OBS. 

### Standard parameters

The plugin automatically populates a few parameters which your shader can use. If you choose to override the entire
effect, be sure to define these as `uniform` variables and use them where necessary. (The filter should gracefully 
handle these variables being missing, but the shader may malfunction.)

* **`ViewProj`** (`float4x4`)&mdash;The view/projection matrix. (Standard for all OBS filters.)
* **`image`** (`texture2d`)&mdash;The image to which the filter is being applied, either the original output of 
  the source or the output of the previous filter in the chain. (Standard for all OBS filters.)
* **`elapsed_time`** (`float`)&mdash;The time in seconds which has elapsed since the filter was created. Useful for 
  creating animations.
* **`local_time`** (`float`)&mdash; a random float representing the local time.(1.2)
* **`loops`** (`int`)&mdash; count of how many loops times the shader has rendered a page.(1.2)
* **`rand_f`** (`float`)&mdash; a random float between 0 and 1. changes per frame.
* **`rand_activation_f`** (`float`)&mdash; a random float between 0 and 1. changes per activation, load or change of settings.(1.2)
* **`rand_instance_f`** (`float`)&mdash; a random float between 0 and 1. changes per instance on load.(1.2)
* **`uv_offset`** (`float2`)&mdash;The offset which should be applied to the UV coordinates of the vertices. This is
  used in the standard vertex shader to draw extra pixels on the borders of the source.
* **`uv_scale`** (`float2`)&mdash;The scale which should be applied to the UV coordinates of the vertices. This is 
  used in the standard vertex shader to draw extra pixels on the borders of the source.
* **`uv_size`** (`float2`)&mdash;The height and width of the screen.
* **`uv_pixel_interval`** (`float2`)&mdash;This is the size in UV coordinates of an individual texel. You can use
  this to convert the UV coordinates of the pixel being processed to the coordinates of that texel in the source
  texture, or otherwise scale UV coordinate distances into texel distances.

### New Options in version 1.1+
* **`Use Slider Inputs`**&mdash; Converts Integer and floating point inputs into sliders in the UI.
* **`Use Shader Time`**&mdash;Start the effect from the loadtime of the shader, not the start up time of OBS Studio.
* **`Override Entire Effect`** renamed **`Use Effect File (.effect)`** in UI and documentation
* Textures moved from the shaders folder to the textures folder. Existing textures are not deleted so as to not disrupt you current scenes.(1.2)
* 1.21 minor bug fixes and shader/effect updates
  
### Example shaders

Several examples are provided in the plugin's *data/examples* folder. These can be used as-is for some hopefully
useful common tasks, or used as a reference in developing your own shaders. Note that the *.shader* and *.effect* 
extensions are for clarity only, and have no specific meaning to the plugin. Text files with any extension can be
loaded. In a standard, *.effect* files include a vertex shader and *.shader* only has a pixel shader.

I recommend *.shader* as they do not require `Use Effect File (.effect)` as pixel shaders, while *.effect* signifies vertex shaders with `Use Effect File (.effect)` required.

* *animated_texture.effect*&mdash; Animates a texture with polar sizing and color options
* *ascii.shader*&mdash; a little example of ascii art
* *background_removal.effect*&mdash; simple implementation of background removal. Optional color space corrections
* *blink.shader*&mdash;A shader that fades the opacity of the output in and out over time, with a configurable speed
  multiplier. Demonstrates the user of the `elapsed_time` parameter.
* *bloom.shader / glow.shader*&mdash; simple shaders to add glow or bloom effects, the glow shader has some additional options for animation
* *cartoon.effect* (Use Effect File (.effect))&mdash; Simple Cartooning based on hue and steps of detail value.
* *border.shader*&mdash;A shader that adds a solid border to all extra pixels outside the bounds of the input. 
* *drop_shadow.shader*&mdash;A shader that adds a basic drop shadow to the input. Note that this is done with a simple
  uniform blur, so it won't look quite as good as a proper Gaussian blur. This is also an O(N&sup2;) blur on the size 
  of the blur, so be very conscious of your GPU usage with a large blur size.
* *edge_detection.shader*&mdash;A shader that detects edges of color. Includes support for alpha channels.   
* *filter_template.effect* (Use Effect File (.effect))&mdash;A copy of the default effect used by the plugin, which simply
  renders the input directly to the output after scaling UVs to reflect any extra border pixels. This is useful as a starting
  point for developing new effects, especially those that might need a custom vertex shader. (Note that modifying this file will
  not affect the internal effect template used by the plugin.)
* *filter_template.shader* &mdash;A copy of the default shader used by the plugin, which simply
  renders the input directly to the output after scaling UVs to reflect any extra border pixels. This is useful as a starting
  point for developing new pixel shaders. (Note that modifying this file will not affect the internal effect template used by the plugin.)
* *fire.shader*&mdash; A fire example converted from shadertoy with lots of added options.[youtube example](https://youtu.be/jcTsC0zSNAs)
* *gradient.shader*&mdash; This shader has a little brother *simple_gradient.shader*, but lets you choose three colors and animate gradients.
* *glitch_analog.shader*&mdash;A shader that creates glitch effects similar to analog signal issues. Includes support for alpha channel.   
* *hexagon.shader*&mdash;A shader that creates a grid of hexagons with several options for you to set. This is an example of making shapes.
* *gaussian-simple.shader*&mdash; A simple gaussian shader for bluring. Really implements closer to a box shader. 
* *luminance.shader*&mdash;A shader that adds an alpha layer based on brightness instead of color. Extremely useful for making live 
  video special effects, like replacing backgrounds or foregrounds.
* *matrix.effect*&mdash; The cat is a glitch conversion from shadertoy. Updated with several configurable options.(1.2)
* *multiply.shader*&mdash;A shader that multiplies the input by another image specified in the parameters. Demonstrates the use 
  of user-defined `texture2d` parameters.
* *night_sky.shader*&mdash; Animated moon, clouds, stars background(1.2)
* *perlin_noise.effect* (Use Effect File (.effect))&mdash;An effect generates perlin_noise, used to make water, clouds and glitch effects. 
* *pulse.effect* (Use Effect File (.effect))&mdash;An effect that varies the size of the output over time. This demonstrates 
  a custom vertex shader that manipulates the position of the rendered vertices based on user data. Note that moving the vertices 
  in the vertex shader will not affect the logical size of the source in OBS, and this may mean that pixels outside the source's
  bounds will get cut off by later filters in the filter chain.
* *rainbow.shader*&mdash;Creates Rainbow effects, animated, rotating, horizontal or vertical. This is an expensive process and limiters
  are implemented.[https://www.twitch.tv/videos/404349212](https://www.twitch.tv/videos/404349212) 
* *rectangular_drop_shadow.shader*&mdash;A shader that renders an optimized drop shadow for sources that are opaque and rectangular. 
  Pixels inside the bounds of the input are treated as solid; pixels outside are treated as opaque. The complexity of the blur
  does not increase with its size, so you should be able to make your blur size as large as you like wtihout affecting
  GPU load. 
* *remove_partial_pixels.shader*&mdash;A shader that removes pixels with partial alpha, excellent for cleaning up green screens.
* *repeat.effect* (Use Effect File (.effect))&mdash;Duplicates the input video as many times as you like and organizes on the screen.
* *repeat_texture.effect* (Use Effect File (.effect))&mdash; As above, but add a texture input to repeat instead of the input source.
* *rgb_color_wheel.shader&mdash;A rotatable RGB color wheel!
* *rotatoe.effect* (Use Effect File (.effect))&mdash;A test rotation effect
* *rounded_rect.shader*&mdash;A shader that rounds the corners of the input, optionally adding a border outside the rounded 
  edges.
* *rounded_stroke.shader*&mdash;A shader that rounds the corners of the input, optionally adding a border outside the rounded [https://youtu.be/J8mQIEKvWt0](https://youtu.be/J8mQIEKvWt0)
  edges. Updated by Exeldro. Several shaders have been upgraded with Apply To Specific Color for you to animate borders.
* *scan_line.shader*&mdash;An effect that creates old style tv scan lines, for glitch style effects. 
* *selective_color.shader*&mdash;Create black and white effects with some colorization. (defaults: .4,.03,.25,.25, 5.0, true,true, true, true. cuttoff higher = less color, 0 = all 1 = none)
* *shake.effect* (Use Effect File (.effect))&mdash;creates random screen glitch style shake. Keep the random_scale low for small (0.2-1) for small
  jerky movements and larger for less often big jumps.
* *spotlight.shader*&mdash;Creates a stationary or animated spotlight effect with color options, speed of animation and glitch
* *shine.shader*&mdash;Add shine / glow to any element, use the transition luma wipes (obs-studio\plugins\obs-transitions\data\luma_wipes *SOME NEW WIPES INCLUDED IN THIS RELEASE ZIP*) or create your own, 
   also includes a glitch (using rand_f), hide/reveal, reverse and ease, start adjustment and stop adjustment
   video explanation of usage [Twitch.tv/videos/396724980](https://www.twitch.tv/videos/396724980)
* *vignetting.shader*&mdash;A shader that reduces opacity further from the center of the image. inner radius is the start and outer radius is the end.
    suggested default settings is opacity 0.5, innerRadius = 0.5, outerRadius = 1.2
* *zoom_blur.shader*&mdash;A shader that creates a zoom with blur effect based on a number of samples and magnitude of each sample. It also includes
   an animation with or without easing and a glitch option. Set speed to zero to not use animation. Suggested values are 15 samples and 30-50 magnitude.
* *other*&mdash; We have far too many shaders to list. Please check [Examples folder](https://github.com/Oncorporation/obs-shaderfilter/tree/master/data/examples)
   or find me on discord, as I have many additional filters for fixing input problems. 

## Building

If you wish to build the obs-shaderfilter plugin from source, you should just need [CMake](https://cmake.org/) 
and the OBS Studio libraries and headers.

* [obs-shaderfilter source repository](https://github.com/Oncorporation/obs-shaderfilter)
* [OBS Studio source repository](https://github.com/jp9000/obs-studio)

I don't believe that the OBS project provides prebuilt libraries; you're probably going to have the best luck
building your own OBS binaries from the source. Refer to the OBS repository for more information on that.

When building in CMake, the OBSSourcePath configuration value should refer to the libobs subfolder 
in the OBS source release. The build pipeline will look for headers in this location, and for libraries
in a "build" folder relative to that path (where the OBS build process puts them). 

Installation logic is provided through CMake as well; you can set the CMAKE_INSTALL_PREFIX configuration value
to choose the folder to which the files will be copied. You can also manually copy all files to the locations
described above.

## License

This project is licensed under the "[Unlicense](http://unlicense.org/)", because copy[right|left] is a hideous
mess to deal with and I don't like it. 

## Donations

I appreciate donations/follows/subs on twitch.tv/surn , [Bitcoin](bitcoin:3HAN6eVxv81URgj51wxeCd9eMhg3tvriro) or [LiteCoin](litecoin:MQFVTFCZUtcucZJzQCyiSDTirrWGqTyCjM).
Why Crypto? We do not have free speech when we live in fear of everything being taken away on an authoritarian whim, a criminal plot or an outraged mob?
