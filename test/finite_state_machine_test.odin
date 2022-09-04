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
