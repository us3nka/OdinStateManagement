package event_system

import "core:log"
import "core:intrinsics"

/* DATA TYPES */

Condition               :: proc() -> bool
State_Machine_Caller    :: proc( state_machine_pointer: State_Machine_Pointer, p_queue_event: ^Queue_Event )

State_Machine_Pointer :: struct {
    state_machine_type  : typeid,
    p_state_machine     : rawptr,
}

Queue_Event :: struct {
    input_type          : typeid,
    input               : int,
    data_type           : typeid,
    p_data              : rawptr,
}

Conditional_Event :: struct {
    condition   : Condition,
    queue_event : Queue_Event,
}

Event_Queue :: struct {
    registered_state_machines   : map[typeid]map[rawptr]State_Machine_Pointer,
    event_queue                 : [dynamic]^Queue_Event,
    conditional_events          : [dynamic]Conditional_Event,
    state_machine_caller      : State_Machine_Caller,
}

/* PROCEDURES */

new_event_queue :: proc(
    state_machine_caller: State_Machine_Caller,
) -> ^Event_Queue
{
    p_event_queue := new( Event_Queue )
    p_event_queue.registered_state_machines = make(map[typeid]map[rawptr]State_Machine_Pointer)
    p_event_queue.event_queue = make( [dynamic]^Queue_Event )
    p_event_queue.conditional_events = make( [dynamic]Conditional_Event )
    p_event_queue.state_machine_caller = state_machine_caller

    log.debug( rawptr(p_event_queue), "event queue created..." )

    return p_event_queue
}

delete_event_queue :: proc(
    p_event_queue: ^Event_Queue,
)
{
    log.debug( rawptr(p_event_queue), "event queue destroyed..." )

    for key, value in p_event_queue.registered_state_machines {
        delete( value )
    }
    delete( p_event_queue.registered_state_machines )
    delete( p_event_queue.event_queue )
    delete( p_event_queue.conditional_events )

    free( p_event_queue )
}

register_state_machine :: proc(
    p_event_queue   : ^Event_Queue,
    $input_type     : typeid,
    p_state_machine : ^$state_machine_type,
)
{
    if( false == ( input_type in p_event_queue.registered_state_machines ) ) {
        p_event_queue.registered_state_machines[input_type] = make( map[rawptr]State_Machine_Pointer )
    }

    p_state_machine_map := &p_event_queue.registered_state_machines[input_type]
    p_state_machine_map[rawptr(p_state_machine)] = State_Machine_Pointer{ state_machine_type, p_state_machine }

    log.debug( rawptr(p_event_queue), ": Registered state machine (", rawptr(p_state_machine) ,") with input type", type_info_of( input_type ) )
}

unregister_state_machine :: proc(
    p_event_queue   : ^Event_Queue,
    $input_type     : typeid,
    p_state_machine : ^$state_machine_type,
)
{
    p_state_machine_map, exists := &p_event_queue.registered_state_machines[input_type]
    if( true == exists ) {
        delete_key(p_state_machine_map, rawptr(p_state_machine) )
    }

    log.debug( rawptr(p_event_queue), ": Unegistered state machine (", rawptr(p_state_machine) ,") with input type", type_info_of( input_type ) )
}

new_queue_event :: proc(
    input   : $Input_Type,
    p_data  : $Data_Type,
) -> ^Queue_Event
{
    p_queue_event := new( Queue_Event )
    p_queue_event.input_type = Input_Type
    p_queue_event.input = int( input )
    p_queue_event.data_type = Data_Type
    p_queue_event.p_data = p_data

    return p_queue_event
}

push_event_no_data :: proc(
    p_event_queue   : ^Event_Queue,
    input           : $Input_Type,
) where intrinsics.type_is_enum(Input_Type)
{
    push_event_raw_data( p_event_queue, input, NO_DATA( nil ) )
}

push_event_raw_data :: proc(
    p_event_queue   : ^Event_Queue,
    input           : $Input_Type,
    p_data          : $Data_Type,
) where intrinsics.type_is_enum(Input_Type), intrinsics.type_is_pointer(Data_Type)
{
    log.debug( rawptr(p_event_queue), ": Push event", input )

    p_queue_event := new_queue_event( input, p_data )

    append( &p_event_queue.event_queue, p_queue_event )
}

push_event :: proc
{
    push_event_no_data,
    push_event_raw_data,
}

add_conditional_event_no_data :: proc(
    p_event_queue   : ^Event_Queue,
    condition       : Condition,
    input           : $Input_Type,
)
{
    add_conditional_event_raw_data( p_event_queue, condition, input, NO_DATA( nil ) )
}

add_conditional_event_raw_data :: proc(
    p_event_queue   : ^Event_Queue,
    condition       : Condition,
    input           : $Input_Type,
    p_data          : $Data_Type,
) where intrinsics.type_is_enum(Input_Type), intrinsics.type_is_pointer(Data_Type)
{
    append(
        &p_event_queue.conditional_events,
        {
            condition,
            {
                Input_Type,
                int( input ),
                Data_Type,
                p_data,
            }
        }
    )
}

add_conditional_event :: proc
{
    add_conditional_event_no_data,
    add_conditional_event_raw_data,
}


process_queue :: proc(
    p_event_queue: ^Event_Queue,
)
{
    log.debug( rawptr(p_event_queue), ": Start processing queue..." )
    for p_queue_event, index in p_event_queue.event_queue {
        for key, state_machine_pointer in p_event_queue.registered_state_machines[p_queue_event.input_type] {
             p_event_queue.state_machine_caller( state_machine_pointer, p_queue_event )
        }

        free( p_queue_event )

        check_conditional_events( p_event_queue )
    }

    clear( &p_event_queue.event_queue )
    log.debug( rawptr(p_event_queue), ": End processing queue..." )
}

check_conditional_events :: proc(
    p_event_queue: ^Event_Queue,
)
{
    for conditional_event in p_event_queue.conditional_events {
        if( true == conditional_event.condition() ) {
            p_queue_event := new( Queue_Event )
            p_queue_event^ = conditional_event.queue_event

            append( &p_event_queue.event_queue, p_queue_event )
        }
    }
}