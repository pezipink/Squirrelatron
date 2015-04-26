import std.string;
import std.file;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

private SDL_Texture*[string] _textures;

void Load(immutable string file, immutable string id, SDL_Renderer* renderer)
{
  assert(!(id in _textures));
  assert(file.exists);
  auto surf = IMG_Load(file.toStringz);
  auto tex = SDL_CreateTextureFromSurface(renderer,surf);
  SDL_FreeSurface(surf);
  _textures[id] = tex;
}

void Draw(immutable string id, int x,int y, int width, int height, SDL_Renderer* renderer, SDL_RendererFlip flip = SDL_FLIP_NONE)
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
  SDL_RenderCopyEx(renderer, _textures[id], &srcRect, &destRect, 0.0, null, flip);
}

void DrawFrame(immutable string id, int x, int y, int width, int height, int currentRow, int currentFrame, SDL_Renderer *renderer, SDL_RendererFlip flip)
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
  SDL_RenderCopyEx(renderer, _textures[id], &srcRect, &destRect, 0.0, null, flip);
}

SDL_Rect GetRect(immutable string id)
{
  assert(id in _textures);
  SDL_Rect source;
  SDL_QueryTexture(_textures[id],null,null,&source.w,&source.h);
  return source;
}
