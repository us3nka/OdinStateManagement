package undefined_state_machine

import "core:log"
import "core:intrinsics"

import "../event_system"

/* DATA TYPES */

State_Action :: union( $State_Type: typeid, $Input_Type: typeid, $State_Machine_Data_Type: typeid ) {
    proc( p_event: ^event_system.Event( Input_Type ), p_state_machine_data: ^State_Machine_Data_Type ) -> State_Type,
    proc( event: ^event_system.Event( Input_Type ) ) -> State_Type,
}

Transition_Action :: union( $Input_Type: typeid, $State_Machine_Data_Type: typeid ) {
    proc( p_event: ^event_system.Event( Input_Type ), p_state_machine_data: ^State_Machine_Data_Type ),
    proc( event: ^event_system.Event( Input_Type ) ),
}

Undefined_State :: struct( $State_Type: typeid, $Input_Type: typeid, $State_Machine_Data_Type: typeid )
    where intrinsics.type_is_enum(State_Type), intrinsics.type_is_enum(Input_Type)
{
    entry_procedure     : Transition_Action( Input_Type, State_Machine_Data_Type ),
    exit_procedure      : Transition_Action( Input_Type, State_Machine_Data_Type ),
    state_procedure     : State_Action( State_Type, Input_Type, State_Machine_Data_Type ),
}

Undefined_State_Machine :: struct ( $State_Type: typeid, $Input_Type: typeid, $State_Machine_Data_Type: typeid )
    where intrinsics.type_is_enum(State_Type), intrinsics.type_is_enum(Input_Type)
{
    name                : string,
    state_table         : [len(State_Type)]Undefined_State( State_Type, Input_Type, State_Machine_Data_Type ),
    current_state       : State_Type,
    data                : State_Machine_Data_Type
}

/* PROCEDURES */

call_trasition_procedure :: proc(
    transition_action       : Transition_Action( $Input_Type, $State_Machine_Data_Type ),
    p_event                 : ^event_system.Event( Input_Type ),
    p_state_machine_data    : ^State_Machine_Data_Type,
) where intrinsics.type_is_enum(Input_Type)
{
    switch transition_procedure in transition_action {
        case proc( p_event: ^event_system.Event( Input_Type ), p_state_machine_data: ^State_Machine_Data_Type ):
            transition_procedure( p_event, p_state_machine_data)
        case proc( event: ^event_system.Event( Input_Type ) ):
            transition_procedure( p_event)
        case:
            /* Nothing to do here */
    }
}

call_state_procedure :: proc(
    state_action            : State_Action( $State_Type, $Input_Type, $State_Machine_Data_Type ),
    p_event                 : ^event_system.Event( Input_Type ),
    p_state_machine_data    : ^State_Machine_Data_Type,
) -> State_Type
where intrinsics.type_is_enum(Input_Type), intrinsics.type_is_enum(State_Type)
{
    switch state_procedure in state_action {
        case proc( p_event: ^event_system.Event( Input_Type ), p_state_machine_data: ^State_Machine_Data_Type ) -> State_Type:
            return state_procedure( p_event, p_state_machine_data)
        case proc( event: ^event_system.Event( Input_Type ) ) -> State_Type:
            return state_procedure( p_event)
        case:
            /* TODO: Panic here? */
            log.error( "State action required!" )
            return State_Type( 0 )
    }
}

state_transition_no_data :: proc (
    p_state_machine : ^Undefined_State_Machine( $State_Type, $Input_Type, $State_Machine_Data_Type ),
    input           : Input_Type,
) where intrinsics.type_is_enum(State_Type), intrinsics.type_is_enum(Input_Type)
{
    event: event_system.Event( Input_Type ) = {
        input,
        event_system.NO_DATA,
        nil,
    }

    state_transition_event( p_state_machine, &event )
}

state_transition_raw_data :: proc(
    p_state_machine : ^Undefined_State_Machine( $State_Type, $Input_Type, $State_Machine_Data_Type ),
    input           : Input_Type, p_data: $Data_Type,
) where intrinsics.type_is_enum(State_Type), intrinsics.type_is_enum(Input_Type), intrinsics.type_is_pointer(Data_Type)
{
    event: event_system.Event( Input_Type ) = {
        input,
        Data_Type,
        p_data,
    }

    state_transition_event( p_state_machine, &event )
}

state_transition_queue_event :: proc(
    $State_Type                 : typeid,
    $Input_Type                 : typeid,
    $State_Machine_Data_Type    : typeid,
    state_machine_pointer       : event_system.State_Machine_Pointer,
    p_queue_event               : ^event_system.Queue_Event,
)
{
    if( Undefined_State_Machine( State_Type, Input_Type, State_Machine_Data_Type ) != state_machine_pointer.state_machine_type ) {
        log.error( "Passed type information does not match state machine type: ", type_info_of( Undefined_State_Machine( State_Type, Input_Type ) ), "!=", type_info_of( state_machine_pointer.state_machine_type ) )
        return
    }

    p_casted_state_machine := (^Undefined_State_Machine( State_Type, Input_Type ))( state_machine_pointer.p_state_machine )

    event: event_system.Event(Input_Type) = {
        Input_Type( p_queue_event.input ),
        p_queue_event.data_type,
        p_queue_event.p_data
    }

    state_transition_event( p_casted_state_machine, &event )
}

state_transition_event :: proc(
    p_state_machine : ^Undefined_State_Machine( $State_Type, $Input_Type, $State_Machine_Data_Type ),
    p_event         : ^event_system.Event(Input_Type),
)
    where intrinsics.type_is_enum(State_Type), intrinsics.type_is_enum(Input_Type)
{
    log.debug( p_state_machine.name, ":", p_state_machine.current_state, "<-", p_event.input )
    new_state: State_Type = call_state_procedure( p_state_machine.state_table[p_state_machine.current_state].state_procedure, p_event, &p_state_machine.data )

    if( p_state_machine.current_state != new_state ) {
        log.debug( p_state_machine.name, ":", p_state_machine.current_state, "<-", p_event.input, ": EXIT" )
        call_trasition_procedure( p_state_machine.state_table[p_state_machine.current_state].exit_procedure, p_event, &p_state_machine.data )

        p_state_machine.current_state = new_state

        log.debug( p_state_machine.name, ":", p_state_machine.current_state, "<-", p_event.input, ": ENTRY" )

        call_trasition_procedure( p_state_machine.state_table[p_state_machine.current_state].entry_procedure, p_event, &p_state_machine.data )
    }
}

state_transition :: proc{
    state_transition_no_data,
    state_transition_raw_data,
    state_transition_queue_event,
    state_transition_event,
}
