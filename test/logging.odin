package test

import "core:testing"

import "core:fmt"
import "core:log"
import "core:runtime"

Logger_Opts: log.Options : log.Options{.Level, .Terminal_Color, .Procedure}

logger          : runtime.Logger
isInitialized   : bool = false

get_logger :: proc() -> runtime.Logger {
    if( false == isInitialized ) {
        logger = log.create_console_logger( opt=Logger_Opts)
        isInitialized = true
    }

    return logger
}

destroy_logger :: proc() {
    if( true == isInitialized ) {
        log.destroy_console_logger( &logger )
        isInitialized = false
    }
}