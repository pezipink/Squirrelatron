import derelict.sdl2.sdl;
import std.stdio;

enum Direction
{
	Up = 0,
	Down = 1,
	Left = 2,
	Right = 3,
	None = 4
}

struct InputData
{
	Direction HorizontalMovement;
	Direction VerticalMovement;	
	Direction HorizontalBullets;
	Direction VerticalBullets;	
}

InputData MainInput;
private SDL_Joystick* joystick;
private immutable int deadZone = 10000;

public bool gameRunning = false;
void InitializeJoysticks(){
	if(SDL_NumJoysticks() > 0 ) {
		joystick = SDL_JoystickOpen(0);
		//for(int i=0; i<SDL_NumJoysticks(); i++) {
				//_joysticks~=SDL_JoystickOpen(i);

		//}
		SDL_JoystickEventState(SDL_ENABLE);
	}

}

private template JoyInput(string target, string greater, string less )
{
	const char[] JoyInput =
		"if( event.jaxis.value > deadZone)
		{
			"~target~"="~greater~";
		}
		else if( event.jaxis.value < -deadZone)
		{
			"~target~"="~less~";
		}
		else
		{
			"~target~" = Direction.None;
		}";
}

void Update() {
	SDL_Event event;
	while (SDL_PollEvent(&event))
	{
	  switch(event.type)
	  {
	    case SDL_QUIT:
	    gameRunning=false;
	    break;

    	case SDL_JOYAXISMOTION:
		if(event.jaxis.axis == 0) // left stick horiz
		{
			mixin(JoyInput!("MainInput.HorizontalMovement","Direction.Right","Direction.Left"));
		}
		else if(event.jaxis.axis == 1) // left stick vert
		{
			mixin(JoyInput!("MainInput.VerticalMovement","Direction.Down","Direction.Up"));
		}

		if(event.jaxis.axis == 2) // Right stick horiz
		{
			mixin(JoyInput!("MainInput.HorizontalBullets","Direction.Right","Direction.Left"));
		}
		else if(event.jaxis.axis == 3) // left stick vert
		{
			mixin(JoyInput!("MainInput.VerticalBullets","Direction.Down","Direction.Up"));
		}

		break;

	    default:
	    break;
	  }
	}
};

void Clean() {
	//foreach(j; _joysticks) {
	//	SDL_JoystickClose(j);
	//}
	SDL_JoystickClose(joystick);
};
