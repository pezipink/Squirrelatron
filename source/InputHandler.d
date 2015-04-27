import derelict.sdl2.sdl;
import std.stdio;

enum Direction
{
	None = 0,
	BaseUp 		= 0b0000_0001,
	BaseDown 	= 0b0000_0010,
	BaseVet		= 0b0000_0011,
	BaseLeft 	= 0b0000_0100,
	BaseRight 	= 0b0000_1000,
	BaseHoriz	= 0b0000_1100,
	BaseAll		= 0b0000_1111,
	TurretUp 	= 0b0001_0000,
	TurretDown  = 0b0010_0000,
	TurretVert	= 0b0011_0000,
	TurretLeft 	= 0b0100_0000,
	TurretRight = 0b1000_0000,
	TurretHoriz = 0b1100_0000,
	TurretAll	= 0b1111_0000,
	All 		= 0b1111_1111 	
}


private byte directions = 0;

bool testDirection(byte dir){
	return (dir & directions) == dir;
}

unittest{
	directions = Direction.TurretUp | Direction.TurretLeft;
	assert(testDirection(Direction.TurretUp));
	assert(testDirection(Direction.TurretLeft));
	assert(testDirection(Direction.TurretUp | Direction.TurretLeft));
	assert(testDirection(Direction.TurretLeft | Direction.TurretDown) == false);
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

Uint8* _keyState;

public bool gameRunning = false;
void InitializeJoysticks(){
	MainInput.HorizontalMovement = Direction.None;
	MainInput.VerticalMovement = Direction.None;
	MainInput.HorizontalBullets = Direction.None;
	MainInput.VerticalBullets = Direction.None;

	if(SDL_NumJoysticks() > 0 ) {
		joystick = SDL_JoystickOpen(0);
		//for(int i=0; i<SDL_NumJoysticks(); i++) {
				//_joysticks~=SDL_JoystickOpen(i);

		//}
		SDL_JoystickEventState(SDL_ENABLE);
	}
}

bool IsKeyDown(SDL_Scancode code){
	if( _keyState != null ) 
		if( _keyState[code] == 1 ) 
			return true;
	return false;
}
 auto keyMapping = [0 : 1, 1 : 2];
private void UpdateKeys(){
	if( IsKeyDown(SDL_SCANCODE_RIGHT)){
		directions |= Direction.BaseRight;
	} else {
		directions &= (directions ^ Direction.BaseRight);
	} 

	if (IsKeyDown(SDL_SCANCODE_LEFT)) {
		directions |= Direction.BaseLeft;
	}
	 else 
	{
		directions &= (directions ^ Direction.BaseLeft);
		//directions &= (directions ^ Direction.BaseHoriz);
		//MainInput.HorizontalMovement = Direction.BaseNone;
		// 00000000
		// 
	}

	//if( IsKeyDown(SDL_SCANCODE_UP) || IsKeyDown(SDL_SCANCODE_W)){
	//	MainInput.VerticalMovement = Direction.Up;
	//} else if (IsKeyDown(SDL_SCANCODE_DOWN)) {
	//	MainInput.VerticalMovement = Direction.Down;
	//} else {MainInput.VerticalMovement = Direction.None; }

	if(IsKeyDown(SDL_SCANCODE_ESCAPE)) {
		gameRunning=false;
	}
}
private template JoyInput(string target, string greater, string less ) {
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
	_keyState = SDL_GetKeyboardState(null);
	UpdateKeys();
	SDL_Event event;
	while (SDL_PollEvent(&event))
	{
	  switch(event.type)
	  {
	    case SDL_QUIT:
	    gameRunning=false;
	    break;

    	case SDL_JOYAXISMOTION:
		if(event.jaxis.axis == 0) { // left stick horiz 
			mixin(JoyInput!("MainInput.HorizontalMovement","Direction.BaseRight","Direction.BaseLeft"));
		}
		else if(event.jaxis.axis == 1) { // left stick vert
			mixin(JoyInput!("MainInput.VerticalMovement","Direction.BaseDown","Direction.BaseUp"));
		}

		if(event.jaxis.axis == 2) {// Right stick horiz
			mixin(JoyInput!("MainInput.HorizontalBullets","Direction.BaseRight","Direction.BaseLeft"));
		}
		else if(event.jaxis.axis == 3){ // Right stick vert
			mixin(JoyInput!("MainInput.VerticalBullets","Direction.BaseDown","Direction.BaseUp"));
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
	if( joystick != null)
		SDL_JoystickClose(joystick);
};
