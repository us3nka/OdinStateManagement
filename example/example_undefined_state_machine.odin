package example

import "core:fmt"
import "state_management:event_system"
import "state_management:undefined_state_machine"

Some_Undefined_Input :: enum {
    INPUT_1,
    INPUT_2,
    INPUT_3,
}

Some_Undefined_State :: enum {
    STATE_1,
    STATE_2,
    STATE_3,
}

undefined_state_machine: undefined_state_machine.Undefined_State_Machine( Some_Undefined_State, Some_Undefined_Input, event_system.NO_DATA ) = {
    "Some Undefined State Machine",
    {
        { some_undefined_state_entry_action, some_undefined_state_exit_action, some_undefined_state_input_action },
        { some_undefined_state_entry_action, some_undefined_state_exit_action, some_undefined_state_input_action },
        { some_undefined_state_entry_action, some_undefined_state_exit_action, some_undefined_state_input_action },
    },
    .STATE_1,
    nil
}

some_undefined_state_entry_action :: proc( p_event: ^event_system.Event( Some_Undefined_Input ) )
{
    event_data: ^int = event_system.get_event_data( p_event, int )
    fmt.println( "Hello from the entry state action with input", p_event.input )
    if( nil != event_data ) {
        fmt.println( "Event data: ", event_data^ )
    }
}

some_undefined_state_exit_action :: proc( p_event: ^event_system.Event( Some_Undefined_Input ) )
{
    event_data: ^int = event_system.get_event_data( p_event, int )
    fmt.println( "Hello from the exit state action with input", p_event.input )
    if( nil != event_data ) {
        fmt.println( "Event data: ", event_data^ )
    }
}

some_undefined_state_input_action :: proc( p_event: ^event_system.Event( Some_Undefined_Input ) ) -> Some_Undefined_State
{

    next_state: Some_Undefined_State = .STATE_1

    fmt.println( "Hello from the input state action with input", p_event.input )

    event_data: ^int = event_system.get_event_data( p_event, int )
    if( nil == event_data ) {
        return next_state
    }

    fmt.println( "Event data: ", event_data^ )

    switch p_event.input {
        case .INPUT_1:
            if( 1 == event_data^ ) {
                next_state = .STATE_2
            }
        case .INPUT_2:
        case .INPUT_3:
        case: // default

    }

    return next_state
}