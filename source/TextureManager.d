import std.string;
import std.file;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

private SDL_Texture*[string] _textures;

static immutable int invader_width = 3;
static immutable int invader_height = 5;
static immutable int invader_full_width = invader_width * 2 - 1;
static immutable int max_invaders = 2 ^^ (invader_width * invader_height);

void Load(SDL_Texture* tex, immutable string id)
{
  assert(!(id in _textures));
  _textures[id] = tex;
}

void Load(immutable string file, immutable string id, SDL_Renderer* renderer)
{
  assert(!(id in _textures));
  assert(file.exists);
  auto surf = IMG_Load(file.toStringz);
  auto tex = SDL_CreateTextureFromSurface(renderer,surf);
  SDL_FreeSurface(surf);
  _textures[id] = tex;
}

string LoadInvader(in int invaderId, SDL_Renderer* renderer)
{
  assert(invaderId<=max_invaders);
  string id = format("invader%d",invaderId);
  if(id in _textures) return id;
  auto tex = GetInvaderTexture(invaderId, renderer);
  _textures[id] = tex;
  return id;
}

private SDL_Texture* GetInvaderTexture(in int invaderId, SDL_Renderer* renderer) {
  import std.random;
  assert(renderer !is null);
  static assert(invader_width % 2 != 0);
  ubyte[invader_full_width*invader_height*4] rgb;

  int rgbindex = 0;
  void AddRgbData(ubyte r,ubyte g,ubyte b,ubyte a) {
      rgb[rgbindex++] = r;
      rgb[rgbindex++] = g;
      rgb[rgbindex++] = b;
      rgb[rgbindex++] = a;
  }

  ubyte[]stack;
  
  ubyte r = cast(ubyte)uniform(50,200);
  ubyte g = cast(ubyte)uniform(50,200);
  ubyte b = cast(ubyte)uniform(50,200);

  for(int i=0; i<invader_width*invader_height; i++) {
    if(i % invader_width == 0 && stack.length > 0){
      stack = stack[0..$-4];
      while(stack.length > 0){
        AddRgbData(stack[$-4],stack[$-3],stack[$-2],stack[$-1]);
        stack = stack[0..$-4];
        
      }
    }
    bool set = (invaderId & (1 << i)) > 0; 
    if(set){
      AddRgbData(r,g,b,0xFF);   
      stack ~= [r,g,b,0xFF];
    }
    else{
      AddRgbData(0,0,0,0);
      stack ~= [0,0,0,0];     
    }     
  }
  stack = stack[0..$-4];
  while(stack.length > 0){
    AddRgbData(stack[$-4],stack[$-3],stack[$-2],stack[$-1]);
    stack = stack[0..$-4];
  }

  SDL_Surface* surface = 
    SDL_CreateRGBSurfaceFrom(cast(void*)rgb, //pointer to the pixels
      5,
      5,
      32,//Depth (bits per pixel)
      5*4,//Pitch 
      cast(uint)0x000000FF,//Red mask
      cast(uint)0x0000FF00,//Green mask
      cast(uint)0x00FF0000,//Blue mask
      cast(uint)0xFF000000//Alpha mask
      );      //Alpha mask
  assert(surface !is null);
  SDL_Texture* tex = SDL_CreateTextureFromSurface(renderer,surface);
  SDL_FreeSurface(surface);
  return tex;
}

void Draw(immutable string id, in int x, in int y, in int width, in int height, in double angle, SDL_Renderer* renderer, SDL_RendererFlip flip = SDL_FLIP_NONE, in float scale = 1.0)
{ 
  assert(id in _textures);
  SDL_Rect srcRect;
  SDL_Rect destRect;
  srcRect.x = 0;
  srcRect.y = 0;
  srcRect.w = destRect.w = width;
  srcRect.h = destRect.h = height;
  destRect.x = x;
  destRect.y = y;
  destRect.w *= scale;
  destRect.h *= scale;
  SDL_RenderCopyEx(renderer, _textures[id], &srcRect, &destRect, angle, null, flip);
}

void DrawFrame(immutable string id, int x, int y, int width, int height, double angle, int currentRow, int currentFrame, SDL_Renderer *renderer, SDL_RendererFlip flip)
{
  assert(id in _textures);
  SDL_Rect srcRect;
  SDL_Rect destRect;
  srcRect.x = width * currentFrame;
  srcRect.y = height * currentRow;
  srcRect.w = destRect.w = width;
  srcRect.h = destRect.h = height;
  destRect.x = x;
  destRect.y = y;
  SDL_RenderCopyEx(renderer, _textures[id], &srcRect, &destRect, angle, null, flip);
}

SDL_Rect GetRect(immutable string id)
{
  assert(id in _textures);
  SDL_Rect source;
  SDL_QueryTexture(_textures[id],null,null,&source.w,&source.h);
  return source;
}
