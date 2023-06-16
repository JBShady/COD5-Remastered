#undef		OPTIONS_STYLE
#undef		STYLE2_NOPOSITION
#define		OPTIONS_LEFT
#include "ui_mp/menustyle.inc"
#undef		OPTIONS_LEFT

#ifndef BACKGROUND_BLACK_LETTERBOX_BLURWORLD_VIS
#include "ui/overlaybg.inc"
#endif

#ifdef PC_INGAME
//	BACKGROUND_BLACK_LETTERBOX_BLURWORLD_VIS( 1 , 1 )
//	OVERLAY_BACKGROUND
//	CHOICE_MENU_TITLE( "@MENU_OPTIONS_UPPER_CASE" )
#else
//	CHOICE_OVERLAY_TITLE_VIS( "@MENU_OPTIONS_UPPER_CASE", when( !dvarBool( cl_ingame ) ) )

#endif

#undef BACK_OPEN
#define BACK_OPEN exec "wait";
#include "ui_mp/navcontrols.inc"

#undef CHOICE_X_START
#define CHOICE_X_START		30

#undef CHOICE_Y_START
#define CHOICE_Y_START		65

#undef		CHOICE_SIZE_Y
#define		CHOICE_SIZE_Y		22

fullScreen		0
rect			0 0 640 480	HORIZONTAL_ALIGN_FULLSCREEN

		BACKGROUND_BLACK_LETTERBOX_BLURWORLD_VIS( 1 , when( dvarBool( cl_ingame ) ) );
		itemDef 
		{ 
			style			WINDOW_STYLE_SHADER 
			rect			-600 -800 2000 2000 0 0 
			forecolor		/*COLOR_FADEOUT*/ 0 0 0 0.65 
			background		"white" 
			visible			when( dvarBool( cl_ingame ) );  
			decoration 
		} 
		itemDef 
		{ 
			style			WINDOW_STYLE_FILLED 
			rect			0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN 
			backcolor		0 0 0 0 
			visible			when( dvarBool( cl_ingame ) );  
			decoration 
		}
		itemDef 
		{ 
			style			WINDOW_STYLE_SHADER 
			rect			-107 0 854 64 0 0
			forecolor		1 1 1 1
			background		"menu_black_line"
			visible			when( dvarBool( cl_ingame ) ); 
			decoration 
		} 
		itemDef 
		{ 
			style			WINDOW_STYLE_SHADER 
			rect			-107 420 854 70 0 0
			forecolor		1 1 1 1 
			background		"menu_black_line" 
			visible			when( dvarBool( cl_ingame ) ); 
			decoration 
		} 
		/*top white line*/ 
		itemDef 
		{ 
			style			WINDOW_STYLE_SHADER 
			rect			0 64 640 1 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN 
			forecolor		0.5 0.5 0.5 0.65  
			background		"menu_white_line_faded" 
			visible			when( dvarBool( cl_ingame ) ); 
			decoration 
		}
		itemDef 
		{ 
			style			WINDOW_STYLE_SHADER 
			rect			0 BOTTOM_LINE_Y 640 1 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN 
			forecolor		0.5 0.5 0.5 0.65  
			background		"menu_white_line_faded" 
			visible			when( dvarBool( cl_ingame ) );
			decoration 
		}
		itemDef 
		{
			name			back2
			text			"@MENU_BACK"
			type			1
			style			WINDOW_STYLE_FILLED
			textstyle		ITEM_TEXTSTYLE_SHADOWED
			rect			-250 -26 40 20 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_BOTTOM
			textalign		ITEM_ALIGN_LEFT
			textfont		CHOICE_TEXTFONT
			textscale		TEXTSIZE_SMALL
			textaligny		18
			visible			when( dvarBool( cl_ingame ) );
			//mouseEnter		{ play "mouse_over"; }
			action 
			{
				play "mouse_click";
				close self;
				BACK_OPEN
			}
		}
#define YOUREINGAME ( dvarBool( cl_ingame ))
	CHOICE_MENU_TITLE_VIS( "@MENU_OPTIONS_UPPER_CASE", YOUREINGAME )

CHOICE_BUTTON( 1, "@MENU_GRAPHICS_CAP", LOCAL_CLOSE_ALL open options_graphics )
CHOICE_BUTTON( 2, "@MENU_TEXTURE_SETTINGS_CAP", LOCAL_CLOSE_ALL open options_graphics_texture )
CHOICE_BUTTON( 3, "@MENU_SOUND_CAP", LOCAL_CLOSE_ALL open options_sound )
CHOICE_BUTTON( 4, "@MENU_VOICECHAT_CAP", LOCAL_CLOSE_ALL open options_voice )
CHOICE_BUTTON( 5, "@MENU_GAME_OPTIONS_CAP", LOCAL_CLOSE_ALL open options_game )
CHOICE_BUTTON_VIS( 6, "@MENU_MULTIPLAYER_OPTIONS_CAP", LOCAL_CLOSE_ALL open options_multi, when( dvarbool( ui_multiplayer ) ); )
CHOICE_BUTTON_VIS( 6, "@MENU_COOPERATIVE_OPTIONS_CAP", LOCAL_CLOSE_ALL open options_multi, when( !dvarbool( ui_multiplayer ) ); )
#ifdef PC_INGAME
CHOICE_DBUTTON_VIS( 7, "@PLATFORM_DEFAULT_SYSTEM_SETTINGS_CAP", 1; )
#else // #ifdef PC_INGAME
CHOICE_DBUTTON_VIS( 7, "@PLATFORM_DEFAULT_SYSTEM_SETTINGS_CAP", when( dvarBool( cl_ingame ) ); )
CHOICE_BUTTON_VIS( 7, "@PLATFORM_DEFAULT_SYSTEM_SETTINGS_CAP", LOCAL_CLOSE_ALL open options_graphics_defaults, when( !dvarBool( cl_ingame ) ); )
#endif // #ifdef PC_INGAME
CHOICE_BUTTON( 9, "@MENU_CONTROLS_CAP", LOCAL_CLOSE_ALL open options_controls_new_pc; close options_new_pc )

#undef		CHOICE_SIZE_X
#undef		CHOICE_SIZE_Y

#define CHOICE_SIZE_X			150//250
#define CHOICE_SIZE_Y			20

#define		OPTIONS_STYLE			1
#undef		STYLE2_NOPOSITION
#define STYLE2_NOPOSITION
#include "ui_mp/menustyle.inc"

#undef CHOICE_TEXTSIZE
#define CHOICE_TEXTSIZE 	TEXTSIZE_SMALL
#undef	CHOICE_TEXTALIGN
#define	CHOICE_TEXTALIGN	ITEM_ALIGN_MIDDLE_RIGHT
#undef	CHOICE_TEXT_OFFSET_X
#define CHOICE_TEXT_OFFSET_X	(-(4+CHOICE_SIZE_Y)) //22

#undef  CHOICE_DVAR_OFFSET_X
#define CHOICE_DVAR_OFFSET_X	(CHOICE_SIZE_X+20)
#undef  CHOICE_DVAR_TEXTALIGN
#define CHOICE_DVAR_TEXTALIGN	ITEM_ALIGN_MIDDLE_LEFT
#undef CHOICE_DVAR_WIDTH_OFFSET
#define CHOICE_DVAR_WIDTH_OFFSET	120
#undef CHOICE_ACTION_SOUND	
#define CHOICE_ACTION_SOUND		"mouse_click_t"

#undef CHOICE_Y_START
#define CHOICE_Y_START		25

#undef CHOICE_X_START
#define CHOICE_X_START		75