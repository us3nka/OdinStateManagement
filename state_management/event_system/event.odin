package event_system

import "core:log"
import "core:intrinsics"

Event :: struct( $Input_Type: typeid )
    where intrinsics.type_is_enum(Input_Type)
{
    input               : Input_Type,
    data_type           : typeid,
    p_data              : rawptr,
}

get_event_data :: proc( p_event: ^Event( $Input_Type ), $Data_Type: typeid ) -> ^Data_Type
    where intrinsics.type_is_enum(Input_Type)
{
    if( nil == p_event.p_data ) {
        log.warn( p_event.input, "event does not conatin any data" )
    } else if ( ^Data_Type != p_event.data_type ) {
        log.error( p_event.input, "event does not contain requested data type: ", type_info_of(^Data_Type), "!=", type_info_of(p_event.data_type) )
    } else {
        return (^Data_Type)( p_event.p_data )
    }

    return nil
}