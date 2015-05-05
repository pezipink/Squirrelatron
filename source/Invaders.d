module Invaders;

import derelict.sdl2.sdl;
import std.random;
import std.math;

// invaders will be 3*3 grid with no alpha channel
// the first 2 columns are mirrored on the opposite side
// with the third being the centre

// data will be stored in RGB with no A channel 
// this is 24 bits per pixel, 27 bytes for 3*3

byte[27] = 
	[0xFF,0xFF,0x0,
	 0xFF,0xFF,0x0
	 0xFF,0xFF,0x0]
//surface=SDL_CreateRGBSurfaceFrom(pixeldata, //pointer to the pixels
//3,//Width
//5,//Height
//24,//Depth (bits per pixel)
//3*3,//Pitch (width*depth_in_bytes, in this case)
//0x0000FF,//Red mask
//0x00FF00,//Green mask
//0xFF0000,//Blue mask
//0);      //Alpha mask (no alpha in this format)
//  