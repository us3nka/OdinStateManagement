package example

import "core:fmt"
import "state_management:event_system"
import "state_management:finite_state_machine"

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

finite_state_machine: finite_state_machine.Finite_State_Machine( Some_State, Some_Input ) = {
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