package test

import "core:testing"

import "core:fmt"

import "state_management:event_system"
import "state_management:finite_state_machine"

import "../example"

state_machine_caller :: proc( state_machine_pointer: event_system.State_Machine_Pointer, p_queue_event: ^event_system.Queue_Event )
{
    switch state_machine_pointer.state_machine_type {
        case finite_state_machine.Finite_State_Machine( example.Some_State, example.Some_Input, event_system.NO_DATA ):
            finite_state_machine.state_transition( example.Some_State, example.Some_Input, event_system.NO_DATA, state_machine_pointer, p_queue_event )
        case:
            fmt.println( "Unknown state machine type: ", type_info_of( state_machine_pointer.state_machine_type ) )
    }
}

@test
test_event_queue :: proc(test: ^testing.T)
{
    context.logger = get_logger()

    state_machine_copy := example.finite_state_machine
    state_machine_copy.name = "COPY State Machine"

    fmt.println( "\n--- New event queue---\n" )

    p_event_queue: ^event_system.Event_Queue = event_system.new_event_queue( state_machine_caller )

    some_event_data: int = 1

    fmt.println( "\n--- Register example state machines to event queue ---\n" )
    event_system.register_state_machine( p_event_queue, example.Some_Input, &example.finite_state_machine )
    event_system.register_state_machine( p_event_queue, example.Some_Input, &state_machine_copy )

    fmt.println( "\n--- Push events into queue ---\n" )
    event_system.push_event( p_event_queue, example.Some_Input.INPUT_1, &some_event_data )
    event_system.push_event( p_event_queue, example.Some_Input.INPUT_3, &some_event_data )
    event_system.push_event( p_event_queue, example.Some_Input.INPUT_2, &some_event_data )

    fmt.println( "\n--- Process queue ---" )
    event_system.process_queue( p_event_queue )

    fmt.println( "\n--- Unregeister copy state machine ---" )
    event_system.unregister_state_machine( p_event_queue, example.Some_Input, &state_machine_copy )

    fmt.println( "\n--- Push events into queue ---" )
    event_system.push_event( p_event_queue, example.Some_Input.INPUT_2, &some_event_data )
    event_system.push_event( p_event_queue, example.Some_Input.INPUT_2, &some_event_data )

    fmt.println( "\n--- Process queue ---" )
    event_system.process_queue( p_event_queue )

    fmt.println( "\n--- Delete queue ---" )
    event_system.delete_event_queue( p_event_queue )

    destroy_logger()
}