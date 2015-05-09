import std.string;
import std.file;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

private SDL_Texture*[string] _textures;

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
