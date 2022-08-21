package test

import "core:testing"

import "state_management:undefined_state_machine"

import "../example"

@test
test_undefined_state_machine :: proc(test: ^testing.T)
{
    context.logger = get_logger()

    some_event_data: int = 1

    undefined_state_machine.state_transition( &example.undefined_state_machine,  example.Some_Undefined_Input.INPUT_1, &some_event_data )
    undefined_state_machine.state_transition( &example.undefined_state_machine,  example.Some_Undefined_Input.INPUT_1 )
    undefined_state_machine.state_transition( &example.undefined_state_machine,  example.Some_Undefined_Input.INPUT_3 )
    undefined_state_machine.state_transition( &example.undefined_state_machine,  example.Some_Undefined_Input.INPUT_2, &some_event_data)

    destroy_logger()
}