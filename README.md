# OdinStateManagement
Simple state management system for applications written in Odin Lang

Execute examples/tests via:
```
odin test ./test -collection:state_management=state_management 
```

Current features:
 - Finite state machine
 - Undefined state machine
 - Event System
    - Register state machines
    - Push events
    - Conditional events
    
TODO:
- Event system:
  - Publish/Post events
    - Currently events are always send to all the registered state machines accepting the input
    - Add possibility to address specific state machine
- Polish up exemaples/tests
  - Undefined state machine example
  - Proper event system example/test
    - Include conditional events
- Write Documentation
  - In code documentation
  - Describe usage on this readme
