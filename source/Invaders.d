module Invaders;

import derelict.sdl2.sdl;
import std.random;
import std.math;

static immutable int invader_width = 3;
static immutable int invader_height = 5;
static immutable int invader_full_width = invader_width * 2 - 1;
static immutable int max_invaders = 2 ^^ (invader_width * invader_height);

ubyte[] rgb;
 

static this() {
	rgb.length = invader_full_width*invader_height*4*max_invaders;
	
	int rgbindex = 0;
	void AddRgbData(ubyte r,ubyte g,ubyte b,ubyte a) {
			rgb[rgbindex++] = r;
			rgb[rgbindex++] = g;
			rgb[rgbindex++] = b;
			rgb[rgbindex++] = 0xFF; 
	}

	for(int invader = 0; invader < max_invaders; invader++ ){	
		ubyte[]stack;
		
		ubyte r = cast(ubyte)uniform(50,200);
		ubyte g = cast(ubyte)uniform(50,200);
		ubyte b = cast(ubyte)uniform(50,200);
		
		for(int i=0; i<invader_width*invader_height; i++) {
			if(i % invader_width == 0 && stack.length > 0){
				stack = stack[0..$-4];
				while(stack.length > 0){
					AddRgbData(stack[$-1],stack[$-2],stack[$-3],stack[$-4]);
					stack = stack[0..$-4];
				}
			}
			bool set = (invader & (1 << i)) > 0; 
			if(set){
				AddRgbData(r,g,b,0xFF);		
				stack ~= [0xFF,b,g,r];
			}
			else{
				AddRgbData(0,0,0,0);
				stack ~= [0,0,0,0];			
			}			
		}
		stack = stack[0..$-4];
		while(stack.length > 0){
			AddRgbData(stack[$-1],stack[$-2],stack[$-3],stack[$-4]);
			stack = stack[0..$-4];
		}
	}
}  

SDL_Texture* GetInvaderTexture(SDL_Renderer* renderer) {
	static assert(invader_width % 2 != 0);
	enum FullWidth = invader_width * 2 - 1;	
	std.stdio.writeln(FullWidth*max_invaders);
	SDL_Surface* surface = 
		SDL_CreateRGBSurfaceFrom(cast(void*)rgb, //pointer to the pixels
			FullWidth*max_invaders,
			invader_height,
			32,//Depth (bits per pixel)
			FullWidth*max_invaders *4,//Pitch 
			cast(uint)0x000000FF,//Red mask
			cast(uint)0x0000FF00,//Green mask
			cast(uint)0x00FF0000,//Blue mask
			cast(uint)0xFF000000//Alpha mask
			);      //Alpha mask
	SDL_Texture* tex = SDL_CreateTextureFromSurface(renderer,surface);
  	SDL_FreeSurface(surface);

	return tex;
}
