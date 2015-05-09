module Invaders;

import derelict.sdl2.sdl;
import std.random;
import std.math;

private SDL_Texture*[int] invaders;
SDL_Texture* GetInvader(int W, int H)(SDL_Renderer* renderer, int data ) {
	static assert(W % 2 != 0);
	enum FullWidth = W * 2 - 1;	
	if(data in invaders)
		return invaders[data];
	ubyte r = cast(ubyte)uniform(50,200);
	ubyte g = cast(ubyte)uniform(50,200);
	ubyte b = cast(ubyte)uniform(50,200);
	
	ubyte rgb[FullWidth*H*3];
	ubyte[]stack;
	int rgbIndex = 0;
	for(int i=0; i<W*H; i++) {
		if(i % W == 0 && stack.length > 0){
			stack = stack[0..$-3];
			while(stack.length > 0){
				rgb[rgbIndex++] = stack[$-1];
				rgb[rgbIndex++] = stack[$-2];
				rgb[rgbIndex++] = stack[$-3];
				stack = stack[0..$-3];
			}
		}
		bool set = (data & (1 << i)) > 0; 
		if(set){
			rgb[rgbIndex++] = r;
			rgb[rgbIndex++] = g;
			rgb[rgbIndex++] = b;		
			//stack ~= [r,g,b];
			stack ~= [b,g,r];
			
		}
		else{
			rgb[rgbIndex++] = 0;
			rgb[rgbIndex++] = 0;
			rgb[rgbIndex++] = 0;
			stack ~= [0,0,0];			
		}
		
		//std.stdio.writeln(stack);
		
	}
	stack = stack[0..$-3];
	while(stack.length > 0){
		rgb[rgbIndex++] = stack[$-1];
		rgb[rgbIndex++] = stack[$-2];
		rgb[rgbIndex++] = stack[$-3];
		stack = stack[0..$-3];
	}
	SDL_Surface* surface = 
		SDL_CreateRGBSurfaceFrom(cast(void*)rgb, //pointer to the pixels
			FullWidth,
			H,
			24,//Depth (bits per pixel)
			FullWidth*3,//Pitch 
			cast(uint)0x0000FF,//Red mask
			cast(uint)0x00FF00,//Green mask
			cast(uint)0xFF0000,//Blue mask
			0);      //Alpha mask
	SDL_Texture* tex = SDL_CreateTextureFromSurface(renderer,surface);
  	SDL_FreeSurface(surface);
	invaders[data] = tex;

	return tex;
}
