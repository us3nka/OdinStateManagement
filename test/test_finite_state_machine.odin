package test

import "core:testing"

import "state_management:finite_state_machine"

import "../example"

@test
test_finite_state_machine :: proc(test: ^testing.T)
{
    context.logger = get_logger()

    some_event_data: int = 1

    finite_state_machine.state_transition( &example.finite_state_machine,  example.Some_Input.INPUT_2, &some_event_data )
    finite_state_machine.state_transition( &example.finite_state_machine,  example.Some_Input.INPUT_1 )
    finite_state_machine.state_transition( &example.finite_state_machine,  example.Some_Input.INPUT_3 )
    finite_state_machine.state_transition( &example.finite_state_machine,  example.Some_Input.INPUT_2, &some_event_data)

    destroy_logger()
}

@test
test_music_box_state_machine :: proc(test: ^testing.T) {
    context.logger = get_logger()

    song: string = "Sympathy For The Devil"

    /* Nothing happens when start/stop button is pressed witout selecting a song */
    finite_state_machine.state_transition( &example.music_box, example.Music_Box_Input.START_BUTTON_PRESSED )
    finite_state_machine.state_transition( &example.music_box, example.Music_Box_Input.STOP_BUTTON_PRESSED )

    /* Select song.  */
    finite_state_machine.state_transition( &example.music_box, example.Music_Box_Input.NEW_SONG_SELECTED, &song )

    /* Increase volume */
    finite_state_machine.state_transition( &example.music_box, example.Music_Box_Input.VOLUME_UP_BUTTON_PRESSED )
    finite_state_machine.state_transition( &example.music_box, example.Music_Box_Input.VOLUME_UP_BUTTON_PRESSED )
    finite_state_machine.state_transition( &example.music_box, example.Music_Box_Input.VOLUME_UP_BUTTON_PRESSED )
    finite_state_machine.state_transition( &example.music_box, example.Music_Box_Input.VOLUME_UP_BUTTON_PRESSED )

    /* Start playing music */
    finite_state_machine.state_transition( &example.music_box, example.Music_Box_Input.START_BUTTON_PRESSED )

    /* Stop playing music */
    finite_state_machine.state_transition( &example.music_box, example.Music_Box_Input.STOP_BUTTON_PRESSED )

    destroy_logger()
}
