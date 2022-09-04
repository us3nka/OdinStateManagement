package example

import "core:fmt"
import "state_management:event_system"
import "state_management:finite_state_machine"

Music_Box_Input :: enum {
    START_BUTTON_PRESSED,
    STOP_BUTTON_PRESSED,
    NEW_SONG_SELECTED,
    VOLUME_UP_BUTTON_PRESSED,
    VOLUME_DOWN_BUTTON_PRESSED,
}

Music_Box_State :: enum {
    NO_SONG_SELECTED,
    READY_TO_PLAY,
    PLAYING_MUSIC,
}

Music_Box :: struct {
    current_song    : string,
    volume          : int,
}

music_box : finite_state_machine.Finite_State_Machine( Music_Box_State, Music_Box_Input, Music_Box ) = {
    "Music Box",
    {                       /* START_BUTTON_PRESSED | STOP_BUTTON_PRESSED   | NEW_SONG_SELECTED     | VOLUME_UP_BUTTON_PRESSED  | VOLUME_DOWN_BUTTON_PRESSED    */
    /* NO_SONG_SELECTED */  { .NO_SONG_SELECTED     , .NO_SONG_SELECTED     , .READY_TO_PLAY        , .NO_SONG_SELECTED         , .NO_SONG_SELECTED             },
    /* READY_TO_PLAY    */  { .PLAYING_MUSIC        , .READY_TO_PLAY        , .READY_TO_PLAY        , .READY_TO_PLAY            , .READY_TO_PLAY                },
    /* PLAYING_MUSIC    */  { .PLAYING_MUSIC        , .READY_TO_PLAY        , .PLAYING_MUSIC        , .PLAYING_MUSIC            , .PLAYING_MUSIC                },
    },
    {
        { nil, no_song_selected_exit, no_song_selected_remain },
        { nil, nil, ready_to_play_remain },
        { play_music_entry, play_music_exit, play_music_remain },
    },
    .NO_SONG_SELECTED,
    {
        "None",
        0,
    }
}

increase_volume :: proc( p_music_box: ^Music_Box ) {
    if( 100 > p_music_box.volume ) {
        p_music_box.volume += 1;
    }
    fmt.println( "Music Box volume set to:", p_music_box.volume )
}

decrease_volume :: proc( p_music_box: ^Music_Box ) {
    if( 0 < p_music_box.volume  ) {
        p_music_box.volume -= 1;
    }
    fmt.println( "Music Box volume set to:", p_music_box.volume )
}

set_song_from_event :: proc( p_music_box: ^Music_Box, p_event: ^event_system.Event( Music_Box_Input )) {
    p_song: ^string = event_system.get_event_data( p_event, string )
    if( nil != p_song ) {
        p_music_box.current_song = p_song^
        fmt.println( "Music Box song set to:", p_music_box.current_song )
    }
}

handle_volume_and_song_selection :: proc( p_event: ^event_system.Event( Music_Box_Input ), p_music_box: ^Music_Box )
{
    switch p_event.input {
        case .VOLUME_UP_BUTTON_PRESSED:
            increase_volume( p_music_box )
        case .VOLUME_DOWN_BUTTON_PRESSED:
            decrease_volume( p_music_box )
        case .NEW_SONG_SELECTED:
            set_song_from_event( p_music_box, p_event )
        case .START_BUTTON_PRESSED:
            fallthrough
        case .STOP_BUTTON_PRESSED:
            fallthrough
        case:
            /* Ignore input */
    }
}

no_song_selected_remain :: proc( p_event: ^event_system.Event( Music_Box_Input ), p_music_box: ^Music_Box )
{
    switch p_event.input {
        case .VOLUME_UP_BUTTON_PRESSED:
            fallthrough
        case .VOLUME_DOWN_BUTTON_PRESSED:
            fallthrough
        case .NEW_SONG_SELECTED:
            handle_volume_and_song_selection( p_event, p_music_box )
        case .START_BUTTON_PRESSED:
            fallthrough
        case .STOP_BUTTON_PRESSED:
            fallthrough
        case:
            /* Nothing to do here */
    }
}

no_song_selected_exit :: proc( p_event: ^event_system.Event( Music_Box_Input ), p_music_box: ^Music_Box )
{
    switch p_event.input {
        case .NEW_SONG_SELECTED:
            handle_volume_and_song_selection( p_event, p_music_box )
        case .VOLUME_UP_BUTTON_PRESSED:
            fallthrough
        case .VOLUME_DOWN_BUTTON_PRESSED:
            fallthrough
        case .START_BUTTON_PRESSED:
            fallthrough
        case .STOP_BUTTON_PRESSED:
            fallthrough
        case:
            /* This should not happen */
    }
}

ready_to_play_remain :: proc( p_event: ^event_system.Event( Music_Box_Input ), p_music_box: ^Music_Box )
{
    switch p_event.input {
        case .VOLUME_UP_BUTTON_PRESSED:
            fallthrough
        case .VOLUME_DOWN_BUTTON_PRESSED:
            fallthrough
        case .NEW_SONG_SELECTED:
            handle_volume_and_song_selection( p_event, p_music_box )
        case .START_BUTTON_PRESSED:
            fallthrough
        case .STOP_BUTTON_PRESSED:
            fallthrough
        case:
            /* Nothing to do here */
    }
}

play_music_remain :: proc( p_event: ^event_system.Event( Music_Box_Input ), p_music_box: ^Music_Box )
{
    switch p_event.input {
        case .VOLUME_UP_BUTTON_PRESSED:
            fallthrough
        case .VOLUME_DOWN_BUTTON_PRESSED:
            fallthrough
        case .NEW_SONG_SELECTED:
            handle_volume_and_song_selection( p_event, p_music_box )
        case .START_BUTTON_PRESSED:
            fallthrough
        case .STOP_BUTTON_PRESSED:
            fallthrough
        case:
            /* Nothing to do here */
    }
}

play_music_entry :: proc( p_event: ^event_system.Event( Music_Box_Input ), p_music_box: ^Music_Box )
{
    fmt.println( "Music box start playing song", p_music_box.current_song )
}

play_music_exit :: proc( p_event: ^event_system.Event( Music_Box_Input ), p_music_box: ^Music_Box )
{
    fmt.println( "Music box stop playing song", p_music_box.current_song )
}

Some_Input :: enum {
    INPUT_1,
    INPUT_2,
    INPUT_3,
}

Some_State :: enum {
    STATE_1,
    STATE_2,
    STATE_3,
}

finite_state_machine: finite_state_machine.Finite_State_Machine( Some_State, Some_Input, event_system.NO_DATA ) = {
    "Some Finite State Machine",
    {
        { .STATE_1, .STATE_2, .STATE_3 },
        { .STATE_2, .STATE_3, .STATE_1 },
        { .STATE_3, .STATE_1, .STATE_2 },
    },
    {
        { some_state_entry_action, some_state_exit_action, some_state_remain_action },
        { some_state_entry_action, some_state_exit_action, some_state_remain_action },
        { some_state_entry_action, some_state_exit_action, some_state_remain_action },
    },
    .STATE_1,
    nil,
}

some_state_entry_action :: proc( p_event: ^event_system.Event( Some_Input ) )
{
    event_data: ^int = event_system.get_event_data( p_event, int )
    fmt.println( "Hello from the entry state action with input", p_event.input )
    if( nil != event_data ) {
        fmt.println( "Event data: ", event_data^ )
    }
}

some_state_exit_action :: proc( p_event: ^event_system.Event( Some_Input ) )
{
    event_data: ^int = event_system.get_event_data( p_event, int )
    fmt.println( "Hello from the exit state action with input", p_event.input )
    if( nil != event_data ) {
        fmt.println( "Event data: ", event_data^ )
    }
}

some_state_remain_action :: proc( p_event: ^event_system.Event( Some_Input ) )
{
    event_data: ^int = event_system.get_event_data( p_event, int )
    fmt.println( "Hello from the remain state action with input", p_event.input )
    if( nil != event_data ) {
        fmt.println( "Event data: ", event_data^ )
    }
}