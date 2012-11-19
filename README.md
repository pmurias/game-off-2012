Game is slowly showing up:
http://mosowski.github.com/game-off-2012

Rendering engine: Gremlin-2nd iteration is mostly done, now I'm going to create more assets and finally a gameplay.
I have very limited time after work, so few features I've planned won't be present in a game at the end of November.


Game is going to be a challenging maze filled up with illusions and modes. Use of third dimmension is necessary!


Gremlin engine was made for the purpose of this game. It is my second attempt at writing browser-based 3d rendering engine. It is wirtten totally in ActionScript and uses stage3d for rendering.
It uses upgraded version of my blender model and skeleton exporter. Engine supports texture render targets, postprocess via 
rendering quad with shaders, AGAL shading language wrapper that makes writing stage3d shaders bearable, of course skeletal animation
and scene graph with material-based renderable system. Some of the features still require a lot of work, but now I need more focus on 
gameplay.

--

Open Source projects I'm using in this game:

Blender:
3d modelling, map editing, animation. 


GIMP:
Texture creating and editing.


FlashDevelop:
Great IDE for flash development.


telemetry-utils: https://github.com/adamcath/telemetry-utils
A script which enables Adobe Scout profiling flag.

